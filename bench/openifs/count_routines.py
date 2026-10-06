#!/usr/bin/env python3
"""Count Fortran routine bodies in the frozen OpenIFS build.

Notes
-----
Run through srun in an exclusive allocation with GNU 12.3 loaded.
Syntax reports and full inventories stay in ignored runtime storage.
This tool does not generate or change a numerical solver.
"""

import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from hashlib import sha256
import json
from pathlib import Path
import re
import shlex
import subprocess
import zipfile


def bodies(report):
    """Read actual routine scopes from a GNU 12.3 syntax report.

    Parameters
    ----------
    report : str
        Complete output from -fdump-fortran-original.

    Returns
    -------
    list of dict
        Qualified routine names, kinds and internal-routine flags.
    dict
        Counts of excluded modules, programs and generated helpers.

    Raises
    ------
    ValueError
        A named code scope has no identifiable procedure attributes.

    Notes
    -----
    Interface declarations have no code scope. Empty bodies retain one.
    An internal routine is written inside another routine or program. Alternate ENTRY
    names share one body and are recorded together.
    """
    scopes, stack = [], []
    current_symbol = None
    for line in report.splitlines():
        match = re.match(r'^( *)Namespace:', line)
        if match:
            depth = len(match[1])
            while stack and stack[-1]['depth'] >= depth:
                stack.pop()
            scope = {'depth': depth, 'name': None, 'symbols': {},
                     'parent': stack[-1] if stack else None, 'code': False, 'entries': []}
            scopes.append(scope)
            stack.append(scope)
            current_symbol = None
            continue
        if not stack:
            continue
        scope = stack[-1]
        match = re.match(r'^( *)procedure name = (.+)$', line)
        if match and len(match[1]) == scope['depth']:
            scope['name'] = match[2].strip().lower()
            continue
        match = re.match(r"^( *)symtree:.*\|\| symbol: '([^']+)'", line)
        if match and len(match[1]) == scope['depth'] + 2:
            current_symbol = match[2].lower()
            continue
        match = re.match(r'^( *)attributes: \((.*)\)', line)
        if match and len(match[1]) == scope['depth'] + 4 and current_symbol:
            scope['symbols'][current_symbol] = match[2].split()
        if line == ' ' * (scope['depth'] + 2) + 'code:':
            scope['code'] = True
        match = re.match(r'^ +ENTRY ([A-Za-z_][A-Za-z_0-9]*)', line)
        if match and scope['code']:
            scope['entries'].append(match[1].lower())

    def attributes(scope):
        owner = scope
        while owner:
            found = owner['symbols'].get(scope['name'])
            if found is not None:
                return found
            owner = owner['parent']
        raise ValueError('Missing attributes for ' + str(scope['name']))

    result, excluded = [], Counter()
    for scope in scopes:
        if not scope['name'] or not scope['code']:
            continue
        attrs = attributes(scope)
        if 'ARTIFICIAL' in attrs:
            excluded['compiler_helpers'] += 1
        elif 'MODULE' in attrs:
            excluded['modules'] += 1
        elif 'PROGRAM' in attrs or 'IS-MAIN-PROGRAM' in attrs:
            excluded['programs'] += 1
        elif 'FUNCTION' in attrs or 'SUBROUTINE' in attrs:
            chain, owner, internal = [], scope, False
            while owner:
                if owner['name']:
                    parent_attrs = attributes(owner)
                    name = owner['entries'][0] if 'ENTRY-MASTER' in parent_attrs else owner['name']
                    chain.append(name)
                    if owner is not scope and 'MODULE' not in parent_attrs:
                        internal |= 'FUNCTION' in parent_attrs or 'SUBROUTINE' in parent_attrs
                owner = owner['parent']
            result.append({'qualified_name': '::'.join(reversed(chain)),
                           'kind': 'function' if 'FUNCTION' in attrs else 'subroutine',
                           'internal': bool(internal), 'entry_points': scope['entries']})
        else:
            raise ValueError('Unknown procedure attributes for ' + scope['name'])
    return result, dict(excluded)


def inspect(index, entry, work):
    """Check one source without changing the frozen build.

    Parameters
    ----------
    index : int
        Compilation entry index.
    entry : dict
        Original compile command, source and working directory.
    work : pathlib.Path
        Audit directory for separate module output.

    Returns
    -------
    tuple
        Unit record and complete syntax report.
    """
    args, filtered, i = shlex.split(entry['command']), [], 0
    while i < len(args):
        arg = args[i]
        if arg in ('-o', '-J'):
            if arg == '-J':
                filtered.append('-I' + str(Path(entry['directory']) / args[i + 1]))
            i += 2
            continue
        if arg.startswith('-J'):
            filtered.append('-I' + str(Path(entry['directory']) / arg[2:]))
        elif arg != '-c':
            filtered.append(arg)
        i += 1
    module_dir = work / 'modules' / str(index)
    module_dir.mkdir(parents=True, exist_ok=True)
    filtered += ['-fsyntax-only', '-fdump-fortran-original', '-J' + str(module_dir)]
    run = subprocess.run(filtered, cwd=entry['directory'], capture_output=True,
                         text=True, check=False)
    source = Path(entry['file']).resolve()
    original_args = shlex.split(entry['command'])
    output = Path(original_args[original_args.index('-o') + 1])
    if not output.is_absolute():
        output = Path(entry['directory']) / output
    record = {'index': index, 'source': str(source), 'directory': entry['directory'],
              'command': filtered, 'source_sha256': sha256(source.read_bytes()).hexdigest(),
              'report_sha256': sha256(run.stdout.encode()).hexdigest(),
              'exit_code': run.returncode, 'stderr': run.stderr,
              'object': str(output),
              'target': str(output).split('/CMakeFiles/')[-1].split('.dir/')[0]}
    if run.returncode:
        record['error'] = 'Compiler syntax check failed'
    else:
        try:
            record['routines'], record['excluded'] = bodies(run.stdout)
        except ValueError as error:
            record['error'] = str(error)
    return record, run.stdout


def main():
    """Save an exact scoped inventory, rejecting incomplete results."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workers', type=int, default=16)
    parser.add_argument('--commands', type=Path,
                        default=Path('.runtime/openifs/strict-build/compile_commands.json'))
    parser.add_argument('--work', type=Path, default=Path('.runtime/openifs/routine-audit'))
    options = parser.parse_args()
    work = options.work.resolve()
    work.mkdir(parents=True, exist_ok=True)
    entries = json.loads(options.commands.read_text())
    configured = [(i, e) for i, e in enumerate(entries)
                  if Path(e['file']).suffix.lower() in ('.f', '.f90', '.f95', '.f03', '.f08', '.for')]
    selected = []
    for index, entry in configured:
        args = shlex.split(entry['command'])
        output = Path(args[args.index('-o') + 1])
        if not output.is_absolute():
            output = Path(entry['directory']) / output
        if output.exists():
            selected.append((index, entry))
    records = []
    with zipfile.ZipFile(work / 'frontend-reports.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        with ThreadPoolExecutor(max_workers=options.workers) as executor:
            futures = [executor.submit(inspect, i, entry, work) for i, entry in selected]
            for future in as_completed(futures):
                record, report = future.result()
                records.append(record)
                archive.writestr(str(record['index']) + '.dump', report)
                if 'error' in record:
                    print('AUDIT_ERROR', record['source'], record['error'], flush=True)
                if len(records) % 100 == 0:
                    print('AUDIT_PROGRESS', len(records), '/', len(selected), flush=True)
    records.sort(key=lambda record: record['index'])
    (work / 'units.json').write_text(json.dumps(records, indent=2) + '\n')
    failures = [record for record in records if 'error' in record]
    if failures:
        raise SystemExit('Audit incomplete for ' + str(len(failures)) + ' source compilations')
    unique = {}
    for record in records:
        for routine in record['routines']:
            key = record['source'] + ':' + routine['qualified_name']
            previous = unique.get(key)
            if previous and previous['kind'] != routine['kind']:
                raise SystemExit('Conflicting configured routine kinds for ' + key)
            unique[key] = {'source': record['source'], 'target': record['target'], **routine}
    inventory = [unique[key] for key in sorted(unique)]
    data = (json.dumps(inventory, sort_keys=True, separators=(',', ':')) + '\n').encode()
    (work / 'inventory.json').write_bytes(data)
    summary = {'date_utc': datetime.now(timezone.utc).isoformat(),
               'scope': 'Unique Fortran routine bodies in completed compilation units of the frozen forecast build',
               'configured_fortran_compilations': len(configured),
               'configured_unbuilt_compilations': len(configured) - len(selected),
               'fortran_compilations': len(selected), 'unique_sources': len({r['source'] for r in records}),
               'routines': len(inventory), 'kinds': dict(Counter(r['kind'] for r in inventory)),
               'internal_routines': sum(r['internal'] for r in inventory),
               'routine_counts_by_target': dict(sorted(Counter(r['target'] for r in inventory).items())),
               'inventory_sha256': sha256(data).hexdigest(), 'failed_compilations': 0,
               'compiler_commands_sha256': sha256(options.commands.read_bytes()).hexdigest()}
    (work / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2), flush=True)


if __name__ == '__main__':
    main()

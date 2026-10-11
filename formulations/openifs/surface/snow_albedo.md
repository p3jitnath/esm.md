# Snow Albedo

Revision 1.0 describes OpenIFS `SRFSN_ASN_MOD::SRFSN_ASN`. Albedo is the fraction of incoming Sun's radiation that a surface reflects. Fresh snow has high albedo. Snow becomes darker as it ages, with a faster change while it melts.

Let $`A`$ be the previous albedo, $`A_{\min}`$ and $`A_{\max}`$ the lower and upper albedo limits, and $`\Delta t`$ the time step in seconds. Let $`D`$ be the number of seconds in one day. Let $`r_a`$ be the daily loss during ordinary ageing and $`r_f`$ the daily melting rate. Equation P01 defines the aged value $`B`$.

```math
B=
\begin{cases}
A_{\min}+(A-A_{\min})e^{-r_f\Delta t/D},&\text{melting},\\
\max(A_{\min},A-r_a\Delta t/D),&\text{ordinary ageing}.
\end{cases}
```

Let $`S`$ be the snowfall rate in kilograms per square metre per second. Equation P02 moves the aged albedo towards fresh snow as new snow accumulates, then keeps it within its physical limits.

```math
w=\min\left(1,\frac{\max(S\Delta t,0)}{10\ \mathrm{kg\,m^{-2}}}\right),\qquad
A_{\rm new}=\min\left(A_{\max},\max\left(A_{\min},B+w(A_{\max}-B)\right)\right).
```

The standard parameters are $`A_{\min}=0.50`$, $`A_{\max}=0.85`$, $`r_a=0.008`$, $`r_f=0.24`$ and $`D=86400\ \mathrm{s}`$. The caller supplies the time step, previous albedo, snowfall and melting indicator. A positive melting indicator selects the melting law. A column marked as having no snow returns $`A_{\max}`$, matching this child's boundary convention. Columns outside the requested range retain their previous output bytes.

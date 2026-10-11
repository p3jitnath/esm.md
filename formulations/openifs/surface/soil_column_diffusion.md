# Diffusion Between Soil Layers

Revision 1.0 uses the complete OpenIFS 48.1.1 SRFWDIF calculation. Diffusion moves water between neighbouring soil layers. The same calculation can move heat between ice layers when temperature replaces water fraction. Let $`q_i`$ be the supplied old state in layer $`i`$, $`\alpha`$ be a weight between zero and one, and $`r_i`$ be the supplied change from other fluxes.

```math
b_i=\frac{q_i}{\alpha}+r_i. \tag{WD-1}
```

Let $`d_i>0`$ be the supplied layer weight in metres and $`k_i\geq0`$ be the supplied diffusion factor in metres. These factors include the time step. The returned scaled state $`u_i`$ satisfies

```math
d_i(u_i-b_i)+k_{i-1}(u_i-u_{i-1})+k_i(u_i-u_{i+1})=0. \tag{WD-2}
```

Each equation balances the stored change against flow from adjacent layers. The top has zero upward flow. At the bottom, the supplied $`k_i`$ acts against a zero exterior value. A zero bottom factor gives a closed column. Soil water uses cubic metres of water per cubic metre of soil, while the ice calculation uses kelvin. The old state, supplied change and returned state use the same units within each call. Sea cells keep their existing output.

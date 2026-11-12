# Sun Radiation Through Atmospheric Layers

Revision 1 describes the shortwave adding model in OpenIFS. Shortwave radiation is the Sun's radiation, which the atmosphere can absorb, reflect towards space, or pass towards the ground. Divide a column of air into $`N`$ layers and solve each selected wavelength interval separately.

Let $`Q_j`$ be the direct beam at boundary $`j`$, measured perpendicular to the beam. Let $`D_j`$ and $`U_j`$ be downward and upward diffuse radiation, which has scattered into several directions. Their units are watts per square metre, written W m$`^{-2}`$. Boundary 1 is the top and boundary $`N+1`$ is the ground.

For each layer, $`r_j`$ and $`t_j`$ are the reflected and transmitted fractions of diffuse radiation. The direct transmitted fraction is $`d_j`$. Fractions $`b_j`$ and $`c_j`$ convert the direct beam into upward and downward diffuse radiation through a horizontal surface. These coefficients have no units.

```math
Q_{j+1}=d_jQ_j \tag{SW-A1}
```

```math
U_j=r_jD_j+t_jU_{j+1}+b_jQ_j \tag{SW-A2}
```

```math
D_{j+1}=t_jD_j+r_jU_{j+1}+c_jQ_j \tag{SW-A3}
```

The first equation passes the unscattered beam to the next boundary. The other equations add the reflected, transmitted and scattered radiation at a layer.

Let $`\mu`$ be the cosine of the angle between the Sun and the vertical. The direct radiation through a horizontal surface is $`\mu Q_j`$. The supplied top beam is $`Q_1`$ and incoming diffuse radiation is zero. At the ground, $`a_d`$ and $`a_b`$ are the reflected fractions for diffuse and direct radiation.

```math
D_1=0,\qquad U_{N+1}=a_dD_{N+1}+a_b\mu Q_{N+1} \tag{SW-A4}
```

The input beam is nonnegative. Each albedo, cosine and layer fraction lies between zero and one. Layer coefficients satisfy $`r_j+t_j\leq1`$ and $`b_j+c_j\leq\mu(1-d_j)`$, so a layer cannot create energy. The forecast supplies these values. The reviewed coarse forecast used 112 wavelength intervals and 19 layers. The [md2fort contract](../../../skills/md2fort/references/openifs/physics/adding_ica_sw.md) records the numerical update and assembly interface.

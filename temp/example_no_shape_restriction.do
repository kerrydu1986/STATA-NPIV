clear
capture program drop npivreg

// set the seed
set seed 1234

// number of observations = sample size
set obs 1000

// instrument z is generated from standard normal dist.
generate double z = rnormal(0, 1)

/* errors u and v are generated from Joint normal dist
    u       ~     N( 0,  1.0   0.5 )
    v              ( 0,  0.5   1.0 )
   correlation btw u and v = 0.5
*/
matrix C = (1, .5 \ .5, 1)
drawnorm u v, corr(C)

// DGP for x
generate x = 3*z + v

// DGP for y
generate true_y = exp(0.5*x) / (1 + exp(0.5*x))
generate y =  true_y + u


// NPIV regression with polynomial spline - power(2, 3) and num_knots(3,4)
npivreg y x z, power_exp(2) power_inst(3) num_exp(3) num_inst(4) pctile(1) polynomial
// Comparison of true y and fitted value (drawing a chart)
generate ygrid = exp(0.5*grid) / (1 + exp(0.5*grid))
line ygrid grid, sort || line npest grid, title("power= (2,3), knots = (3,4)") name(setting_poly, replace)

// NPIV regression with bspline - power(2, 3) and num_knots(3,4)
npivreg y x z, power_exp(2) power_inst(3) num_exp(3) num_inst(4) pctile(1) 
// Comparison of true y and fitted value (drawing a chart)
line ygrid grid, sort || line npest grid, title("power= (2,3), knots = (3,4)") name(setting_bspl, replace)

// Combined graph for all the settings
gr combine setting_poly setting_bspl, cols(2) title("Polyspline(left) vs bspline(right)") ycom

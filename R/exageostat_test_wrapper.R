# Test of exageostat_gen_zR
#
#
   n = 1600
   ncores =10
   gpus =0
   ts=520
   p_grid=1
   q_grid= 1

TestWrapper <- function()
{
#

   library(exageostatdev)


#
# generate vectors that we will treat as a two dimensional array, 
# initialize the variables to recognizable values for debugging.
#
 #  theta = vector(mode="character",length = 10)
 #  computation = vector(mode="character",length = 5)
 #  dmetric = vector(mode="character",length = 3)
 #  theta="1:0.1:0.5"
 #  computation="exact"
 #  dmetric="ed"
#print("sdfsd")

#
#   vecs_out = exageostat_gen_zR(n, ncores, gpus, ts, p_grid, q_grid, theta, compuation, dmetric)
#   theta_out = (n, ncores, gpus, ts, p_grid, q_grid,  vecs_out[1:n-1],  vecs_out[n:2n-1],  vecs_out[2n:3n-1], clb, cub, compuation, dmetric)

#
print("Back from exageostat_gen_z! hit key...")
browser()
#
# done. 
#
}
exageostat_gen_zR <- function(n, ncores, gpus, ts, p_grid, q_grid, theta, compuation, dmetric)
{
vecs_out= .C("exageostat_gen_zR",
		as.integer(n),
                as.integer(ncores),
                as.integer(gpus),
                as.integer(ts),
                as.integer(p_grid),
                as.integer(q_grid),
                as.numeric(theta),
                as.numeric(computation),
                as.numeric(dmetric))
print("back from exageostat_gen_z C function call. Hit key....")
return(vecs_out)
}


exageostat_likelihoodR <- function(n, ncores, gpus, ts, p_grid, q_grid, x, y, z, clb, cub, compuation, dmetric)
{


theta_out= .C("exageostat_likelihoodR",
                as.integer(n),
                as.integer(ncores),
                as.integer(gpus),
                as.integer(ts),
                as.integer(p_grid),
                as.integer(q_grid),
		as.numeric(x),
		as.numeric(y),
		as.numeric(z),
                as.numeric(clb),
		as.numeric(cub),
                as.numeric(computation),
                as.numeric(dmetric))
  print("back from exageostat_likelihood C function call. Hit key....")
  return(theta_out)
}

exageostat_initR <- function(ncores, gpus, ts)
{
	.C("exageostat_initR",
                as.integer(ncores),
                as.integer(gpus),
                as.integer(ts))
print("back from exageostat_init C function call. Hit key....")
}

exageostat_finalizeR <- function()
{
	.C("exageostat_finalizeR")
print("back from exageostat_finalize C function call. Hit key....")

}



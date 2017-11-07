# Test of exageostat_gen_zR
#
#
 TestWrapper <- function()
{
	install.packages(repos=NULL, "exageostat_0.1.0.tar.gz")
   	library(exageostat)
   	theta1 = 1
	theta2 = 0.1
	theta3 = 0.5
   	computation = 0  #exact
   	dmetric = 0 	#ed
   	n=1600
   	ncores=3
   	gpus=0
   	ts=320
   	p_grid=1
   	q_grid=1
        clb = vector(mode="character",length = 3)
        cub = vector(mode="character",length = 3)
        theta_out = vector(mode="numeric",length = 3)
   	clb=as.numeric(c("0.01","0.01","0.01"))
	globalveclen =  3*n
	cub=as.numeric(c("5","5","5"))
   	vecs_out = vector(mode="numeric",length = globalveclen)
  	vecs_out[1:globalveclen] = -1.99
	vecs_out = rexageostat_gen_zR(n, ncores, gpus, ts, p_grid, q_grid, theta1, theta2, theta3, computation, dmetric, globalveclen)
	theta_out = rexageostat_likelihoodR(n, ncores, gpus, ts, p_grid, q_grid,  vecs_out[1:n],  vecs_out[n+1:(2*n)],  vecs_out[(2*n+1):(3*n)], clb, cub, computation, dmetric)

#
print("Back from exageostat_gen_z! hit key...")
browser()
#
# done. 
#
}
rexageostat_gen_zR <- function(n, ncores, gpus, ts, p_grid, q_grid, theta1, theta2, theta3, computation, dmetric, globalveclen)
{
print(globalveclen)
globalvec= vector (mode="numeric", length = globalveclen)
globalvec2 = .C("rexageostat_gen_z",
		as.integer(n),
                as.integer(ncores),
                as.integer(gpus),
                as.integer(ts),
                as.integer(p_grid),
                as.integer(q_grid),
                as.numeric(theta1),
		as.numeric(theta2),
		as.numeric(theta3),
                as.integer(computation),		
                as.integer(dmetric),
                as.integer(globalveclen),		
		globalvec = numeric(globalveclen))$globalvec

globalvec[1:globalveclen] <- globalvec2[1:globalveclen]
print("back from exageostat_gen_z C function call. Hit key....")
return(globalvec)
}


rexageostat_likelihoodR <- function(n, ncores, gpus, ts, p_grid, q_grid, x, y, z, clb, cub, computation, dmetric)
{
theta_out2= .C("rexageostat_likelihood",
                as.integer(n),
                as.integer(ncores),
                as.integer(gpus),
                as.integer(ts),
                as.integer(p_grid),
                as.integer(q_grid),
		as.numeric(x),
		as.integer((n)),
		as.numeric(y),
		as.integer((n)),
		as.numeric(z),
                as.integer((n))	,	
                as.numeric(clb),
                as.integer((3)),	
		as.numeric(cub),
                as.integer((3)),
		as.integer(computation),
                as.integer(dmetric),
		theta_out=numeric(3))$theta_out		
theta_out[1:3] <- theta_out2[1:3]
print("back from exageostat_likelihood C function call. Hit key....")
return(theta_out)
}

rexageostat_initR <- function(ncores, gpus, ts)
{
	.C("rexageostat_init",
                as.integer(ncores),
                as.integer(gpus),
                as.integer(ts))
print("back from exageostat_init C function call. Hit key....")
}

rexageostat_finalizeR <- function()
{
	.C("rexageostat_finalize")
print("back from exageostat_finalize C function call. Hit key....")
}



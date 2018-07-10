 #
 #
 # Copyright (c) 2017, King Abdullah University of Science and Technology
 # All rights reserved.
 #
 # ExaGeoStat-R is a software package provided by KAUST
 #
 #
 #
 # @file test2.R
 # ExaGeoStat R wrapper test example
 #
 # @version 0.1.0
 #
 # @author Sameh Abdulah
 # @date 2018-07-04
library("exageostat")                                           #Load ExaGeoStat-R lib.
theta1          = 1                                             #Initial variance.
theta2          = 0.03                                          #Initial smoothness.
theta3          = 0.5                                           #Initial range.
computation     = 0                                             #0 --> exact computation, 1--> DST approx, and 2--> LR approx. computation.
dmetric         = 0                                             #0 --> Euclidean distance, 1--> great circle distance.
n               = 900                                           #n*n locations grid.
ncores          = 4                                             #Number of underlying CPUs.
gpus            = 0                                             #Number of underlying GPUs.
ts             = 320                                           #Tile_size:  changing it can improve the performance. No fixed value can be given.
p_grid          = 1                                             #More than 1 in the case of distributed systems.
q_grid          = 1                                             #More than 1 in the case of distributed systems ( usually equals to p_grid).
clb             = vector(mode="numeric", length = 3)            #Optimization function lower bounds values.
cub             = vector(mode="numeric", length = 3)            #Optimization function upper bounds values.
theta_out       = vector(mode="numeric", length = 3)            #Parameter vector output.
globalveclen    = 3*n
vecs_out        = vector(mode="numeric", length = globalveclen) #Z measurements of n locations.
clb             = as.numeric(c("0.01", "0.01", "0.01"))         #Optimization lower bounds.
cub             = as.numeric(c("5.00", "5.00", "5.00"))         #Optimization upper bounds.
dst_thick       = 3                                             #Number of used Diagonal Super Tile (DST).
vecs_out[1:globalveclen]        = -1.99
theta_out[1:3]                  = -1.99
#Initiate exageostat instance
exageostat_initR(ncores, gpus, ts)
#Generate Z observation vector
vecs_out        = exageostat_egenzR(n, ncores, gpus, ts, p_grid, q_grid, theta1, theta2, theta3, dmetric, globalveclen)
#Estimate MLE parameters (DST approximation)
theta_out       = exageostat_dstmleR(n, ncores, gpus, ts, p_grid, q_grid,  vecs_out[1:n],  vecs_out[n+1:(2*n)],  vecs_out[(2*n+1):(3*n)], clb, cub, dst_thick,  dmetric, 0.0001, 20)
#Finalize exageostat instance
exageostat_finalizeR()

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
seed            = 0                                             #Initial seed to generate XY locs.
theta1          = 1                                             #Initial variance.
theta2          = 0.03                                          #Initial smoothness.
theta3          = 0.5                                           #Initial range.
dmetric         = 0                                             #0 --> Euclidean distance, 1--> great circle distance.
n               = 900                                           #n*n locations grid.
ncores          = 4                                             #Number of underlying CPUs.
gpus            = 0                                             #Number of underlying GPUs.
dts             = 320                                           #Tile_size:  changing it can improve the performance. No fixed value can be given.
lts             = 600                                           #TLR_Tile_size:  changing it can improve the performance. No fixed value can be given.
p_grid          = 1                                             #More than 1 in the case of distributed systems.
q_grid          = 1                                             #More than 1 in the case of distributed systems ( usually equals to p_grid).
clb             = vector(mode="double", length = 3)            #Optimization function lower bounds values.
cub             = vector(mode="double", length = 3)            #Optimization function upper bounds values.
theta_out       = vector(mode="double", length = 3)            #Parameter vector output.
globalveclen    = 3*n
vecs_out        = vector(mode="double", length = globalveclen) #Z measurements of n locations.
clb             = as.double(c("0.01", "0.01", "0.01"))         #Optimization lower bounds.
cub             = as.double(c("5.00", "5.00", "5.00"))         #Optimization upper bounds.
tlr_acc         = 7                                             #Approximation accuracy 10^-(acc)
tlr_maxrank     = 450                                           #Max Rank
vecs_out[1:globalveclen]        = -1.99
theta_out[1:3]                  = -1.99
#Initiate exageostat instance
exageostat_initR(ncores, gpus, dts)
#Generate Z observation vector
vecs_out        = exageostat_egenzR(n, ncores, gpus, dts, p_grid, q_grid, theta1, theta2, theta3, dmetric, seed, globalveclen)
#Estimate MLE parameters (TLR approximation)
theta_out       = exageostat_tlrmleR(n, ncores, gpus, lts, p_grid, q_grid,  vecs_out[1:n],  vecs_out[n+1:(2*n)],  vecs_out[(2*n+1):(3*n)], clb, cub, tlr_acc, tlr_maxrank,  dmetric, 0.0001, 20)
#Finalize exageostat instance
exageostat_finalizeR()
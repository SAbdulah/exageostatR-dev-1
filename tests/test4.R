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
 # @version 1.0.0
 #
 # @author Sameh Abdulah
 # @date 2019-01-17
library("exageostat")                                                   #Load ExaGeoStat-R lib.
theta1          = 1                                                     #Initial variance.
theta2          = 0.1                                                   #Initial smoothness.
theta3          = 0.5                                                   #Initial range.
dmetric         = 0                                                     #0 --> Euclidean distance, 1--> great circle distance.
n               = 1600                                                  #n*n locations grid.
x               = rnorm(n = 1600, mean = 39.74, sd = 25.09)     #x measurements of n locations.
y               = rnorm(n = 1600, mean = 80.45, sd = 100.19)    #y measurements of n locations.
#Initiate exageostat instance
exageostat_initR(hardware = list (ncores=2, ngpus=0, ts=320, lts=0,  pgrid=1, qgrid=1))#Initiate exageostat instance
#Generate Z observation vector based on given locations
data          = exageostat_egenz_glR( x, y, theta1, theta2, theta3, dmetric)
#Estimate MLE parameters (Exact)
result        = exageostat_emleR(data, dmetric, optimization = list(clb = c(0.001, 0.001, 0.001), cub = c(5, 5,5 ), tol = 1e-4, max_iters = 20))
#print(result)
#Finalize exageostat instance
exageostat_finalizeR()

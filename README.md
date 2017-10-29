ExaGeoStatR
===========

`exageostatR` is an R package for ExaGeoStat framework: a parallel high performance unified framework for geostatistics on manycore systems

Getting Started
===============

### Install

#### git clone exageostatR repo
git clone https://github.com/ecrc/exageostatR.git

#### Update submodules
git submodule init
git submodule update

#### Use ExaGeoStatR
``` r
library("exageostatR")
```

Possibilities of ExaGeoStat
===========================

This project is WIP, only a few things are working right now.

Operations:

1. Generate synthetic spatial datasets (i.e., locations & environmental measurements).
2. Maximum likelihood operation using dense matrices.
Backends:

CHAMELEON & STARPU

Tutorial
========

A more detailed description could be accessible [here](https://github.com/ecrc/exageostat)

For example, to search for data scientist jobs in London:
```r
library("exageostat")
library("RhpcBLASctl")
#Inputs
theta1 = 1       # initial variance
theta2 = 0.1     # initial smothness
theta3 = 0.5     # initial range
computation = 0  # exact computation
dmetric = 0      # ed  euclidian distance
n=1600           # n*n locations grid 
gpus=0           # number of underlying GPUs
ts=320           # tile_size:  change it could improve the performance. No fixed value can be given
p_grid=1         # more than 1 in the case of distributed systems 
q_grid=1         # more than 1 in the case of distributed systems ( usually equals to p_grid)
clb = vector(mode="numeric",length = 3)    #optimization lower bounds
cub = vector(mode="numeric",length = 3)    #optimization upper bounds
theta_out = vector(mode="numeric",length = 3)    # parameter vector output
clb=as.numeric(c("0.01","0.01","0.01"))
globalveclen =  3*n
cub=as.numeric(c("5","5","5"))
vecs_out = vector(mode="numeric",length = globalveclen)     #Z measurments of n locations
vecs_out[1:globalveclen] = -1.99
theta_out[1:3]= -1.99
#Generate Z observation vector
vecs_out = rexageostat_gen_zR(n, ncores, gpus, ts, p_grid, q_grid, theta1, theta2, theta3, computation, dmetric, globalveclen)
#Estimate MLE parameters
theta_out = rexageostat_likelihoodR(n, ncores, gpus, ts, p_grid, q_grid,  vecs_out[1:n],  vecs_out[n+1:(2*n)],  vecs_out[(2*n+1):(3*n)], clb, cub, computation, dmetric)
```

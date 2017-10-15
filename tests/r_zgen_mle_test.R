brary(exageostat)
        theta1 = 1
        theta2 = 0.1
        theta3 = 0.5
        computation = 0  #exact
        dmetric = 0     #ed
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


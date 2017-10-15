/**
 *
 * @file Main.c
 *
 *
 *  MLE is a software package provided by KAUST,
 *  King Abdullah University of Science and Technology - ECRC
 *
 * @version 1.0.0
 * @author Sameh Abdulah
 * @date 2016-11-22
 * @generated d Fri Nov 22 15:11:13 2016
 *
 **/

#include "../src/include/MLE.h"
#include "../r-wrappers/include/rwrappers.h"
//#include "starsh.h"
//#include "starsh-spatial.h"

int main(int argc, char **argv) {

        //initialization
        char *theta;  //for testing case
        int n, ts, log, verbose;
        int i=0;
    char *dm;
    char *computation, *clb, *cub;
	int computation_int;
	int dm_int=0;
        double time_opt=0.0;
        int gpus=0, p_grid =1, q_grid =1, ncores =1;
	int thetalen=3;
        arguments arguments;
    double *vecs_out =NULL, *theta_out =NULL;

        //Arguments default values
        set_args_default(&arguments);
        argp_parse (&argp, argc, argv, 0, 0, &arguments);


    //read inputs
    n        = atoi(arguments.N);
    ncores        = atoi(arguments.ncores);
        gpus        = atoi(arguments.gpus);
        p_grid        = atoi(arguments.p);
        q_grid        = atoi(arguments.q);    
    ts        = atoi(arguments.ts);    
    dm          = arguments.dm;
    computation    = arguments.computation; //approx or exact
    theta        = arguments.ikernel;
    clb        = arguments.olb;
    cub        = arguments.oub;


if (strcmp(dm, "ed") == 0)
	dm_int=0;
else
	dm_int=1;

if (strcmp(computation, "exact") == 0)
	computation_int=0;
else
	computation_int=1;



	int globalveclen = thetalen * n;

    theta_out=(double *) malloc(thetalen * sizeof(double));
        vecs_out=(double *) malloc( globalveclen * sizeof(double));
	double * initial_theta=(double *) malloc (thetalen * sizeof(double)); 
	   double *lb= (double *) malloc(thetalen * sizeof(double));
        double *ub= (double *) malloc(thetalen * sizeof(double));
	theta_parser2(initial_theta, theta);   
	    theta_parser2(lb, clb);
        theta_parser2(ub, cub);

//uniform random generation for locations if x = NULL and y = NULL
    //rexageostat_init(&ncores,&gpus, &ts);
    rexageostat_gen_z(&n,   &ncores,   &gpus,  &ts,   &p_grid,  &q_grid,  &initial_theta[0],  &initial_theta[1],  &initial_theta[2],  &computation_int,  &dm_int, &globalveclen, vecs_out);



rexageostat_likelihood(&n, &ncores, &gpus, &ts, &p_grid, &q_grid,  vecs_out, NULL,  &vecs_out[n], NULL,  &vecs_out[2*n], NULL,   lb, &thetalen, ub, thetalen, &computation_int, &dm_int,  theta_out);
    
    printf("%f - %f - %f\n", theta_out[0], theta_out[1], theta_out[2]);
    //rexageostat_finalize();


    //free memory
    free(theta_out);
    free(vecs_out);
free(ub);
free(lb);
        return 0;
        }


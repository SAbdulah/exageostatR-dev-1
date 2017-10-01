/**
 *
 * @file MLE.c
 *
 *  
 *  ExaGeoStat is a software package provided by KAUST,
 *  King Abdullah University of Science and Technology - ECRC
 *
 * @version 0.1.0
 * @author Sameh Abdulah
 * @date 2016-11-22
 * @generated d Fri Nov 22 15:11:13 2016

 *
 **/
#include "../include/rwrappers.h"

void  exageostat_gen_z(int *n, int *ncores, int *gpus, int *ts, int *p_grid, int *q_grid,  char *theta, char *computation, char *dmetric, double *vecs_out)
{
	//initialization
        int i=0;
	int log=0, verbose=0;
	double  *initial_theta;
        MLE_data data;
        int iseed[4]={0, 0, 0, 1};
        MORSE_sequence_t *msequence;
        MORSE_request_t mrequest[2] = { MORSE_REQUEST_INITIALIZER, MORSE_REQUEST_INITIALIZER };

	initial_theta=(double *) malloc(3 * sizeof(double));

	data.l1.x=vecs_out;
	data.l1.y=&vecs_out[*n];

	//Generate XY locs
	GenerateXYLoc(*n, "", &data.l1);
	
        //set data struct
	data.computation = computation;
        data.verbose=verbose;
        data.dm=dmetric;
        data.l2=data.l1;
	data.async=0;
	data.obsFPath="";
	data.log=log;
        gsl_set_error_handler_off () ;
	
	//parse theta to initial_theta
	theta_parser2(initial_theta, theta);
        
	//nomral random generation of e -- ei~N(0, 1) to generate Z
	LAPACKE_dlarnv(3, iseed, *n, &vecs_out[2**n]);


	MORSE_Sequence_Create(&msequence);
        MORSE_Desc_Create(&data.descC,NULL , MorseRealDouble, *ts, *ts, *ts * *ts, *n, *n, 0, 0, *n, *n, *p_grid, *q_grid);
        MORSE_Desc_Create(&data.descZ, NULL, MorseRealDouble, *ts, *ts, *ts * *ts, *n, 1,  0, 0, *n , 1, *p_grid, *q_grid);
	data.sequence          = msequence;
        data.request           = mrequest;


        //Main algorithm call
        MLE_zvg(&data, &vecs_out[2**n], initial_theta, *n, ts, 1, log) ;
	MORSE_Tile_to_Lapack(data.descZ, &vecs_out[2**n], *n);    

	

	MORSE_Desc_Destroy( &data.descC );
        MORSE_Desc_Destroy( &data.descZ);

	free(initial_theta);


}

void  exageostat_likelihood(int *n,  int *ncores, int *gpus, int *ts, int *p_grid, int *q_grid,  double *x, double *y, double *z, char *clb, char *cub,  char *computation, char *dmetric, double * theta_out)
{
	//initialization
        int i=0;
	int log=0, verbose=0;
        double time_opt=0.0;
        double max_loglik=0.0;
        double * opt_f;
        nlopt_opt opt;
        MLE_data data;
	double *lb= (double *) malloc(3 * sizeof(double));
        double *ub= (double *) malloc(3 * sizeof(double));	
	double *starting_theta = (double *) malloc(3 * sizeof(double));

	//Assign inputs
        data.computation = computation;
        data.verbose=verbose;
        data.dm=dmetric;
        data.async=0;
	data.l1.x=x;
	data.l1.y=y;
        data.l2=data.l1;	
        data.iter_count=0;
	data.log=log;
	//parse char* to double *
        theta_parser2(lb, clb);
	theta_parser2(ub, cub);
	starting_theta[0]=lb[0];
	starting_theta[1]=lb[1];
	starting_theta[2]=lb[2];


	//optimizer initialization
        init_optimizer(&opt, lb, ub, 1e-5);

	//if(data.based_sys==1)
        MORSE_Call(&data, *ncores,*gpus, *ts, *p_grid, *q_grid, *n,  0, 0);

        MORSE_Lapack_to_Tile( z, *n, data.descZ);

        print_summary(1, *n, *ncores, *gpus, *ts, computation, 1, 1, 1);

	//main algorithm call
	START_TIMING(data.total_exec_time);
	nlopt_set_max_objective(opt, MLE_alg, (void *)&data);
	nlopt_optimize(opt, starting_theta, &opt_f);
	STOP_TIMING(data.total_exec_time);

	print_result(&data, starting_theta, *n, 1, *ncores, *ts, 1, NULL, computation, 1, 1, data.final_loglik);

	//destory descriptors & free memory
        nlopt_destroy(opt);
	MORSE_Desc_Destroy( &data.descC );
        MORSE_Desc_Destroy( &data.descZ );
        MORSE_Desc_Destroy( &data.descZcpy );
        MORSE_Desc_Destroy( &data.descproduct );
        MORSE_Desc_Destroy( &data.descdet );
	free(ub);
	free(lb);
	//printf("%f - %f - %f\n", starting_theta[0], starting_theta[1], starting_theta[2]);
	theta_out[0]=starting_theta[0];
	theta_out[1]=starting_theta[1];
        theta_out[2]=starting_theta[2];
}


void exageostat_init(int *ncores, int *gpus, int *ts)
{
//MORSE_user_tag_size(31,26);
        MORSE_Init(*ncores, *gpus);
        MORSE_Set(MORSE_TILE_SIZE, *ts);
}
void exageostat_finalize()
{

        MORSE_Finalize();
}


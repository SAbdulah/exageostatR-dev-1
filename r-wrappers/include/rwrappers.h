/**

 *
 * @file MLE.h
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
#ifndef _RWRAPPERS_H_
#define _RWRAPPERS_H_
#include "../../src/include/MLE.h"

void  exageostat_gen_z(int *n, int *ncores, int *gpus, int *ts, int *p_grid, int *q_grid,  char *theta, char *computation, char *dmetric, double *vecs__out);
void  exageostat_likelihood(int *n,  int *ncores, int *gpus, int *ts, int *p_grid, int *q_grid,  double *x, double *y, double *z, char *clb, char *cub,  char *computation, char *dmetric, double * theta_out);
void exageostat_init(int *ncores, int *gpus, int *ts);
void exageostat_finalize();

#endif

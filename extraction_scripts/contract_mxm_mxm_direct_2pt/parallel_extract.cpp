#include <stdio.h>                                                              
#include <stdlib.h>                                                             
#include </global/homes/s/srijitp/local-20151028/aff/include/lhpc-aff.h>
#include <complex.h>
#include "/global/homes/s/srijitp/spaul/build2/parts/aff/tree/lib/aff.h"
#include <cmath>
#include <string>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <ctime>
#include <omp.h>
#include <mpi.h>
#include "mpi-helpers.hpp"
#define FALSE 0
#define TRUE  1

#define Idx(i,j,k,l) ( 96 * ((i+1) + 3*((j+1) + 3*((k+1) + 3*(l)))))

using namespace std;


int main(int argc, char **argv)
{
	MPI_Init(& argc, & argv);
	mpi_t mpi;
	setupMpi(mpi);
	int T_global = 96;
	int gc = 15;
	int sample = 0;
	int nconf;
	nconf = ;
	int status;
	int Lsize = 32;	
	double phase;
	double _Complex *m_m = NULL;
	double _Complex *coh_m_m = NULL;
	m_m = (double _Complex*)malloc(27 * 12 * 4 * 2*T_global*sizeof(double));
	coh_m_m = (double _Complex*)malloc(27 * 12 * 4 * 2*T_global*sizeof(double));
	int source_list[8][4];

	char filename[100]; 
	sprintf(filename,"src_%.4d",nconf);
	char config_name_1[100];
	char config_name_2[100];

	ifstream src_loc(filename,ios::in);
	int ch = 0;
	int ch_new = 0;
	while(ch!=8) {
		src_loc>>source_list[ch][0]>>source_list[ch][1]>>source_list[ch][2]>>source_list[ch][3];
		ch = ch +1;
	}
	int pf2z = (mpi.world_rank/243) - 1;
	int pf2y = (mpi.world_rank%243)/81 - 1;
	int pf2x = ((mpi.world_rank%243)%81)/27 - 1;
	int pi2z = (((mpi.world_rank%243)%81)%27)/9 - 1;
	int pi2y = ((((mpi.world_rank%243)%81)%27)%9)/3 - 1;
	int pi2x = (mpi.world_rank%3) - 1;

	cout<<"Reading started"<<endl;
	sprintf(config_name_2,"contract_m_m_2pt.%.4d",nconf);
	double _Complex *buffer_2 = NULL;
	struct AffReader_s *g;
	struct AffNode_s *affn_2 = NULL, *affdir_2=NULL;
	char buffer_path_2[200];
	g = aff_reader(config_name_2);
	const char *status_str;
	status_str = aff_reader_errstr(g);
	if (status_str) {
		printf("reader open error: %s\n", status_str);
		aff_reader_close(g);
	}
	buffer_2 = (double _Complex*)malloc(2*T_global*sizeof(double));
	if(buffer_2== NULL) exit(101);
	for(int pf1x = -1; pf1x <=1; pf1x ++) {
		for(int pf1y = -1; pf1y <=1; pf1y ++) {
			for(int pf1z = -1; pf1z<=1; pf1z ++) {

				for(int coh_src = 0; coh_src<8; coh_src++) {
					sprintf(buffer_path_2,"/m-m/gf15_gi15/px%.2dpy%.2dpz%.2d/x%.2dy%.2dz%.2dt%.2d",
							pf1x,pf1y,pf1z,source_list[coh_src][0],source_list[coh_src][1],source_list[coh_src][2],source_list[coh_src][3]);
					affdir_2 = aff_reader_chpath (g, affn_2, buffer_path_2);
					status = aff_node_get_complex (g, affdir_2, buffer_2, T_global);
					if(status != 0) {
						printf("%s  %s\n",config_name_2, buffer_path_2);
						fprintf(stderr, " Error from aff_node_get_complex_1, status was %d\n", status);
						exit(105);
					}
					/* Key pattern
					   /m-m/gf15_gi15/px01py01pz01/x18y25z21t62  
					 */

					//	for(int sample = 0; sample<12; sample++) {
					sprintf(config_name_1,"contract_m_m_oet_2pt.%.4d.t%.2d",nconf,source_list[coh_src][3]);
					double _Complex *buffer_1 = NULL;
					struct  AffReader_s *f;
					struct AffNode_s *affn_1 = NULL, *affdir_1=NULL;
					char buffer_path_1[200];
					f = aff_reader(config_name_1);
					const char *status_str;
					status_str = aff_reader_errstr(f);
					if (status_str) {
						printf("reader open error: %s\n", status_str);
						aff_reader_close(f);
					}
					buffer_1 = (double _Complex*)malloc(2*T_global*sizeof(double));
					if(buffer_1== NULL) exit(101);

					/* Key pattern
					   /m-m-oet/sample00/gf15_gi15/px-01py-01pz-01/kx01ky01kz01/t02 
					 */

					sprintf(buffer_path_1,"/m-m-oet/sample%.2d/gf15_gi15/px%.2dpy%.2dpz%.2d/kx%.2dky%.2dkz%.2d/t%.2d",sample,pi2x,pi2y,pi2z,pf2x,pf2y,pf2z,source_list[coh_src][3]);  

					affdir_1 = aff_reader_chpath (f, affn_1, buffer_path_1);
					status = aff_node_get_complex (f, affdir_1, buffer_1, T_global);
					if(status != 0) {
						printf("%s  %s\n",config_name_1, buffer_path_1);
						fprintf(stderr, " Error from aff_node_get_complex_1, status was %d\n", status);
						exit(105);
					}
					//			  cout<<"I am here"<<endl;

					phase = 2 * M_PI *(source_list[coh_src][0]*(-pi2x-pf1x-pf2x) + source_list[coh_src][1]*(-pi2y-pf1y-pf2y) + source_list[coh_src][2]*(-pi2z-pf1z-pf2z))/Lsize;

					for(int it=0; it<T_global; it++) {
						//   cout<<"I am here"<<endl;
						m_m[Idx(pi2z, pi2y, pi2x, coh_src)+it] = buffer_1[it]*buffer_2[it]*(cos(phase) + sin(phase)*I);
					}
					aff_reader_close(f);
					//			}
				}

			}
		}
	}
	aff_reader_close(g);
	char outfilename[200];
	char key[100];

	cout<<"Reading completed"<<endl;
	for(int pf1x = -1; pf1x <= 1; pf1x++) {
		for(int pf1y = -1; pf1y <= 1; pf1y++) {
			for(int pf1z = -1; pf1z <= 1; pf1z++) {

				sprintf(outfilename, "mxm_mxm_%.4d/mxm_mxm_pi1x%.2dpi1y%.2dpi1z%.2d_pi2x%.2dpi2y%.2dpi2z%.2d_pf1x%.2dpf1y%.2dpf1z%.2d_pf2x%.2dpf2y%.2dpf2z%.2d",nconf,-pi2x-pf1x-pf2x,-pi2y-pf1y-pf2y,-pi2z-pf1z-pf2z,pi2x,pi2y,pi2z,pf1x,pf1y,pf1z,pf2x,pf2y,pf2z);
				ofstream fout(outfilename,ios::out);
				fout<<setprecision(16);
				fout<<scientific;
				for(int coh_src = 0; coh_src<8; coh_src++) {
					sprintf(key, "# /mxm-mxm/sample%.2d/pi2x%.2dpi2y%.2dpi2z%.2d/pf1x%.2dpf1y%.2dpf1z%.2d/pf2x%.2dpf2y%.2dpf2z%.2d/x%.2dy%.2dz%.2dt%.2d",sample,pi2x,pi2y,pi2z,pf1x,pf1y,pf1z,pf2x,pf2y,pf2z,source_list[coh_src][0],source_list[coh_src][1],source_list[coh_src][2],source_list[coh_src][3]);
					fout<<key<<endl;
					for(int it=0; it<T_global; it++) {
						fout<<gc<<"\t\t"<<gc<<"\t\t"<<it<<"\t\t"<<creal(m_m[Idx(pi2z, pi2y, pi2x, coh_src)+it])<<"\t\t"<<cimag(m_m[Idx(pi2z, pi2y, pi2x, coh_src)+it])<<"\t\t"<<nconf<<endl;
					} 

				}
			}
		}
	}





	MPI_Finalize();
}

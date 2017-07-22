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

#define Idx(i,j,k,l) ( 96 * (i + 8*(j  + 7 * (k + 7 * l))))
/*
   Idx macro used to denote the identity of the elements of the m-m single dimensional array, according to the implementation
i: source_location_index(slowest running index)
j: pz
k: py
l: px
m: gi
n: gf
o: configuration number in the array nconf(fastest running index)
 */
using namespace std;


int main(int argc, char **argv)
{
	MPI_Init(& argc, & argv);
	mpi_t mpi;
	setupMpi(mpi);


	int T_global = 96;
	int nconf[44] = {1108, 1116, 1124, 1132, 1140, 1148, 1156, 1164, 1172, 1180, 1188, 1196, 1204, 1212, 1220, 1228, 1236, 1244, 1252, 1260, 1268, 1276, 1284, 1292, 1300, 1308, 1316, 1324, 1332, 1340, 1348, 1356, 1364, 1372, 1380, 1388, 1396, 1404, 1412, 1420, 1428, 1436, 1444, 1452};
	//	int nconf[2] = {1108, 1116, 1124};
	int status;
	int Lsize = 32;
	double phase;
	double _Complex *m_m = NULL;
	m_m = (double _Complex*)malloc(44*49*27*8*2*T_global*sizeof(double));
	int source_list[44][8][4];

	/* Key pattern
	   /m-m/gf15_gi15/px01py01pz01/x18y25z21t62  
	 */

	int px = (mpi.world_rank / 9) - 1;
	int py = ((mpi.world_rank % 9)/3) - 1;
	int pz = (mpi.world_rank % 3) - 1;




	int gc[7] = { 15, 12, 10, 9, 4, 2, 1 };
#pragma omp parallel for private ( phase) shared (m_m)
	for(int iconf = 0; iconf<44;iconf++) {
		char filename[100];     
		sprintf(filename,"src_%.4d",nconf[iconf]);
		char config_name[100];
		sprintf(config_name,"contract_m_m_2pt.%.4d",nconf[iconf]);

		double _Complex *buffer = NULL;
		struct  AffReader_s *f;
		struct AffNode_s *affn = NULL, *affdir=NULL;
		char buffer_path[200];
		f = aff_reader(config_name);
		const char *status_str;
		status_str = aff_reader_errstr(f);
		if (status_str) {
			printf("reader open error: %s\n", status_str);
			aff_reader_close(f);
		}
		buffer = (double _Complex*)malloc(2*T_global*sizeof(double));
		if(buffer== NULL) exit(101);
		ifstream src_loc(filename,ios::in);
		int ch = 0;             
		while(ch!=8) {          
			src_loc>>source_list[iconf][ch][0]>>source_list[iconf][ch][1]>>source_list[iconf][ch][2]>>source_list[iconf][ch][3];
			ch = ch +1;     
		}                       

		for(int gf_num = 0; gf_num <7;++gf_num) {
			for( int gi_num = 0; gi_num <7;++gi_num) {

				for(int i = 0; i < 8;i++) {

					sprintf(buffer_path,"/m-m-cc/gf%.2d_gi%.2d/px%.2dpy%.2dpz%.2d/x%.2dy%.2dz%.2dt%.2d",
							gc[gf_num],gc[gi_num],px,py,pz,source_list[iconf][i][0],source_list[iconf][i][1],source_list[iconf][i][2],source_list[iconf][i][3]);
					//	fprintf(stdout, "#  current key path %s\n", buffer_path);
					affdir = aff_reader_chpath (f, affn, buffer_path);

					status = aff_node_get_complex (f, affdir, buffer, T_global);
					if(status != 0) {
						printf("%s  %s\n",config_name, buffer_path);
						fprintf(stderr, " Error from aff_node_get_complex, status was %d\n", status);
						exit(105);
					}
					phase = (-2) * M_PI *(source_list[iconf][i][0]*px + source_list[iconf][i][1]*py + source_list[iconf][i][2]*pz)/Lsize;

					for(int it=0; it<T_global; it++) {


						m_m[Idx(i,gi_num,gf_num,iconf)+it] = buffer[it]*(cos(phase) + sin(phase)*I);

					}
					if(i==0&&pz==0&&py==0&&px==0&&gi_num==0&&gf_num==0&&iconf==0){
						fprintf(stdout, "#  current key path %s\n", buffer_path);			
						//	cout<<creal(m_m[Idx(0,0,0,0,0,0,0)+0])<<endl;}
					}
				}

			}

		}
		aff_reader_close(f);
	}




	char outfilename[100];
	char key[100];
	for(int gf_write=0;gf_write<7;gf_write++) {
		for(int gi_write=0;gi_write<7;gi_write++) {


			sprintf(outfilename,"m_m_cc/m-m-cc_g%.2d-g%.2d_pix%.2dpiy%.2dpiz%.2d_pfx%.2dpfy%.2dpfz%.2d",gc[gf_write],gc[gi_write],px,py,pz,-px,-py,-pz); 
			ofstream fout(outfilename,ios::out);
			fout<< setprecision(16);
			fout<<scientific;
			for(int iconf = 0; iconf<44;iconf++) { 
				for(int i = 0; i < 8;i++) {
					sprintf(key,"# /m-m-cc/gf%.2d_gi%.2d/px%.2dpy%.2dpz%.2d/x%.2dy%.2dz%.2dt%.2d",gc[gf_write],gc[gi_write],px,py,pz,source_list[iconf][i][0],source_list[iconf][i][1],source_list[iconf][i][2],source_list[iconf][i][3]);
					fout<<key<<endl;
					for(int it=0; it<T_global; it++) {
						fout<<gc[gf_write]<<"\t\t"<<gc[gi_write]<<"\t\t"<<creal(m_m[Idx(i,gi_write,gf_write,iconf) + it])<<"\t\t"<<cimag(m_m[Idx(i,gi_write,gf_write,iconf) + it])<<"\t\t"<<nconf[iconf]<<endl;
					}	
				}
			}
		}
	}


MPI_Finalize();
}

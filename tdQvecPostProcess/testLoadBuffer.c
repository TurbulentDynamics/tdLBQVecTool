//
//  testLoadBuffer.c
//  tdQvecPostProcess
//
//  Created by Nile Ó Broin on 27/06/2019.
//  Copyright © 2019 Turbulent Dynamics. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <vector>
#include <cstdint>


struct tDisk_colrow_Q4_V4 {
    uint16_t col, row;
    float s[4];
};

int main(){
int bin_file_size_in_structs = 309;
std::string qvec_path = "../TinyTestData/plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28/Qvec.node.0.1.1.V4.bin";


tDisk_colrow_Q4_V4 *tmp = (tDisk_colrow_Q4_V4*)malloc(309 * sizeof(tDisk_colrow_Q4_V4));

FILE *fp = fopen(qvec_path.c_str(), "r");
fread(tmp, sizeof(tDisk_colrow_Q4_V4), bin_file_size_in_structs, fp);
fclose(fp);


for (int i=0; i<bin_file_size_in_structs; i++){

    printf("%4i %4i % f % f % f % f\n", tmp[i].col, tmp[i].row, tmp[i].s[0], tmp[i].s[1], tmp[i].s[2], tmp[i].s[3]);

}






}

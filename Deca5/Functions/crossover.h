//
//  xpwntool.h
//  Deca5
//
//  Created by Zane Kleinberg on 7/30/20.
//

#ifndef crossover_h
#define crossover_h

#include <stdio.h>
void decrypt(char *input_path, char *ouput_path, char *ip_key, char *ip_iv, char *decrypt, char *template_path);
int iBootPatcher(char *infile, char *outfile, char *args, char *RSA, char *debug, char *ticket);
int deca5restore(char* ipsw_path, char* iBSS_path, char* iBEC_path, char* devicetree_path, char* ramdisk_path, char* kernel_path, char *logo_path);
int deca5boot(char *iBSS_path, char *iBEC_path, char *devicetree_path, char *ramdisk_path, char *kernel_path, char *bm_path, char *logo_path);
#endif /* xpwntool_h */

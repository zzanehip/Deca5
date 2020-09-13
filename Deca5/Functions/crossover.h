//
//  crossover.h
//  Deca5
//

#ifndef crossover_h
#define crossover_h

#include <stdio.h>
void decrypt(char *input_path, char *ouput_path, char *ip_key, char *ip_iv, char *decrypt, char *template_path);
int iBootPatcher(char *infile, char *outfile, char *args, char *RSA, char *debug, char *ticket, char *kaslr);
int deca5restore(char* ipsw_path, char* iBSS_path, char* iBEC_path, char* devicetree_path, char* ramdisk_path, char* kernel_path, char *logo_path);
int deca5boot(char *iBSS_path, char *iBEC_path, char *devicetree_path, char *ramdisk_path, char *kernel_path, char *bm_path, char *logo_path);
int deca5jailbreak(char *iBSS_path, char *iBEC_path, char *devicetree_path, char *ramdisk_path, char *kernel_path, char *bm_path, char *logo_path);
int patch_kernel(char* infile, char* outfile, char* version);
int lzss_compress(char *infile, char *outfile, char *monitor);
#endif

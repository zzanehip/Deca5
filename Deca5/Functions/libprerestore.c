//
//  libprerestore.c
//  Deca5
//
//

#include "libprerestore.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <getopt.h>
#include <inttypes.h>
#include <libirecovery.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <libfragmentzip/libfragmentzip.h>
#include <math.h>
#include <sys/stat.h>

static irecv_client_t dev = NULL;
irecv_client_t client = NULL;
uint64_t ecid = 0;
irecv_error_t errors = 0;
int progress_cb(irecv_client_t client, const irecv_event_t* event);
void send_progress(double progress);
void send_progress_fz(unsigned int progress);
irecv_device_t device = NULL;


static swift_callbacks callback;
static swift_progress prog;

static const char* mode_to_str(int mode) {
    switch (mode) {
        case IRECV_K_RECOVERY_MODE_1:
        case IRECV_K_RECOVERY_MODE_2:
        case IRECV_K_RECOVERY_MODE_3:
        case IRECV_K_RECOVERY_MODE_4:
            return "Recovery";
            break;
        case IRECV_K_DFU_MODE:
            return "DFU";
            break;
        case IRECV_K_WTF_MODE:
            return "WTF";
            break;
        default:
            return "Unknown";
            break;
    }
}

extern void callback_setup(const swift_callbacks * callbacks) {
    callback = *callbacks;
}

extern void progress_setup(const swift_progress * callbacks) {
    prog = *callbacks;
}

int progress_cb(irecv_client_t client, const irecv_event_t* event) {
    if (event->type == IRECV_PROGRESS) {
        send_progress(event->progress);
    }
    
    return 0;
}


int download_component(const char* url, const char* component, const char* outdir) {
    int ret = 0;
    fragmentzip_t *remote_ipsw = fragmentzip_open(url);
    if (!remote_ipsw) {
        return -1;
    }
    ret = fragmentzip_download_file(remote_ipsw, component, outdir, send_progress_fz);
    fragmentzip_close(remote_ipsw);
    if (ret != 0) {
        return -1;
    }
    return 0;
}

int sendiBSS(char *iBSSpath) {
    int ret;
    size_t legnth;
    FILE* iBSSfile;
    void* buf;
    iBSSfile = fopen(iBSSpath, "rb");
    if(!iBSSfile) {
        printf("Unable to open iBSS %s \n", iBSSpath);
        return -1;
    }
    
    fseek(iBSSfile, 0, SEEK_END);
    legnth = ftell(iBSSfile);
    fseek(iBSSfile, 0, SEEK_SET);
    
    buf = (void*)malloc(legnth);
    fread(buf, 1, legnth, iBSSfile);
    fclose(iBSSfile);
    ret = boot_client(buf, legnth);
    if (ret != 0) {
        return -1;
    }
    sleep(2);
    return 0;
}

int sendiBEC(char *iBECpath) {
    int ret;
    ret = get_dev();
    irecv_devices_get_device_by_client(client, &device);
    printf("Connected to %s, model %s, cpid 0x%04x, bdid 0x%02x\n", device->product_type, device->hardware_model, device->chip_id, device->board_id);
    irecv_event_subscribe(client, IRECV_PROGRESS, &progress_cb, NULL);
    printf("iBEC at: %s \n", iBECpath);
    errors = irecv_send_file(client, iBECpath, 1);
    printf("%s\n", irecv_strerror(errors));
    irecv_close(client);
    sleep(2);
    return 0;
}

int sendDeviceTree(char *DeviceTree_Path) {
    int ret;
    ret = get_dev();
    irecv_devices_get_device_by_client(client, &device);
    printf("Connected to %s, model %s, cpid 0x%04x, bdid 0x%02x\n", device->product_type, device->hardware_model, device->chip_id, device->board_id);
    irecv_event_subscribe(client, IRECV_PROGRESS, &progress_cb, NULL);
    printf("iBEC at: %s \n", DeviceTree_Path);
    errors = irecv_send_file(client, DeviceTree_Path, 1);
    printf("%s\n", irecv_strerror(errors));
    errors = irecv_send_command(client, "devicetree");
    irecv_close(client);
    sleep(2);
    return 0;
}

int sendKernelCache(char *KernelCache_Path) {
    int ret;
    ret = get_dev();
    irecv_devices_get_device_by_client(client, &device);
    printf("Connected to %s, model %s, cpid 0x%04x, bdid 0x%02x\n", device->product_type, device->hardware_model, device->chip_id, device->board_id);
    irecv_event_subscribe(client, IRECV_PROGRESS, &progress_cb, NULL);
    printf("KernelCache at: %s \n", KernelCache_Path);
    errors = irecv_send_file(client, KernelCache_Path, 1);
    printf("%s\n", irecv_strerror(errors));
    errors = irecv_send_command(client, "bootx");
    irecv_close(client);
    sleep(2);
    return 0;
}

int get_dev() {
    int i = 0;
    for (i = 0; i <= 5; i++) {
        printf("Attempting to connect... \n");
        irecv_error_t err = irecv_open_with_ecid(&client, ecid);
        if (err == IRECV_E_UNSUPPORTED) {
            fprintf(stderr, "ERROR: %s\n", irecv_strerror(err));
            return -1;
        }
        else if (err != IRECV_E_SUCCESS)
            sleep(1);
        else
            break;
        
        if (i == 5) {
            int size = snprintf(NULL, 0, "ERROR: %s", irecv_strerror(err));
            char * a = malloc(size + 1);
            sprintf(a, "ERROR: %s", irecv_strerror(err));
            callback.send_output_to_swift(a);
            fprintf(stderr, "ERROR: %s\n", irecv_strerror(err));
            return -1;
        }
    }
    return 0;
}

char * send_ecid() {
    const struct irecv_device_info* info = irecv_get_device_info(client);
    int size = snprintf(NULL, 0, "%llu",info->ecid);
    char * a = malloc(size + 1);
    sprintf(a, "%llu",info->ecid);
    return a;
}

char * send_state() {
    int mode;
    const struct irecv_device_info* info = irecv_get_mode(client, &mode);
    int size = snprintf(NULL, 0, "%s", mode_to_str(mode));
    char * a = malloc(size + 1);
    sprintf(a, "%s", mode_to_str(mode));
    return a;
}



static int read_file_into_buffer(char* path, char** buf, size_t* len) {
    FILE* f = fopen(path, "rb");
    if(!f) {
        return -1;
    }
    fseek(f, 0, SEEK_END);
    *len = ftell(f);
    fseek(f, 0, SEEK_SET);
    if(!*len) {
        return -1;
    }

    *buf = malloc(*len);
    if(!*buf) {
        return -1;
    }
    fread(*buf, 1, *len, f);
    fclose(f);
    return 0;
}

///



void send_progress(double progress) {
    if(progress < 0) {
        return;
    }
    if(progress > 100) {
        progress = 100;
    }
    prog.send_output_progress_to_swift(progress);
}


void send_progress_fz(unsigned int progress) {
    if(progress < 0) {
        return;
    }
    if(progress > 100) {
        progress = 100;
    }
    prog.send_output_progress_to_swift((double)progress);
}


void send_text(char *text) {
    int size = snprintf(NULL, 0, "%s", text);
    char * a = malloc(size + 1);
    sprintf(a, "%s", text);
    callback.send_output_to_swift(a);
}



//** Thank You @dora2 for this below! **//

#define AES_DECRYPT_IOS 0x11
#define AES_GID_KEY     0x20000200
#define IMG3_HEADER     0x496d6733
#define ARMv7_VECTOR    0xEA00000E
#define IMG3_ILLB       0x696c6c62
#define IMG3_IBSS       0x69627373
#define IMG3_DATA       0x44415441
#define IMG3_KBAG       0x4B424147
#define EXEC            0x65786563
#define MEMC            0x6D656D63

int check_img3_file_format(irecv_client_t client, void* file, size_t sz, void** out, size_t* outsz);
int send_data(irecv_client_t client, unsigned char* data, size_t size);

typedef struct img3Tag {
    uint32_t magic;            // see below
    uint32_t totalLength;      // length of tag including "magic" and these two length values
    uint32_t dataLength;       // length of tag data
    // ...
} Img3RootHeader;

typedef struct Unparsed_KBAG_256 {
    uint32_t magic;       // string with bytes flipped ("KBAG" in little endian)
    uint32_t fullSize;    // size of KBAG from beyond that point to the end of it
    uint32_t tagDataSize; // size of KBAG without this 0xC header
    uint32_t cryptState;  // 1 if the key and IV in the KBAG are encrypted with the GID Key
    // 2 is used with a second KBAG for the S5L8920, use is unknown.
    uint32_t aesType;     // 0x80 = aes128 / 0xc0 = aes192 / 0x100 = aes256
    uint8_t encIV_start;    // IV for the firmware file, encrypted with the GID Key
    // ...   // Key for the firmware file, encrypted with the GID Key
} UnparsedKbagAes256_t;

typedef struct img3File {
    uint32_t magic;       // ASCII_LE("Img3")
    uint32_t fullSize;    // full size of fw image
    uint32_t sizeNoPack;  // size of fw image without header
    uint32_t sigCheckArea;// although that is just my name for it, this is the
    // size of the start of the data section (the code) up to
    // the start of the RSA signature (SHSH section)
    uint32_t ident;       // identifier of image, used when bootrom is parsing images
    // list to find LLB (illb), LLB parsing it to find iBoot (ibot),
    // etc.
    struct img3Tag  tags[];      // continues until end of file
} Img3Header;

int send_data(irecv_client_t client, unsigned char* data, size_t size){
    return irecv_usb_control_transfer(client, 0x21, 1, 0, 0, data, size, 100);
}

int boot_client(void* buf, size_t sz) {
    int ret;
    if(!client) {
        ret = get_dev();
        if(ret != 0) {
            printf("No device found.");
            return -1;
        }
    }
    
    const struct irecv_device_info* info = irecv_get_device_info(client);
    char* pwnd_str = strstr(info->serial_string, "PWND:[");
    if(!pwnd_str) {
        irecv_close(client);
        printf("Device not in pwned DFU mode.\n");
        return -1;
    }
    
    void* ibss;
    size_t ibss_sz;
    unsigned char blank[16];
    bzero(blank, 16);
    
    ret = check_img3_file_format(client, buf, sz, &ibss, &ibss_sz);
    
    if (ret != 0){
        printf("Failed to make soft DFU.\n");
        irecv_close(client);
        return -1;
    }
    send_data(client, blank, 16);
    irecv_usb_control_transfer(client, 0x21, 1, 0, 0, NULL, 0, 100);
    irecv_usb_control_transfer(client, 0xA1, 3, 0, 0, blank, 6, 100);
    irecv_usb_control_transfer(client, 0xA1, 3, 0, 0, blank, 6, 100);
    
    printf("\x1b[36mUploading soft DFU\x1b[39m\n");
    size_t len = 0;
    while(len < ibss_sz) {
        size_t size = ((ibss_sz - len) > 0x800) ? 0x800 : (ibss_sz - len);
        size_t sent = irecv_usb_control_transfer(client, 0x21, 1, 0, 0, (unsigned char*)&ibss[len], size, 1000);
        if(sent != size) {
            printf("Failed to upload iBSS.\n");
            return -1;
        }
        len += size;
        double converted_len = (double)len;
        double converted_ibss_size = (double)ibss_sz;
        double s_prog = (double)converted_len/converted_ibss_size;
        send_progress((double)s_prog*100);
    }
    
    irecv_usb_control_transfer(client, 0xA1, 2, 0xFFFF, 0, buf, 0, 100);
    
    //irecv_close(client);
    return 0;
}

int check_img3_file_format(irecv_client_t client, void* file, size_t sz, void** out, size_t* outsz){
    uint32_t Img3header_magic = *(uint32_t*)(file + offsetof(struct img3File, magic));
    switch(Img3header_magic) {
        case ARMv7_VECTOR:
            // Do nothing
            printf("\x1b[36mDecrypted Img3 image\x1b[39m\n");
            *out = malloc(sz);
            *outsz = sz;
            memcpy(*out, file, *outsz);
            return 0;
            break;
            
        case IMG3_HEADER:
            printf("\x1b[36mPacked Img3 image\x1b[39m\n");
            uint32_t ibss_data_start;
            uint32_t tag_header = 0;
            int isKBAG = 0;
            uint8_t IV[16];
            uint8_t Key[32];
            
            uint32_t img3_ident = *(uint32_t*)(file + offsetof(struct img3File, ident));
            //printf("Ident : 0x%08x\n", img3_ident);
            if (img3_ident == IMG3_ILLB || img3_ident == IMG3_IBSS){
                printf("\x1b[35mDetect iBSS/LLB image\x1b[39m\n");
            } else {
                printf("Invalid image\n");
                return -1;
            }
            
            uint32_t img3_fullSize = *(uint32_t*)(file + offsetof(struct img3File, fullSize));
            uint32_t img3_sizeNoPack = *(uint32_t*)(file + offsetof(struct img3File, sizeNoPack));
            
            uint32_t next = img3_fullSize - img3_sizeNoPack; //0x14
            
            for(uint32_t next_tag = next; next_tag < img3_fullSize;){
                uint32_t img3_tag_magic = *(uint32_t*)(file + next_tag + offsetof(struct img3Tag, magic));
                //printf("tag magic: 0x%08x\n", img3_tag_magic);
                uint32_t img3_tag_totalLength = *(uint32_t*)(file + next_tag + offsetof(struct img3Tag, totalLength));
                //printf("tag totalLength: 0x%08x\n", img3_tag_totalLength);
                uint32_t img3_tag_dataLength = *(uint32_t*)(file + next_tag + offsetof(struct img3Tag, dataLength));
                //printf("tag dataLength: 0x%08x\n", img3_tag_dataLength);
                
                if(img3_tag_magic == IMG3_DATA) {
                    tag_header = img3_tag_magic;
                    *outsz = img3_tag_dataLength;
                    ibss_data_start = next_tag + offsetof(struct img3Tag, dataLength) + 4;
                }
                
                if(img3_tag_magic == IMG3_KBAG) {
                    if(*(uint32_t*)(file + next_tag + offsetof(struct Unparsed_KBAG_256, cryptState)) == 1){
                        isKBAG = 1;
                        uint32_t tagDataSize = *(uint32_t*)(file + next_tag + offsetof(struct Unparsed_KBAG_256, tagDataSize));
                        //printf("tagDataSize: 0x%08x\n", tagDataSize);
                        for(int i = 0; i < 16; i++){
                            IV[i] = *(uint8_t*)(file + next_tag + offsetof(struct Unparsed_KBAG_256, encIV_start)+i);
                        }
                        for(int i = 0; i < 32; i++){
                            Key[i] = *(uint8_t*)(file + next_tag + offsetof(struct Unparsed_KBAG_256, encIV_start)+16+i);
                        }
                    }
                }
                
                next_tag += img3_tag_totalLength;
            }
            
            if(tag_header != IMG3_DATA) {
                printf("Invalid image\n");
                return -1;
            }
            
            *out = malloc(*outsz);
            memcpy(*out, file+ibss_data_start, *outsz);
            
            uint32_t out_magic = *(uint32_t*)(*out + offsetof(struct img3File, magic));
            //printf("out magic: 0x%08x\n", out_magic);
            return 0;
            break;
            
        default:
            printf("Invalid image\n");
            return -1;
            break;
    }
    
    printf("Invalid image\n");
    return -1;
}

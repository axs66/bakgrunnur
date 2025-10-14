#import <dlfcn.h>

__attribute__((constructor)) static void loadAltListAtStartup(void){
    const char *candidates[] = {
        "/var/jb/Library/PreferenceBundles/AltList.bundle/AltList",
        "/Library/PreferenceBundles/AltList.bundle/AltList",
        "/private/preboot/procursus/Library/PreferenceBundles/AltList.bundle/AltList"
    };
    for (unsigned i = 0; i < sizeof(candidates)/sizeof(candidates[0]); i++){
        void *h = dlopen(candidates[i], RTLD_NOW | RTLD_GLOBAL);
        if (h) break;
    }
}



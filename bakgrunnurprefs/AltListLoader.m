#import <dlfcn.h>

__attribute__((constructor)) static void loadAltListAtStartup(void){
    const char *candidates[] = {
        // Rootless framework paths (most common)
        "/var/jb/Library/Frameworks/AltList.framework/AltList",
        "/var/jb/System/Library/Frameworks/AltList.framework/AltList",
        // Rootful framework paths
        "/Library/Frameworks/AltList.framework/AltList",
        "/System/Library/Frameworks/AltList.framework/AltList",
        // Rootless bundle paths
        "/var/jb/Library/PreferenceBundles/AltList.bundle/AltList",
        // Rootful bundle paths
        "/Library/PreferenceBundles/AltList.bundle/AltList",
        // Dopamine specific paths
        "/private/preboot/procursus/Library/Frameworks/AltList.framework/AltList",
        "/private/preboot/procursus/Library/PreferenceBundles/AltList.bundle/AltList"
    };
    for (unsigned i = 0; i < sizeof(candidates)/sizeof(candidates[0]); i++){
        void *h = dlopen(candidates[i], RTLD_NOW | RTLD_GLOBAL);
        if (h) break;
    }
}



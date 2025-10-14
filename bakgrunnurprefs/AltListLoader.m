#import <dlfcn.h>

// Load AltList bundle to make ATLApplicationListSubcontrollerController available
__attribute__((constructor)) static void loadAltListBundle(void) {
    // Try different possible paths for AltList bundle
    const char *paths[] = {
        "/var/jb/Library/PreferenceBundles/AltList.bundle/AltList",
        "/Library/PreferenceBundles/AltList.bundle/AltList",
        "/private/preboot/procursus/Library/PreferenceBundles/AltList.bundle/AltList"
    };
    
    for (int i = 0; i < sizeof(paths)/sizeof(paths[0]); i++) {
        void *handle = dlopen(paths[i], RTLD_NOW | RTLD_GLOBAL);
        if (handle) {
            // Successfully loaded AltList bundle
            break;
        }
    }
}

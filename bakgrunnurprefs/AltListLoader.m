#import <dlfcn.h>

// Ensure AltList's preference bundle is loaded so ATLApplicationListSubcontrollerController exists
__attribute__((constructor)) static void loadAltListBundleIfAvailable(void) {
    const char *candidatePaths[] = {
        // Rootless common path (palera1n/ Dopamine symlinked /var/jb)
        "/var/jb/Library/PreferenceBundles/AltList.bundle/AltList",
        // Rootful path
        "/Library/PreferenceBundles/AltList.bundle/AltList"
        // If your environment differs, system symlinks typically resolve one of the above
    };

    for (unsigned i = 0; i < sizeof(candidatePaths)/sizeof(candidatePaths[0]); i++) {
        void *handle = dlopen(candidatePaths[i], RTLD_NOW);
        if (handle) {
            // Loaded successfully; no further action needed
            break;
        }
    }
}



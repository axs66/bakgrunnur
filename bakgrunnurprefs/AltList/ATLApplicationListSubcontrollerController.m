#import <Preferences/PSListController.h>
#import "ATLApplicationListSubcontrollerController.h"
#import <HBLog.h>

@implementation ATLApplicationListSubcontrollerController

- (void)loadPreferences{
    // Try to load AltList framework dynamically
    NSBundle *altListBundle = [NSBundle bundleWithPath:@"/var/jb/Library/Frameworks/AltList.framework"];
    if (altListBundle && [altListBundle load]) {
        // AltList is available, try to call the real implementation
        Class altListClass = NSClassFromString(@"ATLApplicationListSubcontrollerController");
        if (altListClass && [altListClass instancesRespondToSelector:@selector(loadPreferences)]) {
            [super loadPreferences];
        }
    } else {
        HBLogDebug(@"AltList.framework not found, using stub implementation");
    }
}

- (PSSpecifier *)specifierForApplicationWithIdentifier:(NSString *)identifier{
    // Try to load AltList framework dynamically
    NSBundle *altListBundle = [NSBundle bundleWithPath:@"/var/jb/Library/Frameworks/AltList.framework"];
    if (altListBundle && [altListBundle load]) {
        // AltList is available, try to call the real implementation
        Class altListClass = NSClassFromString(@"ATLApplicationListSubcontrollerController");
        if (altListClass && [altListClass instancesRespondToSelector:@selector(specifierForApplicationWithIdentifier:)]) {
            return [super specifierForApplicationWithIdentifier:identifier];
        }
    }
    
    // Fallback implementation
    HBLogDebug(@"AltList.framework not available, returning nil for identifier: %@", identifier);
    return nil;
}

@end



#import <Preferences/PSListController.h>
#import "ATLApplicationListSubcontrollerController.h"

@implementation ATLApplicationListSubcontrollerController

- (void)loadPreferences{
    // No-op stub to satisfy runtime when AltList is not installed
}

- (PSSpecifier *)specifierForApplicationWithIdentifier:(NSString *)identifier{
    // Minimal stub; real AltList provides full implementation
    return nil;
}

@end



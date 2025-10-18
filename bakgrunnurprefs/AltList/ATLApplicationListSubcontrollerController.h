#import <Preferences/PSListController.h>

@interface ATLApplicationListSubcontrollerController : PSListController
- (void)loadPreferences;
- (PSSpecifier *)specifierForApplicationWithIdentifier:(NSString *)identifier;
@end

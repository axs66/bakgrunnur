#import "../common.h"
#import <Preferences/PSListController.h>

@interface BKGPApplicationListSubcontrollerController : PSListController {
    NSMutableDictionary *_prefs;
    NSArray *_allEntriesIdentifier;
    NSArray *_specifiers;
}
-(void)updateIvars;
-(void)loadPreferences;
@end

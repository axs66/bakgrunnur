#import "../common.h"
#import <Preferences/PSListController.h>

@interface BKGPApplicationListSubcontrollerController : PSListController {
    NSMutableDictionary *_prefs;
    NSArray *_allEntriesIdentifier;
}
-(void)updateIvars;
-(void)loadPreferences;
@end

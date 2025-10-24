#import "../common.h"
#import <Preferences/PSListController.h>

// Forward declaration to avoid compile-time dependency on AltList
@class ATLApplicationListSubcontrollerController;

@interface BKGPApplicationListSubcontrollerController : PSListController {
    NSMutableDictionary *_prefs;
    NSArray *_allEntriesIdentifier;
    id _altListController;
}
-(void)updateIvars;
-(void)loadPreferences;
@end

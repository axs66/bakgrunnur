#import "../common.h"

// Forward declaration to avoid compile-time dependency on AltList
@class ATLApplicationListSubcontrollerController;

@interface BKGPApplicationListSubcontrollerController : NSObject {
    NSMutableDictionary *_prefs;
    NSArray *_allEntriesIdentifier;
}
-(void)updateIvars;
-(void)loadPreferences;
-(void)createBasicAppList;
-(id)specifierForApplicationWithIdentifier:(NSString *)identifier;
-(void)reloadSpecifier:(id)specifier animated:(BOOL)animated;
-(void)reloadSpecifiers;
@end

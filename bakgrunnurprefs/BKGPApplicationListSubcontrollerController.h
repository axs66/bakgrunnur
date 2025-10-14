#import "../common.h"

#if __has_include(<AltList/ATLApplicationListSubcontrollerController.h>)
#import <AltList/ATLApplicationListSubcontrollerController.h>
#else
#import <Preferences/PSListController.h>
@interface ATLApplicationListSubcontrollerController : PSListController
@end
#endif

@interface BKGPApplicationListSubcontrollerController : ATLApplicationListSubcontrollerController{
    NSMutableDictionary *_prefs;
    NSArray *_allEntriesIdentifier;
}
-(void)updateIvars;
@end

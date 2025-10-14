#import "../common.h"

#if __has_include(<AltList/ATLApplicationListSubcontrollerController.h>)
#import <AltList/ATLApplicationListSubcontrollerController.h>
#else
#import "AltList/ATLApplicationListSubcontrollerController.h"
#endif

@interface BKGPApplicationListSubcontrollerController : ATLApplicationListSubcontrollerController{
    NSMutableDictionary *_prefs;
    NSArray *_allEntriesIdentifier;
}
-(void)updateIvars;
@end

#import "ControlCenterUIKit.h"
#import "BKGCCModuleContentViewController.h"

@interface CCUIModuleInstanceManager (CCSupport)
- (CCUIModuleInstance*)instanceForModuleIdentifier:(NSString*)moduleIdentifier;
@end

@interface BKGCCToggleModule : CCUIToggleModule{
    BOOL _selected;
	BOOL _shouldSetValue;
	BKGCCModuleContentViewController* _contentViewController;
}
@property (nonatomic, assign) BOOL expandOnTap;
-(void)updateState;
-(void)updateStateViaPreferences;
@end

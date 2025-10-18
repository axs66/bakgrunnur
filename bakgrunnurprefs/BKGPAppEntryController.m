#import "../common.h"
#import "../BKGShared.h"
#import "BKGPAppEntryController.h"
#import "BKGPApplicationListSubcontrollerController.h"
#import "NSString+Regex.h"

@implementation BKGPAppEntryController

static void refreshSpecifiers() {
	[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SPECIFIERS_LOCAL_NOTIFICATION_NAME object:nil];
}

- (instancetype)init{
	if ((self = [super init])) {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)refreshSpecifiers, (CFStringRef)RELOAD_SPECIFIERS_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSpecifiers:) name:RELOAD_SPECIFIERS_LOCAL_NOTIFICATION_NAME object:nil];
	}
	return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	if ((self = [super init])) {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)refreshSpecifiers, (CFStringRef)RELOAD_SPECIFIERS_NOTIFICATION_NAME, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSpecifiers:) name:RELOAD_SPECIFIERS_LOCAL_NOTIFICATION_NAME object:nil];
	}
	return self;
}

- (void)refreshSpecifiers:(NSNotification *)notification{
	[self reloadSpecifiers];
}

- (NSArray *)specifiers {
    NSLog(@"[BKGPAppEntryController] specifiers method called");
    if (!_specifiers) {
        NSLog(@"[BKGPAppEntryController] Creating new specifiers");
        
        // Extract identifier and app name from specifier
        if (self.specifier && self.specifier.identifier) {
            self.identifier = self.specifier.identifier;
            self.appName = [self.specifier propertyForKey:@"label"] ?: self.specifier.identifier;
            NSLog(@"[BKGPAppEntryController] App: %@ (%@)", self.appName, self.identifier);
        } else {
            self.identifier = @"unknown";
            self.appName = @"Unknown App";
            NSLog(@"[BKGPAppEntryController] No specifier found, using defaults");
        }
        
        _expanded = NO;
        _manuallyExpanded = NO;
        
        NSMutableArray *appEntrySpecifiers = [NSMutableArray array];
        
        _staticSpecifiers = [NSMutableArray array];
		_cpuThrottleWarningSpecifiers = [NSMutableArray array];

        //Enabled
		_enabledEntrySpecifier = [PSSpecifier preferenceSpecifierNamed:@"启用" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [_enabledEntrySpecifier setProperty:@"启用" forKey:@"label"];
        [_enabledEntrySpecifier setProperty:@"enabled" forKey:@"key"];
        [_enabledEntrySpecifier setProperty:@NO forKey:@"default"];
        [_enabledEntrySpecifier setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [_enabledEntrySpecifier setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [_staticSpecifiers addObject:_enabledEntrySpecifier];
        
        
        _expandableSpecifiers = [NSMutableArray array];
        
        //Enabled notification
        PSSpecifier *enabledAppNotificationsGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [enabledAppNotificationsGroupSpec setProperty:[NSString stringWithFormat:@"允许 %@ 在被 Bakgrunnur 后台管理时继续发送通知。", self.appName] forKey:@"footerText"];
        [_expandableSpecifiers addObject:enabledAppNotificationsGroupSpec];
        
        PSSpecifier *enabledAppNotificationsSpec = [PSSpecifier preferenceSpecifierNamed:@"通知 (测试版)" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [enabledAppNotificationsSpec setProperty:@"通知 (测试版)" forKey:@"label"];
        [enabledAppNotificationsSpec setProperty:@"enabledAppNotifications" forKey:@"key"];
        [enabledAppNotificationsSpec setProperty:@NO forKey:@"default"];
        [enabledAppNotificationsSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [enabledAppNotificationsSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [_expandableSpecifiers addObject:enabledAppNotificationsSpec];
        
        //Persistence once
        PSSpecifier *persistenceOnceGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [persistenceOnceGroupSpec setProperty:[NSString stringWithFormat:@"保持 %@ 的\"启用一次\"令牌存活，除非通过应用切换器强制终止。当此设置被禁用时，每当 %@ 重新激活时令牌将被撤销。", self.appName, self.appName] forKey:@"footerText"];
        [_expandableSpecifiers addObject:persistenceOnceGroupSpec];
        
        PSSpecifier *persistenceOnceSpec = [PSSpecifier preferenceSpecifierNamed:@"持久化一次令牌" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [persistenceOnceSpec setProperty:@"持久化一次令牌" forKey:@"label"];
        [persistenceOnceSpec setProperty:@"persistenceOnce" forKey:@"key"];
        [persistenceOnceSpec setProperty:@NO forKey:@"default"];
        [persistenceOnceSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [persistenceOnceSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [_expandableSpecifiers addObject:persistenceOnceSpec];
        
        //Dark wake
        PSSpecifier *darkWakeGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [darkWakeGroupSpec setProperty:[NSString stringWithFormat:@"允许 %@ 在锁定时将设备置于半睡眠状态而不是完全睡眠。在此状态下，CPU、网络和磁盘读写将以全容量运行。当应用需要完整的网络/磁盘速度进行后台操作（文件下载、SSH等）时很有用。默认情况下，系统在锁定时会限制/禁用这些功能。", self.appName] forKey:@"footerText"];
        [_expandableSpecifiers addObject:darkWakeGroupSpec];
        
        PSSpecifier *darkWakeSpec = [PSSpecifier preferenceSpecifierNamed:@"半睡眠" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [darkWakeSpec setProperty:@"半睡眠" forKey:@"label"];
        [darkWakeSpec setProperty:@"darkWake" forKey:@"key"];
        [darkWakeSpec setProperty:@NO forKey:@"default"];
        [darkWakeSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [darkWakeSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [_expandableSpecifiers addObject:darkWakeSpec];
        
        //aggressive assertion
        PSSpecifier *aggressiveAssertionGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [aggressiveAssertionGroupSpec setProperty:[NSString stringWithFormat:@"积极地将 %@ 置于后台模式。启用此选项将防止 %@ 的UI被限制，并尝试使用所需的尽可能多的资源。", self.appName, self.appName] forKey:@"footerText"];
        [_expandableSpecifiers addObject:aggressiveAssertionGroupSpec];
        
        PSSpecifier *aggressiveAssertionSpec = [PSSpecifier preferenceSpecifierNamed:@"积极模式" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [aggressiveAssertionSpec setProperty:@"积极模式" forKey:@"label"];
        [aggressiveAssertionSpec setProperty:@"aggressiveAssertion" forKey:@"key"];
        [aggressiveAssertionSpec setProperty:@YES forKey:@"default"];
        [aggressiveAssertionSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [aggressiveAssertionSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [_expandableSpecifiers addObject:aggressiveAssertionSpec];
        
		//throttle cpu
		PSSpecifier *cpuThrottleGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
		[cpuThrottleGroupSpec setProperty:[NSString stringWithFormat:@"在后台运行时限制 %@ 的CPU使用率。如果启用，上面的\"积极模式\"选项可能会被降级。默认为80%%。", self.appName] forKey:@"footerText"];
		[_expandableSpecifiers addObject:cpuThrottleGroupSpec];
		
		PSSpecifier *cpuThrottleSpecifier = [PSSpecifier preferenceSpecifierNamed:@"CPU限制" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[cpuThrottleSpecifier setProperty:@"CPU限制" forKey:@"label"];
		[cpuThrottleSpecifier setProperty:@"cpuThrottleEnabled" forKey:@"key"];
		[cpuThrottleSpecifier setProperty:@NO forKey:@"default"];
		[cpuThrottleSpecifier setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
		[cpuThrottleSpecifier setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
		[_expandableSpecifiers addObject:cpuThrottleSpecifier];
		
		_cpuThrottlePercentageSpecifier = [PSTextFieldSpecifier preferenceSpecifierNamed:@"百分比" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSEditTextCell edit:nil];
		[_cpuThrottlePercentageSpecifier setKeyboardType:UIKeyboardTypeNumberPad autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];
		[_cpuThrottlePercentageSpecifier setPlaceholder:@"80"];
		[_cpuThrottlePercentageSpecifier setProperty:@"throttlePercentage" forKey:@"key"];
		[_cpuThrottlePercentageSpecifier setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
		[_cpuThrottlePercentageSpecifier setProperty:@"百分比" forKey:@"label"];
		[_cpuThrottlePercentageSpecifier setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
		[_expandableSpecifiers addObject:_cpuThrottlePercentageSpecifier];
		
		//throttle cpu warning
		_cpuThrottleWarningGroupSpecifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
		[_cpuThrottleWarningGroupSpecifier setProperty:@"" forKey:@"footerText"];
		[_cpuThrottleWarningSpecifiers addObject:_cpuThrottleWarningGroupSpecifier];
		
        //expiration
        PSSpecifier *expirationGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [expirationGroupSpec setProperty:@"设置应用被挂起/终止的过期时间（秒）。当应用进入后台或设备锁定时，倒计时将开始。每当应用重新进入前台或激活时，倒计时将被重置。默认为3小时。" forKey:@"footerText"];
        [_expandableSpecifiers addObject:expirationGroupSpec];
        
        
        _expirationSpecifier = [PSTextFieldSpecifier preferenceSpecifierNamed:@"过期时间" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSEditTextCell edit:nil];
        [_expirationSpecifier setKeyboardType:UIKeyboardTypeNumberPad autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];
        [_expirationSpecifier setPlaceholder:@"10800"];
        [_expirationSpecifier setProperty:@"expiration" forKey:@"key"];
        [_expirationSpecifier setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [_expirationSpecifier setProperty:@"过期时间" forKey:@"label"];
        [_expirationSpecifier setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [_expandableSpecifiers addObject:_expirationSpecifier];
        
        //retire type
        PSSpecifier *retireSelectionGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [retireSelectionGroupSpec setProperty:@"\U0001F539挂起：系统将被通知优雅地暂停应用。\n\U0001F539终止：应用一旦过期将立即被终止。\n\U0001F539永生：应用将无限期保持活跃，除非被用户强制终止或重启后。\n\U0001F539高级：应用将根据首选的高级设置（CPU、系统调用和网络）在指定时间跨度内被挂起。" forKey:@"footerText"];
        [_expandableSpecifiers addObject:retireSelectionGroupSpec];
        
        PSSpecifier *retireSelectionSpec = [PSSpecifier preferenceSpecifierNamed:@"挂起方式" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSegmentCell edit:nil];
        [retireSelectionSpec setValues:@[@(BKGBackgroundTypeRetire), @(BKGBackgroundTypeTerminate), @(BKGBackgroundTypeImmortal), @(BKGBackgroundTypeAdvanced)] titles:@[@"挂起", @"终止", @"永生", @"高级"]];
        [retireSelectionSpec setProperty:@(BKGBackgroundTypeRetire) forKey:@"default"];
        [retireSelectionSpec setProperty:@"retire" forKey:@"key"];
        [retireSelectionSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [retireSelectionSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [_expandableSpecifiers addObject:retireSelectionSpec];
		
        //Advanced
        PSSpecifier *advancedGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [advancedGroupSpec setProperty:[NSString stringWithFormat:@"时间跨度是一个全局值，这意味着它适用于此类别中所有启用的应用，以愉快地管理功耗。默认为30分钟。在时间跨度内将执行两次定期检查。"] forKey:@"footerText"];
        [_expandableSpecifiers addObject:advancedGroupSpec];
        
        //time span
        _timeSpanSpecifier = [PSTextFieldSpecifier preferenceSpecifierNamed:@"时间跨度" target:self set:@selector(setGlobalPreferenceValue:specifier:) get:@selector(readGlobalPreferenceValue:) detail:nil cell:PSEditTextCell edit:nil];
        [_timeSpanSpecifier setKeyboardType:UIKeyboardTypeNumberPad autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];
        [_timeSpanSpecifier setPlaceholder:@"1800"];
        [_timeSpanSpecifier setProperty:@"timeSpan" forKey:@"key"];
        [_timeSpanSpecifier setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [_timeSpanSpecifier setProperty:@"时间跨度" forKey:@"label"];
        [_timeSpanSpecifier setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [_expandableSpecifiers addObject:_timeSpanSpecifier];
        
        //blank
        PSSpecifier *blankSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [_expandableSpecifiers addObject:blankSpecGroup];
        
        //CPU Controller
        _cpuControllerSpecifier = [PSSpecifier preferenceSpecifierNamed:@"CPU" target:nil set:nil get:nil detail:NSClassFromString(@"BKGPAppCPUController") cell:PSLinkCell edit:nil];
        [_cpuControllerSpecifier setProperty:[NSString stringWithFormat:@"%@-bakgrunnur-app-cpu-[%@]", self.identifier, self.appName] forKey:@"id"];
        [_expandableSpecifiers addObject:_cpuControllerSpecifier];
        
        //System Calls Controller
        _systemCallsControllerSpecifier = [PSSpecifier preferenceSpecifierNamed:@"系统调用" target:nil set:nil get:nil detail:NSClassFromString(@"BKGPAppSystemCallsController") cell:PSLinkCell edit:nil];
        [_systemCallsControllerSpecifier setProperty:[NSString stringWithFormat:@"%@-bakgrunnur-app-systemcalls-[%@]", self.identifier, self.appName] forKey:@"id"];
        [_expandableSpecifiers addObject:_systemCallsControllerSpecifier];
        
        //Network Controller
        _networkControllerSpecifier = [PSSpecifier preferenceSpecifierNamed:@"网络" target:nil set:nil get:nil detail:NSClassFromString(@"BKGPAppNetworkController") cell:PSLinkCell edit:nil];
        [_networkControllerSpecifier setProperty:[NSString stringWithFormat:@"%@-bakgrunnur-app-network-[%@]", self.identifier, self.appName] forKey:@"id"];
        [_expandableSpecifiers addObject:_networkControllerSpecifier];
        
        
        [appEntrySpecifiers addObjectsFromArray:_staticSpecifiers];
        
        // Always show all options, not just when enabled
        [appEntrySpecifiers addObjectsFromArray:_expandableSpecifiers];
        _expanded = YES;
        
        _specifiers = appEntrySpecifiers;
        NSLog(@"[BKGPAppEntryController] Created %lu specifiers", (unsigned long)[_specifiers count]);
    }
    
    NSLog(@"[BKGPAppEntryController] Returning %lu specifiers", (unsigned long)[_specifiers count]);
    return _specifiers;
}

-(BOOL)shouldShowCPUThrottleWarning:(double *)throttle threshold:(double *)threshold{
	
	if (_cpuThrottleWarningShown) return NO;
	
	double throttlePercentage = [valueForConfigKey(self.identifier, @"throttlePercentage", @50) doubleValue];
	double cpuUsageThreshold = [valueForConfigKey(self.identifier, @"cpuUsageThreshold", @(0.5)) doubleValue];
	BOOL cpuThrottleEnabled = [valueForConfigKey(self.identifier, @"cpuThrottleEnabled", @NO) boolValue];
	BOOL cpuUsageEnabled = [valueForConfigKey(self.identifier, @"cpuUsageEnabled", @NO) boolValue];
	BKGBackgroundType type = [valueForConfigKey(self.identifier, @"retire", @(BKGBackgroundTypeRetire)) unsignedLongValue];
	
	if (type != BKGBackgroundTypeAdvanced) return NO;
	
	if (throttle) *throttle = throttlePercentage;
	if (threshold) *threshold = cpuUsageThreshold;
	return cpuThrottleEnabled && cpuUsageEnabled && throttlePercentage < cpuUsageThreshold;
}

-(void)showCPUThrottleWarningIfNecessary{
	double throttlePercentage = -1.0;
	double cpuUsageThreshold = -1.0;
	if ([self shouldShowCPUThrottleWarning:&throttlePercentage threshold:&cpuUsageThreshold]){
		[_cpuThrottleWarningGroupSpecifier setProperty:[NSString stringWithFormat:@"⚠️WARNING: Throttle percentage (%d%%) is lower than CPU threshold (%.2f%%) set in \"Advanced\" mode, you may have unresolved conflicts.", (int)throttlePercentage, cpuUsageThreshold] forKey:@"footerText"];
		[self reloadSpecifier:_cpuThrottlePercentageSpecifier animated:YES];
		[self insertContiguousSpecifiers:_cpuThrottleWarningSpecifiers afterSpecifier:_cpuThrottlePercentageSpecifier animated:YES];
		_cpuThrottleWarningShown = YES;
	}else{
		[self removeContiguousSpecifiers:_cpuThrottleWarningSpecifiers animated:YES];
		_cpuThrottleWarningShown = NO;
	}
}

- (id)readGlobalPreferenceValue:(PSSpecifier*)specifier {
    return valueForKey(specifier.properties[@"key"], specifier.properties[@"default"]);
}

- (void)setGlobalPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    setValueForKey([specifier propertyForKey:@"key"], value);
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    id value = valueForConfigKey(self.identifier, key, specifier.properties[@"default"]);
    return value;
}

-(void)updateParentViewController{
    UIViewController *parentController = (UIViewController *)[self valueForKey:@"_parentController"];
    if ([parentController respondsToSelector:@selector(specifierForApplicationWithIdentifier:)]){
        [(BKGPApplicationListSubcontrollerController *)parentController updateIvars];
        [(BKGPApplicationListSubcontrollerController *)parentController reloadSpecifier:[(BKGPApplicationListSubcontrollerController *)parentController specifierForApplicationWithIdentifier:self.identifier] animated:YES];
    }
}

-(void)updateParentViewControllerWithDelay:(double)delay{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateParentViewController];
    });
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    
    NSString *key = [specifier propertyForKey:@"key"];
    if ([key isEqualToString:@"retire"]){
        if ([value unsignedLongValue] == BKGBackgroundTypeImmortal){
            _isAdvanced = NO;
            [_expirationSpecifier setProperty:@NO forKey:@"enabled"];
            [_cpuControllerSpecifier setProperty:@NO forKey:@"enabled"];
            [_systemCallsControllerSpecifier setProperty:@NO forKey:@"enabled"];
            [_networkControllerSpecifier setProperty:@NO forKey:@"enabled"];
            [_timeSpanSpecifier setProperty:@NO forKey:@"enabled"];
        }else if ([value unsignedLongValue] == BKGBackgroundTypeAdvanced){
            _isAdvanced = YES;
            [_expirationSpecifier setProperty:@NO forKey:@"enabled"];
            [_cpuControllerSpecifier setProperty:@YES forKey:@"enabled"];
            [_systemCallsControllerSpecifier setProperty:@YES forKey:@"enabled"];
            [_networkControllerSpecifier setProperty:@YES forKey:@"enabled"];
            [_timeSpanSpecifier setProperty:@YES forKey:@"enabled"];
        }else{
            _isAdvanced = NO;
            [_expirationSpecifier setProperty:@YES forKey:@"enabled"];
            [_cpuControllerSpecifier setProperty:@NO forKey:@"enabled"];
            [_systemCallsControllerSpecifier setProperty:@NO forKey:@"enabled"];
            [_networkControllerSpecifier setProperty:@NO forKey:@"enabled"];
            [_timeSpanSpecifier setProperty:@NO forKey:@"enabled"];
        }
        [self reloadSpecifier:_expirationSpecifier animated:YES];
        [self reloadSpecifier:_cpuControllerSpecifier animated:YES];
        [self reloadSpecifier:_systemCallsControllerSpecifier animated:YES];
        [self reloadSpecifier:_networkControllerSpecifier animated:YES];
        [self reloadSpecifier:_timeSpanSpecifier animated:YES];
	}else if ([key isEqualToString:@"cpuThrottleEnabled"]){
		[_cpuThrottlePercentageSpecifier setProperty:value forKey:@"enabled"];
		[self reloadSpecifier:_cpuThrottlePercentageSpecifier animated:YES];
	}
    
    setValueForConfigKey(self.identifier, key, value);
	
	if ([key isEqualToString:@"cpuThrottleEnabled"] || [key isEqualToString:@"retire"]){
		[self showCPUThrottleWarningIfNecessary];
	}
	
    if ([key isEqualToString:@"enabled"]){
        if ([value boolValue] && !_expanded){
            [self insertContiguousSpecifiers:_expandableSpecifiers afterSpecifier:specifier animated:YES];
            _expanded = YES;
        }else if(![value boolValue] && _expanded){
            [self removeContiguousSpecifiers:_expandableSpecifiers animated:YES];
            _expanded = NO;
        }
    }
    
    if ([key isEqualToString:@"enabled"] || [key isEqualToString:@"retire"] || [key isEqualToString:@"expiration"] || [key isEqualToString:@"darkWake"]){
        [self updateParentViewController];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"[BKGPAppEntryController] viewWillAppear called");
    [super viewWillAppear:animated];
    
    BKGBackgroundType backgroundType = unsignedLongValueForConfigKey(self.identifier, @"retire", BKGBackgroundTypeRetire);
    if (backgroundType == BKGBackgroundTypeImmortal){
        _isAdvanced = NO;
        [_expirationSpecifier setProperty:@NO forKey:@"enabled"];
        [_cpuControllerSpecifier setProperty:@NO forKey:@"enabled"];
        [_systemCallsControllerSpecifier setProperty:@NO forKey:@"enabled"];
        [_networkControllerSpecifier setProperty:@NO forKey:@"enabled"];
        [_timeSpanSpecifier setProperty:@NO forKey:@"enabled"];
    }else if (backgroundType == BKGBackgroundTypeAdvanced){
        _isAdvanced = YES;
        [_expirationSpecifier setProperty:@NO forKey:@"enabled"];
        [_cpuControllerSpecifier setProperty:@YES forKey:@"enabled"];
        [_systemCallsControllerSpecifier setProperty:@YES forKey:@"enabled"];
        [_networkControllerSpecifier setProperty:@YES forKey:@"enabled"];
        [_timeSpanSpecifier setProperty:@YES forKey:@"enabled"];
    }else{
        _isAdvanced = NO;
        [_expirationSpecifier setProperty:@YES forKey:@"enabled"];
        [_cpuControllerSpecifier setProperty:@NO forKey:@"enabled"];
        [_systemCallsControllerSpecifier setProperty:@NO forKey:@"enabled"];
        [_networkControllerSpecifier setProperty:@NO forKey:@"enabled"];
        [_timeSpanSpecifier setProperty:@NO forKey:@"enabled"];
    }
    [self reloadSpecifier:_expirationSpecifier animated:YES];
    [self reloadSpecifier:_cpuControllerSpecifier animated:YES];
    [self reloadSpecifier:_systemCallsControllerSpecifier animated:YES];
    [self reloadSpecifier:_networkControllerSpecifier animated:YES];
    [self reloadSpecifier:_timeSpanSpecifier animated:YES];
	
	BOOL cpuThrottleEnabled = boolValueForConfigKey(self.identifier, @"cpuThrottleEnabled", NO);
	[_cpuThrottlePercentageSpecifier setProperty:@(cpuThrottleEnabled) forKey:@"enabled"];
	[self reloadSpecifier:_cpuThrottlePercentageSpecifier animated:YES];
	
	[self showCPUThrottleWarningIfNecessary];
	
    [super viewWillAppear:animated];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (!_manuallyExpanded && !_expanded && indexPath == [self indexPathForSpecifier:_enabledEntrySpecifier]){
        [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
        [self expands:!_expanded];
        _manuallyExpanded = YES;
    }
}

-(void)expands:(BOOL)expands{
    if (expands && !_expanded){
        [self insertContiguousSpecifiers:_expandableSpecifiers afterSpecifier:_enabledEntrySpecifier animated:YES];
        _expanded = YES;
    }else if (!expands && _expanded){
        [self removeContiguousSpecifiers:_expandableSpecifiers animated:YES];
        _expanded = NO;
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"[BKGPAppEntryController] viewDidLoad called");
    
    // Ensure specifier is set up properly
    if (self.specifier && self.specifier.identifier) {
        self.identifier = self.specifier.identifier;
        self.appName = [self.specifier propertyForKey:@"label"] ?: self.specifier.identifier;
        NSLog(@"[BKGPAppEntryController] viewDidLoad - App: %@ (%@)", self.appName, self.identifier);
    } else {
        NSLog(@"[BKGPAppEntryController] viewDidLoad - No specifier found");
    }
}

-(void)loadView{
    [super loadView];
    NSLog(@"[BKGPAppEntryController] loadView called");
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

-(void)_returnKeyPressed:(id)arg1{
    [self.view endEditing:YES];
}
@end

#import "BKGPApplicationListSubcontrollerController.h"
#import "../BKGShared.h"

@implementation BKGPApplicationListSubcontrollerController

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

-(NSArray *)getAllEntries:(NSString *)keyName keyIdentifier:(NSString *)keyIdentifier{
    NSArray *arrayWithEventID = [_prefs[keyName] valueForKey:keyIdentifier];
    return arrayWithEventID;
}

-(void)updateIvars{
    _prefs = [getPrefs() ?: @{} mutableCopy];
    _allEntriesIdentifier = [self getAllEntries:@"enabledIdentifier" keyIdentifier:@"identifier"];
}

- (void)loadPreferences{
    [self updateIvars];
    [super loadPreferences];
}


- (NSString*)previewStringForApplicationWithIdentifier:(NSString *)applicationID{
    return [self previewForApplication:applicationID];
}

- (NSString*)subtitleForApplicationWithIdentifier:(NSString*)applicationID{
    return [self subtitleForApplication:applicationID];
}

-(NSString *)formattedExpiration:(double)seconds{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    if (seconds < 60){
        formatter.numberStyle = NSNumberFormatterNoStyle;
        return [NSString stringWithFormat:@"%@秒", [formatter stringFromNumber:@(seconds)]];
    }else if (seconds < 3600){
        formatter.numberStyle = NSNumberFormatterNoStyle;
        return [NSString stringWithFormat:@"%@分钟", [formatter stringFromNumber:@(seconds/60.0)]];
    }else if (fmod(seconds, 60.0) > 0){
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.maximumFractionDigits = 1;
        formatter.roundingMode = NSNumberFormatterRoundUp;
        return [NSString stringWithFormat:@"%@小时", [formatter stringFromNumber:@(seconds/3600.0)]];
    }else{
        formatter.numberStyle = NSNumberFormatterNoStyle;
        return [NSString stringWithFormat:@"%@小时", [formatter stringFromNumber:@(seconds/3600.0)]];
    }
}

- (NSString *)subtitleForApplication:(NSString *)appID{
    NSUInteger identifierIdx = [_allEntriesIdentifier indexOfObject:appID];
    
    BOOL enabled = boolValueForConfigKeyWithPrefsAndIndex(@"enabled", NO, _prefs, identifierIdx);
    if (!enabled) return @"";
    
    double expiration = doubleValueForConfigKeyWithPrefsAndIndex(@"expiration", defaultExpirationTime, _prefs, identifierIdx);
    
    BKGBackgroundType backgroundType = unsignedLongValueForConfigKeyWithPrefsAndIndex(@"retire", BKGBackgroundTypeRetire, _prefs, identifierIdx);
    
    NSString *verboseText = @"";
    NSMutableArray *verboseArray = [NSMutableArray array];
    
    switch (backgroundType) {
        case BKGBackgroundTypeTerminate:{
            [verboseArray addObject:[self formattedExpiration:expiration]];
            break;
        }
        case BKGBackgroundTypeRetire:{
            [verboseArray addObject:[self formattedExpiration:expiration]];
            break;
        }
        case BKGBackgroundTypeImmortal:{
            break;
        }
        case BKGBackgroundTypeAdvanced:{
            BOOL cpuUsageEnabled = boolValueForConfigKeyWithPrefsAndIndex(@"cpuUsageEnabled", NO, _prefs, identifierIdx);
            if (cpuUsageEnabled){
                [verboseArray addObject:@"CPU"];
            }
            
            int systemCallsType = intValueForConfigKeyWithPrefsAndIndex(@"systemCallsType", 0, _prefs, identifierIdx);
            if (systemCallsType > 0){
                [verboseArray addObject:@"System"];
            }
            
            int networkTransmissionType = intValueForConfigKeyWithPrefsAndIndex(@"networkTransmissionType", 0, _prefs, identifierIdx);
            if (networkTransmissionType > 0){
                [verboseArray addObject:@"Network"];
            }
            break;
        }
        default:
            return @"";
    }
    
    BOOL darkWake = boolValueForConfigKeyWithPrefsAndIndex(@"darkWake", NO, _prefs, identifierIdx);
    if (darkWake){
        [verboseArray addObject:@"唤醒"];
    }
    
    if (verboseArray.count > 0){
        verboseText = [verboseArray componentsJoinedByString:@" | "];
    }
    return verboseText;
    
}
- (NSString *)previewForApplication:(NSString *)appID{
    NSUInteger identifierIdx = [_allEntriesIdentifier indexOfObject:appID];
    
    BOOL enabled = boolValueForConfigKeyWithPrefsAndIndex(@"enabled", NO, _prefs, identifierIdx);
    if (!enabled) return @"";
    
    BKGBackgroundType backgroundType = unsignedLongValueForConfigKeyWithPrefsAndIndex(@"retire", BKGBackgroundTypeRetire, _prefs, identifierIdx);
    
    switch (backgroundType) {
        case BKGBackgroundTypeTerminate:{
            return @"终止";
        }
        case BKGBackgroundTypeRetire:{
            return @"挂起";
        }
        case BKGBackgroundTypeImmortal:{
            return @"常驻";
        }
        case BKGBackgroundTypeAdvanced:{
            return @"高级";
        }
        default:
            return @"";
    }
}
@end


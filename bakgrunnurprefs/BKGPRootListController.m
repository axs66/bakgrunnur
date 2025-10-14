#import "../common.h"
#import "../BKGShared.h"
#import "BKGPRootListController.h"
#import "../PrivateHeaders.h"
#import "NSTask.h"

@implementation BKGPRootListController

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

- (void)refreshSpecifiers:(NSNotification *)notification{
	[self reloadSpecifiers];
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *rootSpecifiers = [[NSMutableArray alloc] init];
        
        //Tweak
        PSSpecifier *tweakEnabledGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"功能" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [tweakEnabledGroupSpec setProperty:@"无需重启，修改会在应用启动或切回时生效。" forKey:@"footerText"];
        [rootSpecifiers addObject:tweakEnabledGroupSpec];
        
        PSSpecifier *tweakEnabledSpec = [PSSpecifier preferenceSpecifierNamed:@"启用" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [tweakEnabledSpec setProperty:@"启用" forKey:@"label"];
        [tweakEnabledSpec setProperty:@"enabled" forKey:@"key"];
        [tweakEnabledSpec setProperty:@YES forKey:@"default"];
        [tweakEnabledSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [tweakEnabledSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [rootSpecifiers addObject:tweakEnabledSpec];
        
        //blank
        PSSpecifier *blankSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:blankSpecGroup];
        
        //Manage Apps
        PSSpecifier *altListSpec = [PSSpecifier preferenceSpecifierNamed:@"管理应用" target:nil set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"BKGPApplicationListSubcontrollerController") cell:PSLinkListCell edit:nil];
        [altListSpec setProperty:@"BKGPAppEntryController" forKey:@"subcontrollerClass"];
        [altListSpec setProperty:@"管理应用" forKey:@"label"];
        NSString *sectionType = boolValueForKey(@"showHiddenApps", NO) ? @"全部" : @"可见";
        [altListSpec setProperty:@[
            @{@"sectionType":sectionType},
        ] forKey:@"sections"];
        [altListSpec setProperty:@YES forKey:@"useSearchBar"];
        [altListSpec setProperty:@YES forKey:@"hideSearchBarWhileScrolling"];
        [altListSpec setProperty:@YES forKey:@"alphabeticIndexingEnabled"];
        [altListSpec setProperty:@YES forKey:@"showIdentifiersAsSubtitle"];
        [altListSpec setProperty:@YES forKey:@"includeIdentifiersInSearch"];
        [rootSpecifiers addObject:altListSpec];
        
        //accessory type
        PSSpecifier *homescreenGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"主屏幕" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [homescreenGroupSpec setProperty:@"当应用在后台运行时显示指示器。若选择圆点，新装或刚更新应用的系统圆点将被覆盖隐藏。" forKey:@"footerText"];
        [rootSpecifiers addObject:homescreenGroupSpec];
        
        PSSpecifier *preferredAccessoryTypeSelectionSpec = [PSSpecifier preferenceSpecifierNamed:@"指示样式" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSegmentCell edit:nil];
        [preferredAccessoryTypeSelectionSpec setValues:@[@0, @2, @4] titles:@[@"关闭", @"圆点", @"沙漏"]];
        [preferredAccessoryTypeSelectionSpec setProperty:@2 forKey:@"default"];
        [preferredAccessoryTypeSelectionSpec setProperty:@"preferredAccessoryType" forKey:@"key"];
        [preferredAccessoryTypeSelectionSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [preferredAccessoryTypeSelectionSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [rootSpecifiers addObject:preferredAccessoryTypeSelectionSpec];
        
        //dock
        PSSpecifier *showIndicatorOnDockSpec = [PSSpecifier preferenceSpecifierNamed:@"Dock 指示器" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [showIndicatorOnDockSpec setProperty:@"Dock 指示器" forKey:@"label"];
        [showIndicatorOnDockSpec setProperty:@"showIndicatorOnDock" forKey:@"key"];
        [showIndicatorOnDockSpec setProperty:@YES forKey:@"default"];
        [showIndicatorOnDockSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
        [showIndicatorOnDockSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
        [rootSpecifiers addObject:showIndicatorOnDockSpec];
        
        /*
        //force touch shortcut
        PSSpecifier *forceTouchShortcutGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [forceTouchShortcutGroupSpec setProperty:@"Show shortcut for enabling or disabling Bakgrunnur for each individual app via quick actions menu in homescreen." forKey:@"footerText"];
        [rootSpecifiers addObject:forceTouchShortcutGroupSpec];
        
        PSSpecifier *forceTouchShortcutSpec = [PSSpecifier preferenceSpecifierNamed:@"Quick Action" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [forceTouchShortcutSpec setProperty:@"Quick Action" forKey:@"label"];
        [forceTouchShortcutSpec setProperty:@"showForceTouchShortcut" forKey:@"key"];
        [forceTouchShortcutSpec setProperty:@YES forKey:@"default"];
        [forceTouchShortcutSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
         [forceTouchShortcutSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
         [rootSpecifiers addObject:forceTouchShortcutSpec];
         */
        
        //force touch shortcut
        PSSpecifier *forceTouchShortcutGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [forceTouchShortcutGroupSpec setProperty:@"在主屏幕快捷操作里为每个应用显示启用/禁用开关。" forKey:@"footerText"];
        [rootSpecifiers addObject:forceTouchShortcutGroupSpec];
        
        PSSpecifier *forceTouchShortcutSpec = [PSSpecifier preferenceSpecifierNamed:@"快捷操作" target:nil set:nil get:nil detail:NSClassFromString(@"BKGPQuickActionsController") cell:PSLinkCell edit:nil];
        [rootSpecifiers addObject:forceTouchShortcutSpec];
        
        //banner
        if (@available(iOS 14.0, *)){
            PSSpecifier *presentBannerGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
            [presentBannerGroupSpec setProperty:@"当 Bakgrunnur 处理应用时显示横幅提示。" forKey:@"footerText"];
            [rootSpecifiers addObject:presentBannerGroupSpec];

            PSSpecifier *presentBannerSpec = [PSSpecifier preferenceSpecifierNamed:@"横幅提示" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
            [presentBannerSpec setProperty:@"横幅提示" forKey:@"label"];
            [presentBannerSpec setProperty:@"presentBanner" forKey:@"key"];
            [presentBannerSpec setProperty:@YES forKey:@"default"];
            [presentBannerSpec setProperty:BAKGRUNNUR_IDENTIFIER forKey:@"defaults"];
            [presentBannerSpec setProperty:PREFS_CHANGED_NOTIFICATION_NAME forKey:@"PostNotification"];
            [rootSpecifiers addObject:presentBannerSpec];
        }
        
        //blank
        [rootSpecifiers addObject:blankSpecGroup];

        //Advanced
        PSSpecifier *advancedGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"其他" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:advancedGroupSpec];
        
        PSSpecifier *advancedSpec = [PSSpecifier preferenceSpecifierNamed:@"高级" target:nil set:nil get:nil detail:NSClassFromString(@"BKGPAdvancedController") cell:PSLinkCell edit:nil];
        [rootSpecifiers addObject:advancedSpec];
        
        //reset
        PSSpecifier *resetGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [resetGroupSpec setProperty:@"重置所有设置为默认值。" forKey:@"footerText"];
        [rootSpecifiers addObject:resetGroupSpec];
        
        PSSpecifier *resetSpec = [PSSpecifier preferenceSpecifierNamed:@"重置" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [resetSpec setProperty:@"重置" forKey:@"label"];
        [resetSpec setButtonAction:@selector(reset)];
        [rootSpecifiers addObject:resetSpec];
        
        //blsnk group
        [rootSpecifiers addObject:blankSpecGroup];
        
        //Support Dev
        PSSpecifier *supportDevGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"开发支持" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:supportDevGroupSpec];
        
        PSSpecifier *supportDevSpec = [PSSpecifier preferenceSpecifierNamed:@"关注抖音" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [supportDevSpec setProperty:@"关注抖音" forKey:@"label"];
        [supportDevSpec setButtonAction:@selector(donation)];
        [supportDevSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/BakgrunnurPrefs.bundle/PayPal.png"] forKey:@"iconImage"];
        [rootSpecifiers addObject:supportDevSpec];
        
        
        //Contact
        PSSpecifier *contactGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"联系" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [rootSpecifiers addObject:contactGroupSpec];
        
        //Twitter
        PSSpecifier *twitterSpec = [PSSpecifier preferenceSpecifierNamed:@"Sileo越狱源" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [twitterSpec setProperty:@"Sileo越狱源" forKey:@"label"];
        [twitterSpec setButtonAction:@selector(twitter)];
        [twitterSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/BakgrunnurPrefs.bundle/Twitter.png"] forKey:@"iconImage"];
        [rootSpecifiers addObject:twitterSpec];
        
        //Reddit
        PSSpecifier *redditSpec = [PSSpecifier preferenceSpecifierNamed:@"TG分享频道" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [redditSpec setProperty:@"TG分享频道" forKey:@"label"];
        [redditSpec setButtonAction:@selector(reddit)];
        [redditSpec setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/BakgrunnurPrefs.bundle/Reddit.png"] forKey:@"iconImage"];
        [rootSpecifiers addObject:redditSpec];
        
        //udevs
        PSSpecifier *createdByGroupSpec = [PSSpecifier preferenceSpecifierNamed:@"" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [createdByGroupSpec setProperty:@"由 udevs 开发" forKey:@"footerText"];
        [createdByGroupSpec setProperty:@1 forKey:@"footerAlignment"];
        [rootSpecifiers addObject:createdByGroupSpec];
        
        _specifiers = rootSpecifiers;
        
        
    }
    
    return _specifiers;
}

-(id)readPreferenceValue:(PSSpecifier*)specifier{
    NSString *key = [specifier propertyForKey:@"key"];
    id value = valueForKey(key, specifier.properties[@"default"]);
    return value;
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier{
    setValueForKey([specifier propertyForKey:@"key"], value);
	/*
    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
	 */
    if ([specifier.properties[@"key"] isEqualToString:@"enabled"]){
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)REFRESH_MODULE_NOTIFICATION_NAME, NULL, NULL, YES);
        
    }
}

-(void)viewDidLoad  {
    [super viewDidLoad];
    
    
    CGRect frame = CGRectMake(0,0,self.table.bounds.size.width,170);
    CGRect Imageframe = CGRectMake(0,10,self.table.bounds.size.width,80);
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor colorWithRed: 1.00 green: 0.29 blue: 0.61 alpha: 1.00];
    
    
    UIImage *headerImage = [[UIImage alloc]
                            initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/BakgrunnurPrefs.bundle"] pathForResource:@"Bakgrunnur512" ofType:@"png"]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:Imageframe];
    [imageView setImage:headerImage];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:imageView];
    
    CGRect labelFrame = CGRectMake(0,imageView.frame.origin.y + 90 ,self.table.bounds.size.width,80);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [headerLabel setText:@"Bakgrunnur"];
    [headerLabel setFont:font];
    [headerLabel setTextColor:[UIColor blackColor]];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setContentMode:UIViewContentModeScaleAspectFit];
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:headerLabel];
    
    self.table.tableHeaderView = headerView;
    
    self.respringBtn = [[UIBarButtonItem alloc] initWithTitle:@"重启 SpringBoard" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
    self.navigationItem.rightBarButtonItem = self.respringBtn;
}

-(void)reset{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Bakgrunnur" message:@"确定要重置为默认设置？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:PREFS_PATH error:&error];
        if ((error != nil || error != NULL) && [[NSFileManager defaultManager] fileExistsAtPath:PREFS_PATH]){
            UIAlertController *alertFailed = [UIAlertController alertControllerWithTitle:@"Bakgrunnur" message:[NSString stringWithFormat:@"重置失败：%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [alertFailed addAction:okAction];
            
            [self presentViewController:alertFailed animated:YES completion:nil];
            
        }else{
            [self reloadSpecifiers];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)PREFS_CHANGED_NOTIFICATION_NAME, NULL, NULL, YES);
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)REFRESH_MODULE_NOTIFICATION_NAME, NULL, NULL, YES);
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)RESET_ALL_NOTIFICATION_NAME, NULL, NULL, YES);

        }
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}

-(int)runCommand:(NSString *)cmd{
    if ([cmd length] != 0){
        NSMutableArray *taskArgs = [[NSMutableArray alloc] init];
        taskArgs = [NSMutableArray arrayWithObjects:@"-c", cmd, nil];
        NSTask * task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/bash"];
        [task setArguments:taskArgs];
        NSPipe* outputPipe = [NSPipe pipe];
        task.standardOutput = outputPipe;
        [task launch];
        //NSData *data = [[outputPipe fileHandleForReading] readDataToEndOfFile];
        [task waitUntilExit];
        return [task terminationStatus];
    }
    return 0;
}

-(void)respring{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Bakgrunnur" message:@"无需重启，是否仍要重启 SpringBoard？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *jbPrefix = [[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb"] ? @"/var/jb" : @"";
        NSString *bkgPath = [jbPrefix stringByAppendingString:@"/usr/bin/bkg"];
        if ([[NSFileManager defaultManager] isExecutableFileAtPath:bkgPath]){
            [self runCommand:[NSString stringWithFormat:@"'%@' --privatekillbkgd", bkgPath]];
        }
        NSString *sbreloadPath = [jbPrefix stringByAppendingString:@"/usr/bin/sbreload"];
        if ([[NSFileManager defaultManager] isExecutableFileAtPath:sbreloadPath]){
            [self runCommand:[NSString stringWithFormat:@"'%@'", sbreloadPath]];
        }else{
            [self runCommand:@"killall -9 SpringBoard"];
        }
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)donation{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"snssdk1128://user/profile/1935590721863150"] options:@{} completionHandler:nil];
}

-(void)twitter{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://axs66.github.io/repo"] options:@{} completionHandler:nil];
}

-(void)reddit{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/wxfx8"] options:@{} completionHandler:nil];
}
@end

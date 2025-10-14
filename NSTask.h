// Minimal NSTask interface for jailbroken iOS where NSTask exists at runtime
// This header is provided solely for compilation; implementation is in Foundation on-device.

#import <Foundation/Foundation.h>

@interface NSTask : NSObject
@property (copy) NSString *launchPath;
@property (copy) NSArray<NSString *> *arguments;
@property (retain) id standardOutput;
- (instancetype)init;
- (void)launch;
- (void)waitUntilExit;
- (int)terminationStatus;
@end



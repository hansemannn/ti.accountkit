/**
 * ti.accountkit
 *
 * Created by Your Name
 * Copyright (c) 2016 Your Company. All rights reserved.
 */

#import "TiAccountkitModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation TiAccountkitModule

#pragma mark Internal

// this is generated for your module, please do not change it
- (id)moduleGUID
{
	return @"43908d52-f013-4f83-917e-b3e8f89e5df5";
}

// this is generated for your module, please do not change it
- (NSString*)moduleId
{
	return @"ti.accountkit";
}

#pragma mark Lifecycle

- (void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
    
	NSLog(@"[INFO] %@ loaded",self);
}

- (void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

- (void)dealloc
{
    RELEASE_TO_NIL(accountKit);
    RELEASE_TO_NIL(pendingLoginViewController);

    // release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

- (void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma Public APIs

- (void)initialize:(id)args
{
    ENSURE_TYPE([args objectAtIndex:0], NSNumber);
    
    if (accountKit == nil) {
        accountKit = [[AKFAccountKit alloc] initWithResponseType:NUMINT([args objectAtIndex:0])];
    }
    
    pendingLoginViewController = [accountKit viewControllerForLoginResume];
    [pendingLoginViewController setDelegate:self];
    [pendingLoginViewController setAdvancedUIManager:nil];
    [pendingLoginViewController setTheme:nil];
}

- (void)loginWithPhone:(id)unused
{
    ENSURE_UI_THREAD(loginWithPhone, unused);
    
    // TODO: Support prefill
    // AKFPhoneNumber *phoneNumber = [[AKFPhoneNumber alloc] initWithCountryCode:@"49" phoneNumber:@"176xxxx35897"];
    NSString *inputState = [[NSUUID UUID] UUIDString];
    UIViewController<AKFViewController> *viewController = [accountKit viewControllerForPhoneLoginWithPhoneNumber:nil state:inputState];
    [viewController setEnableSendToFacebook:YES];
    [[[[TiApp app] controller] topPresentedController] presentViewController:viewController animated:YES completion:nil];
}

- (void)loginWithEmail:(id)unused
{
    ENSURE_UI_THREAD(loginWithEmail, unused);

    // TODO: Support prefill
    // NSString *email = @"test@example.com";
    NSString *inputState = [[NSUUID UUID] UUIDString];
    UIViewController<AKFViewController> *viewController = [accountKit viewControllerForEmailLoginWithEmail:nil state:inputState];
    [[[[TiApp app] controller] topPresentedController] presentViewController:viewController animated:YES completion:nil];
}

- (void)logout:(id)unused
{
   ENSURE_UI_THREAD(logout, unused);
   [accountKit logOut];
}

- (void)requestAccount:(id)args
{
    ENSURE_TYPE([args objectAtIndex:0], KrollCallback);
    KrollCallback *callback = [args objectAtIndex:0];
    
    TiThreadPerformOnMainThread(^{
        [accountKit requestAccount:^(id<AKFAccount> account, NSError *error) {
            NSMutableDictionary * event = [@{
                @"success":NUMBOOL(!error),
                @"error": error ? [error localizedDescription] : [NSNull null],
            } copy];
            
            if ([account emailAddress] != nil) {
                [event setValue:[account emailAddress] forKey:@"email"];
            }
            
            if ([account phoneNumber] != nil) {
                [event setValue:[account phoneNumber] forKey:@"phone"];
            }
            
            KrollEvent * invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:event thisObject:self];
            [[callback context] enqueue:invocationEvent];
            [invocationEvent release];
            [event release];

        }];
    },NO);
}

#pragma Delegates

- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken state:(NSString *)state
{
    [self fireEvent:@"success" withObject:@{@"accessToken": [self dictionaryFromAccessToken:accessToken]}];
}

- (void)viewControllerDidCancel:(UIViewController<AKFViewController> *)viewController
{
    [self fireEvent:@"cancel"];
}

- (void)viewController:(UIViewController<AKFViewController> *)viewController didFailWithError:(NSError *)error
{
    [self fireEvent:@"error" withObject:@{@"message":[error localizedDescription]}];
}

- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAuthorizationCode:(NSString *)code state:(NSString *)state
{
    [self fireEvent:@"error" withObject:@{@"code":code, @"state":state}];
}

#pragma Utils

- (NSDictionary*)dictionaryFromAccessToken:(id<AKFAccessToken>)accessToken
{
    return @{
        @"accountID": [accessToken accountID],
        @"applicationID": [accessToken applicationID],
        @"lastRefresh": [accessToken lastRefresh],
    };
}

MAKE_SYSTEM_PROP(RESPONSE_TYPE_AUTHORIZATION_CODE, AKFResponseTypeAuthorizationCode);
MAKE_SYSTEM_PROP(RESPONSE_TYPE_ACCESS_TOKEN, AKFResponseTypeAccessToken);

@end

/**
 * ti.accountkit
 *
 * Created by Hans Knoechel
 * Copyright (c) 2016-Present Hans Knoechel. All rights reserved.
 */

#import "TiAccountkitModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation TiAccountkitModule

#pragma mark Internal

- (id)moduleGUID
{
	return @"43908d52-f013-4f83-917e-b3e8f89e5df5";
}

- (NSString*)moduleId
{
	return @"ti.accountkit";
}

#pragma mark Lifecycle

- (void)startup
{
	[super startup];
	NSLog(@"[DEBUG] %@ loaded",self);
}

#pragma mark Public APIs

- (void)initialize:(id)args
{
    ENSURE_ARG_COUNT(args, 1);
    ENSURE_TYPE([args objectAtIndex:0], NSNumber);
    
    AKFResponseType responseType = [TiUtils intValue:[args objectAtIndex:0] def:AKFResponseTypeAccessToken];
    
    if (accountKit == nil) {
        accountKit = [[AKFAccountKit alloc] initWithResponseType:responseType];
    }
}

- (void)loginWithPhone:(id)args
{
    ENSURE_UI_THREAD(loginWithPhone, args);

    id phone = [args objectAtIndex:0];
    id countryCode = [args objectAtIndex:1];
    
    ENSURE_TYPE(phone, NSString);
    ENSURE_TYPE(countryCode, NSString);
    
    AKFPhoneNumber *phoneNumber = [[AKFPhoneNumber alloc] initWithCountryCode: [countryCode uppercaseString]
                                                                  phoneNumber: [TiUtils stringValue:phone]];
    NSString *inputState = [[NSUUID UUID] UUIDString];
    
    UIViewController<AKFViewController> *viewController = [accountKit viewControllerForPhoneLoginWithPhoneNumber:phoneNumber
                                                                                                           state:inputState];
    [viewController setEnableSendToFacebook:YES];
    [viewController setDelegate:self];

    [[TiApp app] showModalController:viewController animated:YES];
}

- (void)loginWithEmail:(id)args
{
    ENSURE_UI_THREAD(loginWithEmail, args);
    
    id email = [args objectAtIndex:0];
    ENSURE_TYPE_OR_NIL(email, NSString);

    NSString *prefilledEmail = [TiUtils stringValue:email];
    NSString *inputState = [[NSUUID UUID] UUIDString];

    UIViewController<AKFViewController> *viewController = [accountKit viewControllerForEmailLoginWithEmail:prefilledEmail
                                                                                                     state:inputState];
    [viewController setDelegate:self];

    [[TiApp app] showModalController:viewController animated:YES];
}

- (void)logout:(id)value
{
    ENSURE_SINGLE_ARG_OR_NIL(value, KrollCallback);
    
    if (value == nil) {
        [accountKit logOut];
    } else {
        [accountKit logOut:^(BOOL success, NSError *error) {
            NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:NUMBOOL(success), @"success", nil];
            
            if (error != nil) {
                [event setObject:[error localizedDescription] forKey:@"error"];
            }
            
            [(KrollCallback *)value call:@[event] thisObject:self];
        }];
    }
}

- (void)requestAccount:(id)args
{
    ENSURE_TYPE([args objectAtIndex:0], KrollCallback);
    KrollCallback *callback = [args objectAtIndex:0];
    
    TiThreadPerformOnMainThread(^{
        [accountKit requestAccount:^(id<AKFAccount> account, NSError *error) {

            NSMutableDictionary * event = [[NSMutableDictionary alloc] initWithDictionary:@{@"success":[NSNumber numberWithBool:!error]}];

            if (error != nil) {
                [event setValue:[[[[error userInfo] valueForKey:@"NSUnderlyingError"] userInfo] valueForKey:@"com.facebook.accountkit:ErrorDeveloperMessageKey"] forKey:@"message"];
            } else {
                if ([account accountID] != nil) {
                    [event setValue:[account accountID] forKey:@"accountID"];
                }
                
                if ([account emailAddress] != nil) {
                    [event setValue:[account emailAddress] forKey:@"email"];
                }
                
                if ([account phoneNumber] != nil) {
                    [event setValue:[account phoneNumber] forKey:@"phone"];
                }
            }
            
            KrollEvent * invocationEvent = [[KrollEvent alloc] initWithCallback:callback eventObject:event thisObject:self];
            [[callback context] enqueue:invocationEvent];
        }];
    }, NO);
}

- (void)cancelLogin:(id)unused
{
    [accountKit cancelLogin];
}

- (void)currentAccessToken
{
    return [self dictionaryFromAccessToken:[accountKit currentAccessToken]];
}

- (NSString *)graphVersion
{
    return [AKFAccountKit graphVersionString];
}

- (NSString *)version
{
    return [AKFAccountKit versionString];
}

#pragma mark Delegates

- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken state:(NSString *)state
{
    [self fireEvent:@"login" withObject:@{
        @"accessToken": [self dictionaryFromAccessToken:accessToken],
        @"state":state,
        @"success": @YES
    }];
}

- (void)viewControllerDidCancel:(UIViewController<AKFViewController> *)viewController
{
    [self fireEvent:@"login" withObject:@{
        @"success": @NO,
        @"cancel": @YES
    }];
}

- (void)viewController:(UIViewController<AKFViewController> *)viewController didFailWithError:(NSError *)error
{
    [self fireEvent:@"login" withObject:@{
        @"success": @NO,
        @"error":[error localizedDescription]
    }];
}

- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAuthorizationCode:(NSString *)code state:(NSString *)state
{
    [self fireEvent:@"login" withObject:@{
        @"success": @YES,
        @"code":code,
        @"state":state
    }];
}

#pragma mark Utilities

- (NSDictionary*)dictionaryFromAccessToken:(id<AKFAccessToken>)accessToken
{
    return @{
         @"accountID": [accessToken accountID],
         @"applicationID": [accessToken applicationID],
         @"lastRefresh": [accessToken lastRefresh],
         @"tokenRefreshInterval": NUMDOUBLE([accessToken tokenRefreshInterval]),
         @"tokenString": [accessToken tokenString]
    };
}

#pragma mark Constants

MAKE_SYSTEM_PROP(RESPONSE_TYPE_AUTHORIZATION_CODE, AKFResponseTypeAuthorizationCode);
MAKE_SYSTEM_PROP(RESPONSE_TYPE_ACCESS_TOKEN, AKFResponseTypeAccessToken);

@end

/**
 * ti.accountkit
 *
 * Created by Hans Knoechel
 * Copyright (c) 2016 Hans Knoechel. All rights reserved.
 */

#import "TiModule.h"
#import <AccountKit/AccountKit.h>

@interface TiAccountkitModule : TiModule<AKFViewControllerDelegate>
{
    /**
     *  The AccountKit instance
     */
    AKFAccountKit *accountKit;
}

/**
 *  Initializes the module with a login type.
 *
 *  @param args The arguments passed to initialize the module.
 *  @since 1.0.0
 */
- (void)initialize:(id)args;

/**
 *  Opens a login dialog to enter an phone number.
 *
 *  @param args The arguments passed to login with phone.
 *  @since 1.0.0
 */
- (void)loginWithPhone:(id)args;

/**
 *  Opens a login dialog to enter an email.
 *
 *  @param args The arguments passed to login with email.
 *  @since 1.0.0
 */
- (void)loginWithEmail:(id)args;

/**
 *  Logs out the current user if logged in.
 *
 *  @since 1.0.0
 */
- (void)logout:(id)unused;

/**
 *  Requests account info for the current user.
 *
 *  @param args The callback passed to be called after the infos are returned.
 *  @since 1.0.0
 */
- (void)requestAccount:(id)args;

@end

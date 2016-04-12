/**
 * ti.accountkit
 *
 * Created by Your Name
 * Copyright (c) 2016 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import <AccountKit/AccountKit.h>

@interface TiAccountkitModule : TiModule<AKFViewControllerDelegate>
{
    AKFAccountKit *accountKit;
    UIViewController<AKFViewController> *pendingLoginViewController;

}

@end

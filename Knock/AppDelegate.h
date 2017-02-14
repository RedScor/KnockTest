//
//  AppDelegate.h
//  Knock
//
//  Created by RedScor Yuan on 2017/2/11.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MMDrawerController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MMDrawerController *drawerController;
}
@property (strong, nonatomic) UIWindow *window;

- (void)initDrawer;
@end


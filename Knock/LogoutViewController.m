//
//  LogoutViewController.m
//  Knock
//
//  Created by RedScor Yuan on 2017/2/14.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import "LogoutViewController.h"
#import "APIClient.h"
#import "AppDelegate.h"

@interface LogoutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userName;
@end

@implementation LogoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *username = [APIClient sharedClient].userName;
    self.userName.text = username ?: @"";
}

- (IBAction)tapLogout:(id)sender {

    if (![APIClient sharedClient].userName) {
        self.userName.text = @"您尚未登入";
        return;
    }
    [APIClient sharedClient].userName = nil;
    [APIClient sharedClient].password = nil;
    [APIClient sharedClient].accessToken = nil;

    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appdelegate initDrawer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

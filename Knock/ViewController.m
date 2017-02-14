//
//  ViewController.m
//  Knock
//
//  Created by RedScor Yuan on 2017/2/11.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import "ViewController.h"
#import "NetAPIManager.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *loginMessage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Button Handlers
- (IBAction)loginPress:(UIButton *)sender {

    NSDictionary *dic = @{@"name":self.userName.text, @"pwd":self.password.text};

    [[NetAPIManager sharedManager] requestSignInWithBodyDic:dic block:^(id data, NSInteger statusCode, NSError *error) {

        if (data) {

            [APIClient sharedClient].userName = self.userName.text;
            [APIClient sharedClient].password = self.password.text;
            self.loginMessage.text = [NSString stringWithFormat:@"%@ 登入成功",self.userName.text];
        }else {
            self.loginMessage.text = @"登入失敗";
        }
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

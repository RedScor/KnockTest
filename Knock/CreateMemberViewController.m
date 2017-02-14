//
//  CreateMemberViewController.m
//  Knock
//
//  Created by RedScor Yuan on 2017/2/14.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import "CreateMemberViewController.h"
#import "NetAPIManager.h"

@interface CreateMemberViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property (weak, nonatomic) IBOutlet UILabel *responseLabel;
@end

@implementation CreateMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)CreateMemberClick:(UIButton *)sender {

    if ([self.userNameTextField.text length] == 0) {
        return;
    }
    NSDictionary *params = @{@"name":self.userNameTextField.text};

    [[NetAPIManager sharedManager] requestCreateMemeberWithNameDic:params
                                                             block:^(id data, NSInteger statusCode, NSError *error)
    {
        BOOL success;
        if (data && [data[@"code"] isEqualToString:@"success"]) {
            NSLog(@"會員建立成功");
            success  = YES;
        }else {
            NSLog(@"會員建立失敗");
        }
        NSString *successStr = success ? @"成功" : @"失敗";
        NSString *text = [NSString stringWithFormat:@"會員 %@ 建立 %@",self.userNameTextField.text, successStr];
        self.responseLabel.text = text;
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

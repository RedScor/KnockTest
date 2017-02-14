//
//  LeftMenuViewController.m
//  Knock
//
//  Created by RedScor Yuan on 2017/2/11.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import "LeftMenuViewController.h"
//#import "leftDrawerTableViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "ViewController.h"
#import "MemberListController.h"
#import "CreateMemberViewController.h"

@interface LeftMenuViewController ()

@property (nonatomic, strong) NSArray *menuArr;
@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);

    self.menuArr = @[@"登出", @"取得會員列表", @"新增會員"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.menuArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    NSString *menuStr = self.menuArr[indexPath.row];
    cell.textLabel.text = menuStr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];


    NSInteger index = indexPath.row;
    if (index > [self.menuArr count]) {
        return;
    }

    UIViewController *view;

    NSString *controllerStr;
    switch (index) {
        case 0:
        {
            controllerStr = @"Logout";
        }

            break;
        case 1:
        {
            controllerStr = @"memberList";

        }
            break;
        case 2:
        {
            controllerStr = @"createMember";
        }
            break;

        default:
            break;
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    view = [mainStoryboard instantiateViewControllerWithIdentifier:controllerStr];
    self.mm_drawerController.centerViewController = view;
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
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

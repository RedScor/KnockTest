//
//  MemberListController.m
//  Knock
//
//  Created by RedScor Yuan on 2017/2/14.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import "MemberListController.h"
#import "NetAPIManager.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

@interface MemberListController ()

@property (nonatomic, strong) NSArray *members;
@end

@implementation MemberListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestMemberList];
    [self setupLeftButton];

}

- (void)setupLeftButton {

    MMDrawerBarButtonItem *leftItemButton = [[MMDrawerBarButtonItem alloc]initWithTarget:self action:@selector(menuButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftItemButton animated:YES];
}

#pragma mark - Button Handlers
- (void)menuButtonPress:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)requestMemberList {

    [[NetAPIManager sharedManager] requestMemberListWithBlock:^(id data, NSInteger statusCode, NSError *error) {

        if (data && [data[@"data"] count] > 0) {
            self.members = data[@"data"];

            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.members count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberListCell" forIndexPath:indexPath];

    
    UILabel *numberLabel = [cell.contentView viewWithTag:100];
    UILabel *memberNameLabel = [cell.contentView viewWithTag:101];

    NSDictionary *memberDic = self.members[indexPath.row];

    numberLabel.text = [memberDic[@"ID"] isKindOfClass:[NSNumber class]] ?
                                            [memberDic[@"ID"] stringValue] :
                                            memberDic[@"ID"];
    memberNameLabel.text = memberDic[@"name"];

    
    return cell;
}




@end

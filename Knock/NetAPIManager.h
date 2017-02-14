//
//  NetAPIManager.h
//  Knock
//
//  Created by RedScor Yuan on 2017/2/11.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIClient.h"

typedef void (^requestBlock)(id data, NSInteger statusCode, NSError *error);

@interface NetAPIManager : NSObject

+ (instancetype)sharedManager;

/**
 *  登入用的Api
 */
- (void)requestSignInWithBodyDic:(id)params block:(requestBlock)block;

/**
 *  去得會員列表的Api
 */
- (void)requestMemberListWithBlock:(requestBlock)block;

/**
 *  新增會員的Api
 */
- (void)requestCreateMemeberWithNameDic:(id)params block:(requestBlock)block;
@end

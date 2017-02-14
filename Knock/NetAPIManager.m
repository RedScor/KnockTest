//
//  NetAPIManager.m
//  Knock
//
//  Created by RedScor Yuan on 2017/2/11.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import "NetAPIManager.h"

@implementation NetAPIManager

+ (instancetype)sharedManager {
    static NetAPIManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

- (void)requestSignInWithBodyDic:(id)params block:(requestBlock)block {

    [[APIClient sharedClient] requestSignInWithBodyDic:params block:^(NSURLSessionDataTask *task, id responseObject, NSUInteger statusCode, NSError *error) {

        if (responseObject && responseObject[@"token"]) {
            NSString *token = responseObject[@"token"][@"token"];
            [APIClient sharedClient].accessToken = token;
            block(responseObject,((NSHTTPURLResponse *)task.response).statusCode,nil);
        }else {
            block(nil,((NSHTTPURLResponse *)task.response).statusCode,error);
        }
    }];
}

- (void)requestMemberListWithBlock:(requestBlock)block {

    [[APIClient sharedClient] requestJsonDataWithPath:@"member"
                                           withHeader:nil
                                           withParams:nil
                                                 body:nil
                                       withMethodType:Get
                                             andBlock:^(NSURLSessionDataTask *task, id responseObject, NSUInteger statusCode, NSError *error)
    {

        if (responseObject) {
            block(responseObject,((NSHTTPURLResponse *)task.response).statusCode,nil);
        }else {
            block(responseObject,((NSHTTPURLResponse *)task.response).statusCode,error);
        }

    }];
}

- (void)requestCreateMemeberWithNameDic:(id)params block:(requestBlock)block {

    [[APIClient sharedClient] requestJsonDataWithPath:@"member"
                                           withHeader:nil
                                           withParams:nil
                                                 body:params
                                       withMethodType:Post
                                             andBlock:^(NSURLSessionDataTask *task, id responseObject, NSUInteger statusCode, NSError *error)
    {

        if (responseObject) {
            block(responseObject,((NSHTTPURLResponse *)task.response).statusCode,nil);
        }else {
            block(responseObject,((NSHTTPURLResponse *)task.response).statusCode,error);
        }
        
    }];
}


@end

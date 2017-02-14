//
//  APIClient.h
//  Knock
//
//  Created by RedScor Yuan on 2017/2/11.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

/**
 *  Request API 用的共通HttpMethod 的enum
 */
typedef NS_ENUM(NSInteger, NetworkMethod) {
    /**
     *  GET Method
     */
    Get = 0,
    /**
     *  POST Method
     */
    Post

};

typedef void (^RequestCallBack)(NSURLSessionDataTask *task, id responseObject, NSUInteger statusCode, NSError *error);

@interface APIClient : AFHTTPSessionManager
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;


+ (instancetype)sharedClient;

- (NSURLSessionDataTask *)requestJsonDataWithPath:(NSString *)aPath
                                       withHeader:(NSDictionary *)header
                                       withParams:(NSDictionary *)params
                                             body:(NSDictionary *)body
                                   withMethodType:(NetworkMethod)method
                                         andBlock:(RequestCallBack)block;

#pragma mark - login &reFreshToken
- (void)requestSignInWithBodyDic:(id)params block:(RequestCallBack)block;
@end

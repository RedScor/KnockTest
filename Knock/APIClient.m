//
//  APIClient.m
//  Knock
//
//  Created by RedScor Yuan on 2017/2/11.
//  Copyright © 2017年 RedScor. All rights reserved.
//

#import "APIClient.h"

NSString * const APIBaseURLString =  @"http://52.197.192.141:3443";

@implementation APIClient
static APIClient *_sharedClient = nil;
+ (instancetype)sharedClient {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc]initWithBaseURL:[NSURL URLWithString:APIBaseURLString]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", nil];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.requestSerializer.timeoutInterval = 30;

    return self;

}

- (NSDictionary *)loadDefaultHeader {

    if (!self.accessToken || [self.accessToken length] == 0) {
        return nil;
    }

    NSDictionary *tokenDic = @{@"Authorization":self.accessToken};

    return tokenDic;
    
}

- (NSMutableURLRequest *)settingRequestWithUrl:(NSString *)Url
                                    parameters:(id)parameters
                                    HttpMethod:(NSString *)httpMethod
                                        header:(NSDictionary *)header
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:httpMethod URLString:[NSString stringWithFormat:@"%@/%@",APIBaseURLString,Url] parameters:parameters error:NULL];

    [request setAllHTTPHeaderFields:[self loadDefaultHeader]]; //set default header

    [header enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { //set input header
        [request setValue:obj forHTTPHeaderField:key];
    }];

    return request;
}

- (NSURLSessionDataTask *)requestJsonDataWithPath:(NSString *)aPath
                                       withHeader:(NSDictionary *)header
                                       withParams:(NSDictionary *)params
                                             body:(NSDictionary *)body
                                   withMethodType:(NetworkMethod)method
                                         andBlock:(RequestCallBack)block
{

    aPath = [aPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    switch (method) {
        case Get:
        {
            //所有 Get 请求，增加緩存機制
            NSMutableString *localPath = [aPath mutableCopy];
            if (params) {
                [localPath appendString:params.description];
            }
            return [self getRequest:aPath header:header parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                block(task, responseObject, response.statusCode, nil);

            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"\n===========response===========\n%@:\n%@", aPath, error);
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                block(task, nil, response.statusCode,error);
            }];

        }
            break;
        case Post:
        {
            return [self postRequest:aPath header:header parameters:params body:body success:^(NSURLSessionDataTask *task, id responseObject) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;

                block(task, responseObject, response.statusCode, nil);

            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"\n===========response===========\n%@:\n%@", aPath, error);
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                NSDictionary *errorDic;
                if ([error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey]) {
                    //判斷error 中的 Json Data
                    NSData *errorData = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
                     errorDic = [NSJSONSerialization JSONObjectWithData:errorData
                                                                             options:0
                                                                               error:NULL];
                }
                block(task, nil, response.statusCode,error);
            }];
        }
            break;
        default:
            return nil;
            break;
    }

}

- (NSData *)jsonStringData:(NSDictionary *)dic {

    if ([dic isKindOfClass:[NSData class]]) {
        return (NSData *)dic;
    }
    return [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];

}
#pragma mark - APIs
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                          header:(NSDictionary *)header
                                            body:(NSData *)body
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self settingRequestWithUrl:URLString
                                                    parameters:parameters
                                                    HttpMethod:method
                                                        header:header];
    if (body) {
        [request setHTTPBody:body]; //set body data
    }

    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }

        return nil;
    }

    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(dataTask, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    return dataTask;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler {

    void (^authFailBlock)(NSURLResponse *response, id responseObject, NSError *error) = ^(NSURLResponse *response, id responseObject, NSError *error) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] == 401) {
            NSLog(@"token expire");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                [self requestSignInWithBodyDic:request.HTTPBody block:^(NSURLSessionDataTask *task, id responseObject, NSUInteger statusCode, NSError *error) {

                    NSLog(@"token get");
                    NSURLSessionDataTask *originalDataTask = [super dataTaskWithRequest:request completionHandler:completionHandler];
                    [originalDataTask resume];
                }];
            });
        }else if ([httpResponse statusCode] == 200){
            NSLog(@"get response");
            completionHandler(response, responseObject, error);
        }
    };

    NSURLSessionDataTask *task = [super dataTaskWithRequest:request completionHandler:authFailBlock];
    [task resume];
    return task;

}


- (NSURLSessionDataTask *)getRequest:(NSString *)url
                              header:(NSDictionary *)header
                          parameters:(id)parameters
                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"GET"
                                                        URLString:url
                                                       parameters:parameters
                                                           header:header
                                                             body:nil
                                                          success:success
                                                          failure:failure];

    [dataTask resume];

    return dataTask;
}

- (NSURLSessionDataTask *)postRequest:(NSString *)url
                               header:(NSDictionary *)header
                           parameters:(id)parameters
                                 body:(NSDictionary *)body
                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"POST"
                                                        URLString:url
                                                       parameters:parameters
                                                           header:header
                                                             body: [self jsonStringData:body]
                                                          success:success
                                                          failure:failure];

    [dataTask resume];

    return dataTask;
}

#pragma mark - Login 
- (void)requestSignInWithBodyDic:(id)params block:(RequestCallBack)block {

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:APIBaseURLString parameters:nil error:nil];

    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[self jsonStringData:params]];

    NSURLSessionDataTask *task = [manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {

        if (responseObject) {
            block(task, responseObject, ((NSHTTPURLResponse *)response).statusCode, nil);
        }else {
            block(task, responseObject, ((NSHTTPURLResponse *)response).statusCode, error);
        }
    }];

    [task resume];
}
@end

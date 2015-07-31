//
//  DataAPI.m
//  Instagram
//
//  Created by MS on 7/30/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import "DataAPI.h"
#import "HTTPClient.h"
#import "PersistencyManager.h"
#import "AFNetworking/AFNetworking.h"
#import "Errors.h"

@interface DataAPI ()

@property (strong, nonatomic) HTTPClient *httpClient;
@property (strong, nonatomic) PersistencyManager *persistencyManager;
@property (nonatomic) BOOL isOnline;

@end


@implementation DataAPI


- (id)init
{
    self = [super init];
    if (self) {
        self.httpClient = [[HTTPClient alloc] init];
        self.persistencyManager = [[PersistencyManager alloc] init];
        
        self.isOnline = [[AFNetworkReachabilityManager sharedManager] isReachable];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status > 0) {
                self.isOnline = YES;
            } else {
                self.isOnline = NO;
            }
            
        }];
    }
    
    return self;
}

+ (id)sharedManager
{
    static DataAPI *sharedDataAPI = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataAPI = [[self alloc] init];
        
    });
    return sharedDataAPI;
    
}

- (void)getNextPortionOfImageAndCommentsOfUserID:(NSString *)userID onSuccess:(void (^)(NSArray *))success onFailure:(void (^)(NSError *))failure
{
    if (self.isOnline) {
        [self.httpClient getNextPortionOfImageAndCommentsOfUserID:userID onSuccess:^(NSArray *result) {
            [self.persistencyManager savePhotos:result ofUserID:userID];
            success(result);
        } onFailure:^(NSError *error) {
            failure(error);
        }];
    } else {
        [self.persistencyManager getNextPortionOfImageAndCommentsOfUserID:userID onSuccess:^(NSArray *result) {
            success(result);
        } onFailure:^(NSError *error) {
            failure(error);
        }];
    }
    
    
}

- (void)getImageByURL:(NSURL *)imageURL progressView:(UIProgressView *)progressView onSuccess:(void (^)(UIImage *))success onFailure:(void (^)(NSError *))failure
{
    
    [self.persistencyManager getImageByFilename:[imageURL lastPathComponent] onSuccess:^(UIImage *image) {
        success(image);
    } onFailure:^(NSError *error) {

        [self.httpClient getImageByURL:imageURL progressView:progressView onSuccess:^(UIImage *image) {

            [self.persistencyManager saveImage:image filename:[imageURL lastPathComponent]];
            success(image);
            
        } onFailure:^(NSError *error) {
            failure(error);
        }];
    }];

}

- (void)getUserIDOfLogin:(NSString *)login
               onSuccess: (void (^) (NSString *UserID)) success
               onFailure: (void (^) (NSError *error)) failure
{
    NSString *userID = [self.persistencyManager getUserIDOfLogin:login];
    if (userID == nil) {
        [self.httpClient getUserIDOfLogin:login onSuccess:^(NSString *UserID) {
            [self.persistencyManager saveUserID:UserID ofLogin:login];
            success(UserID);
        } onFailure:^(NSError *error) {
            failure(error);
        }];
        return;
    } else {
        success(userID);
    }
}


- (void)cancelLoadingImageByURL: (NSURL *)url
{
    [self.httpClient cancelLoadingImageByURL:url];
}

@end

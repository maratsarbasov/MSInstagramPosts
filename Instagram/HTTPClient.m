//
//  ParseManager.m
//  Instagram
//
//  Created by MS on 7/28/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import "HTTPClient.h"
#import "AFNetworking/AFNetworking.h"
#import "UIProgressView+AFNetworking.h"
#import "Constants.h"
#import "Photo.h"
#import "Errors.h"

#define SUCCESS_CODE 200

@interface HTTPClient ()
@property (strong, nonatomic) NSString *previousUserID;
@property (strong, nonatomic) NSString *nextURL;

@property (strong, nonatomic) AFHTTPRequestOperationManager *imageOperationManager;
@end

@implementation HTTPClient

- (AFHTTPRequestOperationManager *)imageOperationManager
{
    if (!_imageOperationManager) {
        _imageOperationManager = [AFHTTPRequestOperationManager manager];
    }
    return _imageOperationManager;
}
- (void)getNextPortionOfImageAndCommentsOfUserID: (NSString *)userID
                                   onSuccess: (void (^) (NSArray *result)) success //array of model
                                   onFailure: (void (^) (NSError *error)) failure
{

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"accessToken"];
    if (token == nil) {
        NSError *error = [NSError errorWithDomain:MSErrorDomain code:MSInvalidAccessToken userInfo:nil];
        failure(error);
    }
    
    NSString *query = nil;
    
    
    if ([userID isEqualToString:self.previousUserID]) { //if loading not first portion of this user
        query = self.nextURL;
    } else {
         query = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?access_token=%@&count=%d", userID, token, PORTION];
    }
    
    [manager GET:query parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        NSDictionary *meta = [responseObject objectForKey:@"meta"];
        
        //if error (response code != 200)
        if (![[meta objectForKey:@"code"] isEqualToNumber:[NSNumber numberWithInt:SUCCESS_CODE]]) {
            NSDictionary *details = @{NSLocalizedDescriptionKey : [meta objectForKey:@"error_type"]};
            NSError *error = [NSError errorWithDomain:MSErrorDomain code:MSUnknownError userInfo:details];
            
            if (failure)
                failure(error);
            
            return;
        }
        
        //getting data
        NSArray *data = [responseObject objectForKey:@"data"];
        NSMutableArray *mutableArrayOfPhotos = [NSMutableArray array];
        for (NSDictionary *photo in data) {
            
            Photo *photoObject = [[Photo alloc] initWithServerResponse:photo];
            if (photoObject)
                [mutableArrayOfPhotos addObject:photoObject];
            
        }
        
        NSArray *photos = [NSArray arrayWithArray:mutableArrayOfPhotos];
        

        
        //getting URL for next portion of photos
        NSDictionary *pagination = [responseObject objectForKey:@"pagination"];
        self.nextURL = [pagination objectForKey:@"next_url"];
        self.previousUserID = userID;
        
        if ([photos count] == 0) {
            NSError *error = [NSError errorWithDomain:MSErrorDomain code:MSNoMorePhotos userInfo:nil];
            if (failure)
                failure(error);
            return;
        }
        
        if (success)
            success(photos);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
    }];
}


+ (id)sharedManager
{
    static HTTPClient *sharedParseManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedParseManager = [[self alloc] init];
        
    });
    return sharedParseManager;

}



- (void)getUserIDOfLogin:(NSString *)login
               onSuccess: (void (^) (NSString *UserID)) success
               onFailure: (void (^) (NSError *error)) failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *query = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/search?q=%@&client_id=%@", login,  CLIENTID];
    
    [manager GET:query parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        
        //if response code != 200
        NSDictionary *meta = [responseObject objectForKey:@"meta"];
        if (![[meta objectForKey:@"code"] isEqualToNumber:[NSNumber numberWithInt:SUCCESS_CODE]]) {
            NSDictionary *details = @{NSLocalizedDescriptionKey : [meta objectForKey:@"error_type"]};
            NSError *error = [NSError errorWithDomain:MSErrorDomain code:MSUnknownError userInfo:details];
            
            if (failure)
                failure(error);
            return;
        }
        
        NSArray *data = [result objectForKey:@"data"];
        
        //search for correct user
        for (id obj in data) {
            NSDictionary *userInfo = (NSDictionary *)obj;
            if ([userInfo[@"username"] isEqualToString:login]) {
                NSString *UserID = userInfo[@"id"];
                
                if (success)
                    success(UserID);
                return;
            }
        }
        
        //user not found
        
        NSError *error = [NSError errorWithDomain:MSErrorDomain code:MSUserNotFound userInfo:nil];
        failure(error);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
    }];
}

- (void)getImageByURL: (NSURL *)imageURL
         progressView: (UIProgressView *)progressView
            onSuccess: (void (^) (UIImage *image)) success
            onFailure: (void (^) (NSError *error)) failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [progressView setProgressWithDownloadProgressOfOperation:operation animated:YES];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *resultImage = [UIImage imageWithData:responseObject];
        success(resultImage);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(error);
    }];
    
    [self.imageOperationManager.operationQueue  addOperation:operation];
}

- (void)cancelLoadingImageByURL: (NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        NSArray *operations = self.imageOperationManager.operationQueue.operations;
        for (AFHTTPRequestOperation *operation in operations) {
            NSString *operationUrlPath = operation.request.URL.path;
            if ([[url path] isEqual:operationUrlPath]) {
                [operation cancel];

                
            }
        }
    });

}
@end

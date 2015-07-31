//
//  DataAPI.h
//  Instagram
//
//  Created by MS on 7/30/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DataAPI : NSObject

+ (id)sharedManager;
- (void)getNextPortionOfImageAndCommentsOfUserID: (NSString *)userID
                                       onSuccess: (void (^) (NSArray *result)) success //array of model
                                       onFailure: (void (^) (NSError *error)) failure;

- (void)getImageByURL: (NSURL *)imageURL
         progressView: (UIProgressView *)progressView
            onSuccess: (void (^) (UIImage *image)) success
            onFailure: (void (^) (NSError *error)) failure;

- (void)getUserIDOfLogin:(NSString *)login
               onSuccess: (void (^) (NSString *UserID)) success
               onFailure: (void (^) (NSError *error)) failure;

- (void)cancelLoadingImageByURL: (NSURL *)url;
@end

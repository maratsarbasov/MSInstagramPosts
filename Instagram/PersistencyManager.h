//
//  PersistencyManager.h
//  Instagram
//
//  Created by MS on 7/30/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PersistencyManager : NSObject

- (void)getImageByFilename: (NSString *)filename
            onSuccess: (void (^) (UIImage *image)) success
            onFailure: (void (^) (NSError *error)) failure;
- (void)saveImage: (UIImage *)image filename: (NSString *)filename;
- (NSString *)getUserIDOfLogin: (NSString *)login;
- (void)saveUserID: (NSString *)userID ofLogin: (NSString *)login;
- (void)savePhotos: (NSArray *)photos ofUserID: (NSString *)userID;

- (void)getNextPortionOfImageAndCommentsOfUserID: (NSString *)userID
                                       onSuccess: (void (^) (NSArray *result)) success //array of model
                                       onFailure: (void (^) (NSError *error)) failure;

@end

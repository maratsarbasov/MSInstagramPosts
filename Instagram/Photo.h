//
//  ImageAndComments.h
//  Instagram
//
//  Created by MS on 7/28/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject <NSCoding>
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSArray *comments; //of comments
@property (nonatomic) NSInteger creationTime;
@property (strong, nonatomic) NSString *photoId;

- (id)initWithServerResponse: (NSDictionary *)response;

@end

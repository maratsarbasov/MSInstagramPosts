//
//  Comment.h
//  Instagram
//
//  Created by MS on 7/29/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Comment : NSObject <NSCoding>
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *author;

- (id)initWithAuthor: (NSString *)author Text: (NSString *)text;
@end

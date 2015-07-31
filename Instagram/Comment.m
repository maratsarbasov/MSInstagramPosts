//
//  Comment.m
//  Instagram
//
//  Created by MS on 7/29/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (id)initWithAuthor: (NSString *)author Text: (NSString *)text
{
    self = [super init];
    if (self) {
        self.author = author;
        self.text = text;
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.author forKey:@"author"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
    }
    return self;
}

@end

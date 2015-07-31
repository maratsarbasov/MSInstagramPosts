//
//  ImageAndComments.m
//  Instagram
//
//  Created by MS on 7/28/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import "Photo.h"
#import "Comment.h"
#import "Constants.h"

@implementation Photo

- (id)initWithServerResponse: (NSDictionary *)response
{
    self = [super init];
    if (self) {
        
        //image
        NSDictionary *images = [response objectForKey:@"images"];
        self.imageURL = [NSURL URLWithString:[[images objectForKey:@"standard_resolution"] objectForKey:@"url"]];
        
        //comments
        NSMutableArray *commentsArray = [NSMutableArray array];
        NSArray *comments = [[response objectForKey:@"comments"] objectForKey:@"data"];
        
        //photoId
        self.photoId = [response objectForKey:@"id"];
        
        //getting only 5 latest comments
        int beginCommentIndex = [comments count] - NUMBER_OF_COMMENTS;
        if (beginCommentIndex < 0)
            beginCommentIndex = 0;
        
        for (int i = beginCommentIndex; i < [comments count]; i++) {
            NSDictionary *commentDict = comments[i];
            NSString *text = [commentDict objectForKey:@"text"];
            NSString *author = [[commentDict objectForKey:@"from"] objectForKey:@"username"];
            Comment *comment = [[Comment alloc] initWithAuthor:author Text:text];
            if (comment)
                [commentsArray addObject:comment];
        }
        
        self.comments = [[NSArray alloc] initWithArray:commentsArray];
        
        //creation time
        self.creationTime = [[response objectForKey:@"created_time"] intValue];
        
        
        
        
    }
    return  self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.creationTime = [[aDecoder decodeObjectForKey:@"creationTime"] intValue];
        self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        self.comments = [aDecoder decodeObjectForKey:@"comments"];
        self.photoId = [aDecoder decodeObjectForKey:@"photoId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithInt:self.creationTime] forKey:@"creationTime"];
    [aCoder encodeObject:self.photoId forKey:@"photoId"];
    [aCoder encodeObject:self.imageURL forKey:@"imageURL"];
    [aCoder encodeObject:self.comments forKey:@"comments"];
}



@end

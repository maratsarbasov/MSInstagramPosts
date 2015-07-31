//
//  TableViewCell.m
//  Instagram
//
//  Created by MS on 7/28/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import "InstagramCell.h"
#import "DataAPI.h"



@implementation InstagramCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.photoView.image = nil;
    self.commentsLabel.text = @"";
    self.progressView.progress = 0.0;
    self.progressView.hidden = NO;

}

@end

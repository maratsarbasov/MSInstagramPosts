//
//  TableViewCell.h
//  Instagram
//
//  Created by MS on 7/28/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface InstagramCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) Photo *photo;

@end

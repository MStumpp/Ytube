//
//  APPCommentCell.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPTableCell.h"

@interface APPCommentCell : APPTableCell

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *comment;
@property (copy, nonatomic) UIImage *profilePic;
@property (copy, nonatomic) NSDate *date;
@property BOOL showFullComment;
-(NSUInteger)cellHeightFullComment;

@end

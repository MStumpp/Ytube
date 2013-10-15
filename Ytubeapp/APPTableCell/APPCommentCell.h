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
-(void)setComment:(GDataEntryYouTubeComment*)comment;
-(NSUInteger)cellHeightFullComment;
-(void)setOpen:(BOOL)o;
@end

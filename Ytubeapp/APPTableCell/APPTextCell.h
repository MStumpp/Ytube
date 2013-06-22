//
//  APPTextCell.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPTableCell.h"

@interface APPTextCell : APPTableCell
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) UIImage *textPic;
@property (nonatomic) int numberItems;
@end

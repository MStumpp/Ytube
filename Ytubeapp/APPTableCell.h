//
//  APPTableCell.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import "APPProtocols.h"

@class APPTableCell;

@protocol TouchButtonTableViewCellDelegate;

@interface APPTableCell : UITableViewCell

@property (strong, nonatomic) UIView *tableCellMain;
@property (strong, nonatomic) UIImageView *tableCellSubMenu;

@property (nonatomic, assign) id<TouchButtonTableViewCellDelegate> touchButtonDelegate;
@property (nonatomic, retain) NSIndexPath *touchButtonIndexPath;

- (void)openOnCompletion:(void (^)(BOOL isOpened))callback animated:(BOOL)animated;
- (void)closeOnCompletion:(void (^)(BOOL isClosed))callback animated:(BOOL)animated;
- (BOOL)isOpened;
- (BOOL)isClosed;

- (void)allowToOpen:(BOOL)value;
- (void)mask:(BOOL)value;

@end

@protocol TouchButtonTableViewCellDelegate<NSObject>

@optional

- (void)tableViewCellButtonTouched:(APPTableCell *)cell button:(UIButton*)button indexPath:(NSIndexPath *)indexPath;

@end
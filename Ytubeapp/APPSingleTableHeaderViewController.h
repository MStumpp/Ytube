//
//  APPSingleTableHeaderViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableListViewController.h"

@interface APPSingleTableHeaderViewController : APPSingleTableListViewController <UITableViewHeaderFormViewDelegate>

// header form
@property BOOL downAtTopOnly;
@property int downAtTopDistance;

@property (nonatomic, strong) UITableViewHeaderFormView *tableViewHeaderFormView;

// Should move to some class containing navigation bar specific code
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, retain) NSIndexPath *tmpEditingCell;

@end

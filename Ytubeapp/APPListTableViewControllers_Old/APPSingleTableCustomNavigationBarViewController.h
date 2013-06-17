//
//  APPSingleTableCustomNavigationBarViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableHeaderViewController.h"

@interface APPSingleTableCustomNavigationBarViewController : APPSingleTableHeaderViewController <UITextFieldDelegate>

@property (nonatomic, strong) UITableViewHeaderFormView *tableViewHeaderFormView1;
@property (nonatomic, strong) UITableViewHeaderFormView *tableViewHeaderFormView2;

@property (nonatomic, strong) UITextField *textField;

@end

//
//  APPSingleTableCustomNavigationBarView.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "PervasiveView.h"
#import "APPSingleTableView.h"
#import "UITableViewHeaderFormView.h"

@interface APPSingleTableCustomNavigationBarView : PervasiveView

@end

@protocol APPSingleTableCustomNavigationBarViewDelegate <APPSingleTableViewDelegate, UITableViewHeaderFormViewDelegate>

@required

@property (nonatomic, strong) UITableViewHeaderFormView *tableViewHeaderFormView1;
@property (nonatomic, strong) UITableViewHeaderFormView *tableViewHeaderFormView2;

@end
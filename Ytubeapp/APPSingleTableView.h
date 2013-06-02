//
//  APPSingleTableView.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 09.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "PervasiveView.h"
#import "SSPullToRefreshView.h"
#import "UITableViewSwipeView.h"
#import "UITableViewAtBottomView.h"

@interface APPSingleTableView : PervasiveView

@end

@protocol APPSingleTableViewDelegate <NSObject, UITableViewDataSource, UITableViewDelegate, SSPullToRefreshViewDelegate, UITableViewSwipeViewDelegate, UITableViewAtBottomViewDelegate>

@required

@end

//
//  UITableViewAtBottomView.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.12.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "UITableViewAtBottomView.h"

@interface UITableViewAtBottomView()

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) id<UITableViewAtBottomViewDelegate> delegate;

@property BOOL fired;
@property float currentTableViewHeight;
@property float reload_distance;

@end

@implementation UITableViewAtBottomView

- (id)initWithTableView:(UITableView *)tableView delegate:(id<UITableViewAtBottomViewDelegate>)delegate
{
    if ((self = [self init])) {
        self.tableView = tableView;
        self.delegate = delegate;
        
        self.fired = FALSE;
        self.reload_distance = -100.0;
        
        // add some initial observer
        [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    }
	return self;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"contentSize"]) {
        CGSize contentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
        if (self.currentTableViewHeight = 0.0) {
            self.currentTableViewHeight = contentSize.height;
            [self.tableView removeObserver:self forKeyPath:@"contentSize"];

        } else if (contentSize.height > self.currentTableViewHeight) {
            self.currentTableViewHeight = contentSize.height;
            self.fired = FALSE;
            [self.tableView removeObserver:self forKeyPath:@"contentSize"];
            [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        }
        
    } else if (!self.fired && [keyPath isEqual:@"contentOffset"]) {        
        if (self.tableView.contentSize.height != 0.0 && [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue].y + self.tableView.bounds.size.height - self.tableView.contentInset.bottom > self.tableView.contentSize.height + self.reload_distance) {
            self.fired = TRUE;
            [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
            [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            if ([self.delegate respondsToSelector:@selector(tableViewDidBottom:)])
                [self.delegate tableViewDidBottom:self.tableView];
        }
        
        // http://stackoverflow.com/questions/5137943/how-to-know-when-uitableview-did-scroll-to-bottom
 
    }
    /*else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }*/
}

@end

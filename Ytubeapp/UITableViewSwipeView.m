//
//  UITableViewSwipeView.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.12.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "UITableViewSwipeView.h"

@interface UITableViewSwipeView ()

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) id<UITableViewSwipeViewDelegate> delegate;

@end

@implementation UITableViewSwipeView

- (id)initWithTableView:(UITableView *)tableView delegate:(id<UITableViewSwipeViewDelegate>)delegate
{
    if ((self = [self init])) {
        self.tableView = tableView;
        self.delegate = delegate;
        
        // https://github.com/boctor/idev-recipes/blob/master/SideSwipeTableView/ClasseSideSwipeTableViewController.m
        
        // Setup a right swipe gesture recognizer
        UISwipeGestureRecognizer* rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.tableView addGestureRecognizer:rightSwipeGestureRecognizer];
        
        // Setup a left swipe gesture recognizer
        UISwipeGestureRecognizer* leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.tableView addGestureRecognizer:leftSwipeGestureRecognizer];
    }
	return self;
}

// Handle a left or right swipe
- (void)swipe:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer && recognizer.state == UIGestureRecognizerStateEnded)
    {
        // Get the table view cell where the swipe occured
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];

        BOOL swipe = YES;
        if ([recognizer direction] == UISwipeGestureRecognizerDirectionLeft) {
            if ([self.delegate respondsToSelector:@selector(tableViewSwipeViewCanSwipeLeft:rowAtIndexPath:)]) {
                if (![self.delegate tableViewSwipeViewCanSwipeLeft:self.tableView rowAtIndexPath:indexPath]) {
                    swipe = NO;
                }
            }
            
            if (swipe) {
                if ([self.delegate respondsToSelector:@selector(tableViewSwipeViewDidSwipeLeft:rowAtIndexPath:)])
                    [self.delegate tableViewSwipeViewDidSwipeLeft:self.tableView rowAtIndexPath:indexPath];
            }
        }
            
        if ([recognizer direction] == UISwipeGestureRecognizerDirectionRight) {
            if ([self.delegate respondsToSelector:@selector(tableViewSwipeViewCanSwipeRight:rowAtIndexPath:)]) {
                if (![self.delegate tableViewSwipeViewCanSwipeRight:self.tableView rowAtIndexPath:indexPath]) {
                    swipe = NO;
                }
            }
            
            if (swipe) {
                if ([self.delegate respondsToSelector:@selector(tableViewSwipeViewDidSwipeRight:rowAtIndexPath:)])
                    [self.delegate tableViewSwipeViewDidSwipeRight:self.tableView rowAtIndexPath:indexPath];
            }
        }
    }
}

@end

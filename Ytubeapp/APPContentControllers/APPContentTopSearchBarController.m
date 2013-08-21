//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopSearchBarController.h"

@interface APPContentTopSearchBarController()
@property NSString *query;
@end

@implementation APPContentTopSearchBarController

-(id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_search"];

        [self toDefaultStateForce];
    }
    return self;
}

-(void)loadView
{
    [super loadView];

    UIControl *subtopbarContainer = [[UIControl alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_back"]]];
    [subtopbarContainer addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sub_top_bar_search_field_small"]]];

    // add text field to search bar
    self.search = [[UITextField alloc] initWithFrame:CGRectMake(38.0, 9.0, 210.0, 26.0)];
    self.search.placeholder = @"Enter search";
    [self.search setDelegate:self];
    [self.search setReturnKeyType:UIReturnKeySearch];
    [subtopbarContainer addSubview:self.search];

    // add cancel button to search bar
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 6, 71, 30)];
    [self.cancelButton addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateNormal];
    [self.cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateHighlighted];
    [self.cancelButton setImage:[UIImage imageNamed:@"sub_top_bar_button_cancel"] forState:UIControlStateSelected];
    [subtopbarContainer addSubview:self.cancelButton];

    [self.tableViewHeaderFormView setHeaderView:subtopbarContainer];
}

-(void)cancelSearch
{
    if ([self.search isFirstResponder]) {
        self.search.text = @"";
        [self.search resignFirstResponder];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self.search resignFirstResponder];
    self.query = textField.text;
    [self tableView:self.tableView reloadDataConcreteForShowMode:tDefault withPrio:tVisibleload];
    return YES;
}

-(Query*)tableView:(APPTableView*)tableView reloadDataConcreteForShowMode:(int)mode withPrio:(int)p
{
    return [APPQueryHelper queryVideos:self.query showMode:mode withPrio:p delegate:tableView];
}

-(Query*)tableView:(APPTableView*)tableView loadMoreDataConcreteForShowMode:(int)mode forFeed:(GDataFeedBase*)feed withPrio:(int)p
{
    return [APPQueryHelper fetchMore:feed showMode:mode withPrio:p delegate:tableView];
}

@end
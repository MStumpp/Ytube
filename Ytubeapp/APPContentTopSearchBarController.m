//
// Created by Matthias Stumpp on 18.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPContentTopSearchBarController.h"

@implementation APPContentTopSearchBarController

- (id)init
{
    self = [super init];
    if (self) {
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_search"];

        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
        }] onViewState:tDidLoad do:^() {
            [this toShowMode:tDefault];
        }];

        [self toInitialState];
    }
    return self;
}

- (void)loadView
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.search resignFirstResponder];
    [self reloadData];
    return YES;
}

-(QueryTicket*)reloadDataConcreteForShowMode:(int)mode withPrio:(int)prio
{
    return [self.contentManager mostPopular:mode prio:prio context:[NSNumber numberWithInt:mode] delegate:self didFinishSelector:@selector(reloadDataResponse:)];
}

-(QueryTicket*)loadMoreDataConcreteForShowMode:(int)mode withPrio:(int)prio
{
    if ([self currentFeedForShowMode:mode])
        return [self.contentManager loadMoreData:[self currentFeedForShowMode:mode] prio:prio context:[NSNumber numberWithInt:mode] delegate:self didFinishSelector:@selector(loadMoreDataResponse:)];
    return nil;
}

@end
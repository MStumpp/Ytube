//
//  APPCommentsDetailViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 24.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPCommentsDetailViewController.h"
#import "NSDate+TimeAgo.h"

@interface APPCommentsDetailViewController ()

@end

@implementation APPCommentsDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.contentManager = [APPContentManager classInstance];
    }
    return self;
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
    
    // configure navigationbar
    [self setNavigationbarBackgroundImage:[UIImage imageNamed:@"sub_top_bar_back"]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 49.0, 44.0);
    [button setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_up"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_down"] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"sub_top_bar_arrow_left_down"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(276, 0, 44, 44)];
    [addButton addTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[UIImage imageNamed:@"sub_top_bar_plus_up"] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"sub_top_bar_plus_down"] forState:UIControlStateHighlighted];
    [addButton setImage:[UIImage imageNamed:@"sub_top_bar_plus_down"] forState:UIControlStateSelected];
    [addButton setTag:tAdd];
    UIBarButtonItem* addButtonBarItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:addButtonBarItem, nil];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 18.0, 200.0, 12.0)];
    [self.nameLabel setFont:[UIFont fontWithName:@"Nexa Bold" size:10]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    [self.nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.nameLabel];
    
    self.timeagoLabel = [[UILabel alloc] initWithFrame:CGRectMake(235.0, 18.0, 100.0, 12.0)];
    [self.timeagoLabel setFont:[UIFont fontWithName:@"Nexa Bold" size:10]];
    [self.timeagoLabel setTextColor:[UIColor grayColor]];
    [self.timeagoLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.timeagoLabel];
    
    self.profilePicImage = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 36.0, 48.0, 48.0)];
    [self.view addSubview:self.profilePicImage];
    
    self.commentLabel = [[UITextView alloc] initWithFrame:CGRectMake(85.0, 36.0, 215.0, 400.0)];
    [self.commentLabel setFont:[UIFont fontWithName: @"Nexa Light" size:12]];
    [self.commentLabel setTextColor:[UIColor whiteColor]];
    self.commentLabel.editable = FALSE;
    self.commentLabel.scrollEnabled = TRUE;
    [self.commentLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.commentLabel];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.nameLabel.text = [[[self.comment authors] objectAtIndex:0] name];
    self.commentLabel.text = [[self.comment content] stringValue];
    self.timeagoLabel.text = [[[self.comment updatedDate] date] timeAgo];
        
    [self.contentManager imageForComment:self.comment callback:^(UIImage *image){
        if (image) {
            [self.profilePicImage setImage:image];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)subtopbarButtonPress:(UIButton*)sender
{

}

- (void)setNavigationbarBackgroundImage:(UIImage*) image
{
    // iOS >= 5.0
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        // iOS < 5.0
    } else {
        [self.navigationController.navigationBar insertSubview:[[UIImageView alloc] initWithImage:image] atIndex:1];
    }
}

@end

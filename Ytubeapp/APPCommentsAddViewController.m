//
//  APPCommentsAddViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 25.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPCommentsAddViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface APPCommentsAddViewController ()

@end

@implementation APPCommentsAddViewController

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
        
    self.profilePicImage = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 36.0, 48.0, 48.0)];
    [self.view addSubview:self.profilePicImage];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(85.0, 36.0, 215.0, 200.0)];
    [self.textField setFont:[UIFont fontWithName: @"Nexa Light" size:12]];
    [self.textField setTextColor:[UIColor blackColor]];
    self.textField.clipsToBounds = YES;
    self.textField.layer.cornerRadius = 10.0f;
    [self.textField setBackgroundColor:[UIColor whiteColor]];
    [self.textField setDelegate:self];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [self.view addSubview:self.textField];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [[APPContentManager classInstance] userProfile:^(GDataEntryYouTubeUserProfile *user) {
        if (user) {
            self.nameLabel.text = [[[user authors] objectAtIndex:0] name];
            [[APPContentManager classInstance] imageForUser:user callback:^(UIImage *image) {
                if (image) {
                    [self.profilePicImage setImage:image];
                }
            }];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    GDataEntryYouTubeComment *comment = [[GDataEntryYouTubeComment alloc] init];
    [comment setContentWithString:self.textField.text];
    NSLog(@"test");
    [self.contentManager addComment:comment ToVideo:self.video callback:^(GDataEntryYouTubeComment *comm) {
        /*if (comment)
            self.textField.text = @"";
            [self.navigationController popToRootViewControllerAnimated:YES];*/
    }];
    self.textField.text = @"";
    [self.navigationController popToRootViewControllerAnimated:YES];
    return YES;
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

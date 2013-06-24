//
//  APPTableCell.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 19.11.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPTableCell.h"
#import "APPTableView.h"
#import <QuartzCore/QuartzCore.h>

@interface APPTableCell ()
@property (strong, nonatomic) CALayer *menuSubMenuMask;
@property (strong, nonatomic) UIImageView *shadowImage;
@property (strong, nonatomic) UIImageView *bottomBack;
@property BOOL allowToOpen;
@end

@implementation APPTableCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // sub menu
        self.tableCellSubMenu = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 88.0)];
        [self.tableCellSubMenu setImage:[UIImage imageNamed:@"video_cell_menu_back"]];
        [self.contentView addSubview:self.tableCellSubMenu];
        
        self.menuSubMenuMask = [CALayer layer];
        self.menuSubMenuMask.backgroundColor = [[UIColor whiteColor] CGColor];
        self.menuSubMenuMask.frame = CGRectMake(320.0, 0.0, 320.0, 88.0);
        self.tableCellSubMenu.layer.mask = self.menuSubMenuMask;
        self.tableCellSubMenu.layer.masksToBounds = YES;
        
        // table cell
        self.tableCellMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 88.0)];
        //self.tableCellMain = [[UIImageView alloc] init];
        [self.tableCellMain setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.tableCellMain];

        UIImageView *topBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 1.0)];
        [topBack setImage:[UIImage imageNamed:@"video_cell_back_normal_top"]];
        [self.tableCellMain addSubview:topBack];

        self.bottomBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 1.0)];
        [self.bottomBack setImage:[UIImage imageNamed:@"video_cell_back_normal_bottom"]];
        [self.tableCellMain addSubview:self.bottomBack];
        
        // mask image
        self.shadowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 88.0)];
        [self.shadowImage setImage:[UIImage imageNamed:@"video_cell_front_hide"]];
        [self.tableCellMain addSubview:self.shadowImage];
        [self mask:FALSE];
        
        // customize accessory icon
        //self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_cell_icon_right.png"]];
        
        self.selectionStyle = style;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self closeOnCompletion:nil animated:NO];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.tableCellMain.frame;
    rect.size.height = self.bounds.size.height;
    self.tableCellMain.frame = rect;
    
    rect = self.bottomBack.frame;
    rect.origin.y = self.tableCellMain.frame.size.height - 1.0;
    self.bottomBack.frame = rect;
}

-(void)openOnCompletion:(void (^)(BOOL isOpened))callback animated:(BOOL)animated
{
    if (self.allowToOpen) {
    
        if (self.tableCellMain.frame.origin.x == 0)
        {            
            CGPoint toValue1 = CGPointMake(160.0, self.menuSubMenuMask.position.y);
            CGPoint toValue2 = CGPointMake(-160.0, self.tableCellMain.layer.position.y);
            
            if (animated) {
                [CATransaction begin]; {
                    [CATransaction setCompletionBlock:^{                    
                        if (callback) {
                            callback(TRUE);
                        }
                    }];
                    
                    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
                    animation1.fromValue = [NSValue valueWithCGPoint:self.menuSubMenuMask.position];
                    animation1.toValue = [NSValue valueWithCGPoint:toValue1];
                    animation1.duration = 0.2f;
                    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    [self.menuSubMenuMask setPosition:toValue1];
                        
                    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
                    animation2.fromValue = [NSValue valueWithCGPoint:self.tableCellMain.layer.position];
                    animation2.toValue = [NSValue valueWithCGPoint:toValue2];
                    animation2.duration = 0.2f;
                    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    [self.tableCellMain.layer setPosition:toValue2];
                
                    [self.menuSubMenuMask addAnimation:animation1 forKey:@"animatePosition1"];
                    [self.tableCellMain.layer addAnimation:animation2 forKey:@"animatePosition2"];
                    
                } [CATransaction commit];
                
            } else {
                [self.menuSubMenuMask setPosition:toValue1];
                [self.tableCellMain.layer setPosition:toValue2];
                
                if (callback)
                    callback(TRUE);
            }
            
        } else {
            if (callback)
                callback(TRUE);
        }
        
    } else {
        if (callback)
            callback(FALSE);
    }
}

-(void)closeOnCompletion:(void (^)(BOOL isClosed))callback animated:(BOOL)animated
{
    if (self.tableCellMain.frame.origin.x == -320.0)
    {
        CGPoint toValue1 = CGPointMake(480.0, self.menuSubMenuMask.position.y);
        CGPoint toValue2 = CGPointMake(160.0, self.tableCellMain.layer.position.y);
        
        if (animated) {
            [CATransaction begin]; {
                [CATransaction setCompletionBlock:^{
                    if (callback) {
                        callback(TRUE);
                    }
                }];
                
                CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
                animation1.fromValue = [NSValue valueWithCGPoint:self.menuSubMenuMask.position];
                animation1.toValue = [NSValue valueWithCGPoint:toValue1];
                animation1.duration = 0.2f;
                animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [self.menuSubMenuMask setPosition:toValue1];
                
                CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
                animation2.fromValue = [NSValue valueWithCGPoint:self.tableCellMain.layer.position];
                animation2.toValue = [NSValue valueWithCGPoint:toValue2];
                animation2.duration = 0.2f;
                animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [self.tableCellMain.layer setPosition:toValue2];
                
                [self.menuSubMenuMask addAnimation:animation1 forKey:@"animatePosition1"];
                [self.tableCellMain.layer addAnimation:animation2 forKey:@"animatePosition2"];
                
            } [CATransaction commit];
            
        } else {
            [self.menuSubMenuMask setPosition:toValue1];
            [self.tableCellMain.layer setPosition:toValue2];
            
            if (callback)
                callback(TRUE);
        }
    } else {
        if (callback)
            callback(TRUE);
    }
}

/*- (void)open:(BOOL)arg callback:(void (^)(void))callback
{
    if (arg && self.allowToOpen) {
        if (self.tableCellMain.frame.origin.x == 0)
        {
            CAAnimationGroup *theGroup = [CAAnimationGroup animation];
            
            CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
            animation1.fromValue = [self.menuSubMenuMask valueForKey:@"position"];
            animation1.toValue = [NSValue valueWithCGPoint:CGPointMake(160.0, 44.0)];
            [self.menuSubMenuMask setPosition:CGPointMake(160.0, 44.0)];
                        
            CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"frame"];
            animation2.fromValue = [self.tableCellMain.layer valueForKey:@"frame"];
            CGRect point2 = CGRectMake(-320.0, self.tableCellMain.frame.origin.y, self.tableCellMain.frame.size.width, self.tableCellMain.frame.size.height);
            animation2.toValue = [NSValue valueWithCGRect:point2];
            [self.tableCellMain.layer setFrame:point2];
                
            theGroup.duration = .5;
            theGroup.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
            theGroup.animations = [NSArray arrayWithObjects:animation1, animation2, nil];
            
            [self.menuSubMenuMask addAnimation:theGroup forKey:@"animatePosition"];
        }
    
    } else {
        if (self.tableCellMain.frame.origin.x != 0.0)
        {
            CAAnimationGroup *theGroup = [CAAnimationGroup animation];
            
            CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
            animation1.fromValue = [self.menuSubMenuMask valueForKey:@"position"];
            CGPoint point1 = CGPointMake(480.0, 44.0);
            animation1.toValue = [NSValue valueWithCGPoint:point1];
            [self.menuSubMenuMask setPosition:point1];
            
            CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"frame"];
            animation2.fromValue = [self.tableCellMain.layer valueForKey:@"frame"];
            CGRect point2 = CGRectMake(0.0, self.tableCellMain.frame.origin.y, self.tableCellMain.frame.size.width, self.tableCellMain.frame.size.height);
            animation2.toValue = [NSValue valueWithCGRect:point2];
            [self.tableCellMain.layer setFrame:point2];
            
            theGroup.duration = .5;
            theGroup.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
            theGroup.animations = [NSArray arrayWithObjects:animation1, animation2, nil];
            
            [self.menuSubMenuMask addAnimation:theGroup forKey:@"animatePosition"];
        }
    }
    if (callback)
        callback();
}*/

-(BOOL)isOpened
{
    if (self.tableCellMain.frame.origin.x == 0)
        return FALSE;
    return TRUE;
}

-(BOOL)isClosed
{
    return ![self isOpened];
}

-(void)allowToOpen:(BOOL)value
{
    self.allowToOpen = value;
}

-(void)mask:(BOOL)value
{
    if (value)
        [self.shadowImage setHidden:NO];
    else
        [self.shadowImage setHidden:YES];
}

// customize delete icon

/*- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    if ((state & UITableViewCellStateShowingEditControlMask) == UITableViewCellStateShowingEditControlMask) {
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellEditControl"]) {
                subview.hidden = YES;
                subview.alpha = 0.0;
            }
        }
    }
}*/

/*- (void)didTransitionToState:(UITableViewCellStateMask)state
{
    [super didTransitionToState:state];
    if (state == UITableViewCellStateShowingEditControlMask || state == UITableViewCellStateShowingEditControlMask) {
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellEditControl"]) {
                UIView *deleteButtonView = (UIView *)[subview.subviews objectAtIndex:0];
                CGRect f = deleteButtonView.frame;
                f.origin.x -= 20;
                deleteButtonView.frame = f;
                
                subview.hidden = NO;
                
                //[UIView beginAnimations:@"anim" context:nil];
                subview.alpha = 1.0;
                //[UIView commitAnimations];
                
                //NSLog(@"test");
                
                deleteButtonView 
                                
                UIImageView *editButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 88)];
                [editButton setImage:[UIImage imageNamed:@"video_cell_cross"]];
                [[subview.subviews objectAtIndex:0] addSubview:editButton];
            }
        }
    }
}*/

@end

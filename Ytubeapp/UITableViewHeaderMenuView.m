//
//  UITableViewHeaderMenuView.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 31.12.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "UITableViewHeaderMenuView.h"
#import <QuartzCore/QuartzCore.h>

typedef void(^UITableViewHeaderMenuViewCallback)(BOOL val);

@interface UITableViewHeaderMenuView ()

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) UIView *view;
@property (nonatomic, assign) id<UITableViewHeaderMenuViewDelegate> delegate;

@property (nonatomic, strong) UIControl *tmp_view;
@property (nonatomic, retain) UIView *slider;
@property BOOL downAtTopOnly;
@property int downAtTopDistance;

@property (nonatomic, retain) CAAnimationGroup *downAnimation;
@property (nonatomic, retain) CAAnimationGroup *upAnimation;
@property (nonatomic, copy) UITableViewHeaderMenuViewCallback callback;
@end

@implementation UITableViewHeaderMenuView

- (id)initWithTableView:(UITableView *)tableView view:(UIView*)view delegate:(id<UITableViewHeaderMenuViewDelegate>)delegate
{
    if ((self = [self init])) {
        self.tableView = tableView;
        self.view = view;
        self.delegate = delegate;
        
        self.downAtTopOnly = TRUE;
        self.downAtTopDistance = 40;
                
        self.tmp_view = [[UIControl alloc] initWithFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height)];
        self.tmp_view.clipsToBounds = TRUE;
        self.slider = [[UIControl alloc] initWithFrame:CGRectMake(0.0, -view.frame.size.height, self.tmp_view.frame.size.width, self.tmp_view.frame.size.height+view.frame.size.height)];
        [self.slider addSubview:view];
        UIView *superView = [tableView superview];
        [tableView removeFromSuperview];
        tableView.frame = CGRectMake(0.0, view.frame.size.height, tableView.frame.size.width, tableView.frame.size.height);
        [self.slider addSubview:tableView];
        
        // add some observer
        [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];

        [self.tmp_view addSubview:self.slider];
        [superView addSubview:self.tmp_view];
    }
	return self;
}

- (void)down:(void (^)(BOOL isDown))callback
{
    if (self.slider.frame.origin.y != 0.0) {

        if ([self.delegate respondsToSelector:@selector(tableViewHeaderMenuViewCanShow:)]) {
            if (![self.delegate tableViewHeaderMenuViewCanShow:self]) {
                if (callback)
                    callback(FALSE);
                return;
            }
        }
        
        // Possibly rework callback handling by using CATransaction with completion handler
        // http://stackoverflow.com/questions/11515647/objective-c-cabasicanimation-applying-changes-after-animation
        self.callback = callback;
    
        self.downAnimation = [CAAnimationGroup animation];
        
        CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
        animation1.fromValue = [self.slider.layer valueForKey:@"position"];
        animation1.toValue = [NSValue valueWithCGPoint:CGPointMake(self.slider.frame.size.width/2.0, self.slider.frame.size.height/2.0)];
        [self.slider.layer setPosition:CGPointMake(self.slider.frame.size.width/2.0, self.slider.frame.size.height/2.0)];
                
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"frame"];
        animation2.fromValue = [self.tableView valueForKey:@"frame"];
        animation2.toValue = [NSValue valueWithCGRect:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-self.view.frame.size.height)];
        [self.tableView.layer setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-self.view.frame.size.height)];
        
        self.downAnimation.duration = .2f;
        self.downAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        self.downAnimation.animations = [NSArray arrayWithObjects:animation1, animation2, nil];
        self.downAnimation.delegate = self;
        
        if ([self.delegate respondsToSelector:@selector(tableViewHeaderMenuViewWillShow:)])
            [self.delegate tableViewHeaderMenuViewWillShow:self];
       
        [self.slider.layer addAnimation:self.downAnimation forKey:@"animatePosition"];
    
    } else {
        if (callback)
            callback(TRUE);
    }
}

- (void)up:(void (^)(BOOL isUp))callback
{
    if (self.slider.frame.origin.y != -self.view.frame.size.height) {
    
        if ([self.delegate respondsToSelector:@selector(tableViewHeaderMenuViewCanHide:)]) {
            if (![self.delegate tableViewHeaderMenuViewCanHide:self]) {
                if (callback)
                    callback(FALSE);
                return;
            }
        }
        
        self.callback = callback;
    
        self.upAnimation = [CAAnimationGroup animation];
        
        CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
        animation1.fromValue = [self.slider.layer valueForKey:@"position"];
        animation1.toValue = [NSValue valueWithCGPoint:CGPointMake(self.slider.frame.size.width/2.0, self.slider.frame.size.height/2.0-self.view.frame.size.height)];
        [self.slider.layer setPosition:CGPointMake(self.slider.frame.size.width/2.0, self.slider.frame.size.height/2.0-self.view.frame.size.height)];
        
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"frame"];
        animation2.fromValue = [self.tableView valueForKey:@"frame"];
        animation2.toValue = [NSValue valueWithCGRect:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height+self.view.frame.size.height)];
        [self.tableView.layer setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height+self.view.frame.size.height)];
        
        self.upAnimation.duration = .2f;
        self.upAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        self.upAnimation.animations = [NSArray arrayWithObjects:animation1, animation2, nil];
        self.upAnimation.delegate = self;
        
        if ([self.delegate respondsToSelector:@selector(tableViewHeaderMenuViewWillHide:)])
            [self.delegate tableViewHeaderMenuViewWillHide:self];
        
        [self.slider.layer addAnimation:self.upAnimation forKey:@"animatePosition"];
            
    } else {
        if (callback)
            callback(TRUE);
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (flag) {
        if (theAnimation == self.downAnimation) {
            if ([self.delegate respondsToSelector:@selector(tableViewHeaderMenuViewDidShow:)])
                [self.delegate tableViewHeaderMenuViewDidShow:self];
        } else {
            if ([self.delegate respondsToSelector:@selector(tableViewHeaderMenuViewDidHide:)])
                [self.delegate tableViewHeaderMenuViewDidHide:self];
        }
            
        if (self.callback) {
            self.callback(TRUE);
            self.callback = nil;
        }
    }
}

- (void)downAtTopOnly:(BOOL)val
{
    self.downAtTopOnly = val;
}

- (BOOL)isDown
{
    if (self.slider.frame.origin.y == 0.0)
        return TRUE;
    return FALSE;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"contentOffset"]) {
        CGPoint newContentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint oldContentOffset = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];            
        if (oldContentOffset.y < newContentOffset.y && [self isDown] && newContentOffset.y > self.downAtTopDistance) {
            [self up:NULL];
        } else if (oldContentOffset.y > newContentOffset.y && ![self isDown] && (self.downAtTopOnly ? (newContentOffset.y < self.downAtTopDistance) : (newContentOffset.y + self.tableView.bounds.size.height - self.tableView.contentInset.bottom < (self.tableView.contentSize.height - self.downAtTopDistance)))) {
            [self down:NULL];
        }
        
        //if((newVal.y >= 0.0) && (newVal.y <= self.tableView.contentSize.height)) {
        //}
            
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
} 

@end

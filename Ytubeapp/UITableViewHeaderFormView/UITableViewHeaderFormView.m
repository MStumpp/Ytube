//
//  UITableViewHeaderFormView.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 15.12.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "UITableViewHeaderFormView.h"
#import <QuartzCore/QuartzCore.h>

@interface UITableViewHeaderFormView ()

@property (nonatomic, assign) UIView *_rootView;
@property CGFloat initialHeightRootView;
@property (nonatomic, assign) UIView *_headerView;
@property (nonatomic, assign) id<UITableViewHeaderFormViewDelegate> _delegate;

@end

@implementation UITableViewHeaderFormView

- (id)initWithRootView:(UIView *)rootView headerView:(UIView*)headerView delegate:(id<UITableViewHeaderFormViewDelegate>)delegate
{
    if (!rootView)
        return NULL;
    
    self = [super init];
    if (self)
    {
        self._rootView = rootView;
        self._delegate = delegate;

        self.initialHeightRootView = self._rootView.frame.size.height;
        self.frame = CGRectMake(self._rootView.frame.origin.x, self._rootView.frame.origin.y, self._rootView.frame.size.width, self._rootView.frame.size.height);
        self.clipsToBounds = TRUE;
        
        if (headerView)
            [self setHeaderView:headerView];
        
        UIView *superView = [self._rootView superview];
        self._rootView.frame = CGRectMake(0.0, 0.0, self._rootView.frame.size.width, self._rootView.frame.size.height);
        [self addSubview:self._rootView];
        if (superView)
            [superView addSubview:self];
    }
    return self;
}

- (void)setHeaderView:(UIView*)headerView
{
    if (!headerView)
        return;
        
    BOOL wasShown = [self isHeaderShown];
    
    [self hideOnCompletion:^(BOOL isHidden) {
        if (isHidden) {
            if (self._headerView)
                [self._headerView removeFromSuperview];
            
            self._headerView = headerView;
            self._headerView.frame = CGRectMake(0.0, -self._headerView.frame.size.height, self._headerView.frame.size.width, self._headerView.frame.size.height);
            [self addSubview:self._headerView];
            
            if (wasShown)
                [self showOnCompletion:nil animated:YES];
        }
    } animated:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    CGFloat newHeightRootView;
    if (self._headerView && [self isHeaderShown])
        newHeightRootView = self.frame.size.height - self._headerView.frame.size.height;
    else
        newHeightRootView = self.frame.size.height;
    
    if (newHeightRootView > self.initialHeightRootView)
        newHeightRootView = self.initialHeightRootView;
    
    self._rootView.frame = CGRectMake(self._rootView.frame.origin.x, self._rootView.frame.origin.y, self._rootView.frame.size.width, newHeightRootView);
}

- (void)showOnCompletion:(void (^)(BOOL isShown))callback animated:(BOOL)animated;
{
    if (self._headerView && self._headerView.frame.origin.y != 0.0) {
        
        if ([self._delegate respondsToSelector:@selector(tableViewHeaderFormViewShouldShow:)]) {
            if (![self._delegate tableViewHeaderFormViewShouldShow:self]) {
                if (callback)
                    callback(FALSE);
                return;
            }
        }
        
        CGPoint toValue1 = CGPointMake(self._headerView.layer.position.x, self._headerView.layer.position.y+self._headerView.layer.bounds.size.height);
        CGPoint toValue2 = CGPointMake(self._rootView.layer.position.x, self._rootView.layer.position.y+self._headerView.layer.bounds.size.height/2);
        CGRect toValue3 = CGRectMake(self._rootView.layer.bounds.origin.x, self._rootView.layer.bounds.origin.y, self._rootView.layer.bounds.size.width, self._rootView.layer.bounds.size.height-self._headerView.layer.bounds.size.height);

        if (animated) {
            
            //NSLog(@"log 1");
            
            __block BOOL done = NO;
            [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    //NSLog(@"log 2");

                    if ([self._delegate respondsToSelector:@selector(tableViewHeaderFormViewDidShow:)])
                        [self._delegate tableViewHeaderFormViewDidShow:self];
                    
                    //NSLog(@"log 3");

                    if (callback)
                        callback(TRUE);
                    
                    //NSLog(@"log 4");
                    
                    done = YES;
                    return;
                }];

                CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
                animation1.fromValue = [NSValue valueWithCGPoint:self._headerView.layer.position];
                animation1.toValue = [NSValue valueWithCGPoint:toValue1];
                animation1.duration = 0.3f;
                animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [self._headerView.layer setPosition:toValue1];
                
                //CAAnimationGroup *downAnimation2 = [CAAnimationGroup animation];
                
                CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
                animation2.fromValue = [NSValue valueWithCGPoint:self._rootView.layer.position];
                animation2.toValue = [NSValue valueWithCGPoint:toValue2];
                animation2.duration = 0.3f;
                animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                //animation2.removedOnCompletion = NO;
                //animation2.fillMode = kCAFillModeForwards;
                [self._rootView.layer setPosition:toValue2];
                
                CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"bounds"];
                animation3.fromValue = [NSValue valueWithCGRect:self._rootView.layer.bounds];
                animation3.toValue = [NSValue valueWithCGRect:toValue3];
                animation3.duration = 0.3f;
                animation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                //animation3.removedOnCompletion = NO;
                //animation3.fillMode = kCAFillModeForwards;
                [self._rootView.layer setBounds:toValue3];
            
                /*downAnimation2.duration = 0.2f;
                downAnimation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                downAnimation2.animations = [NSArray arrayWithObjects:animation2, animation3, nil];
                downAnimation2.removedOnCompletion = NO;
                downAnimation2.fillMode = kCAFillModeForwards;*/

                if ([self._delegate respondsToSelector:@selector(tableViewHeaderFormViewWillShow:)])
                    [self._delegate tableViewHeaderFormViewWillShow:self];

                //NSLog(@"log 5");
                
                [self._headerView.layer addAnimation:animation1 forKey:@"animatePosition"];
                [self._rootView.layer addAnimation:animation2 forKey:@"animatePosition2"];
                [self._rootView.layer addAnimation:animation3 forKey:@"animateBounds"];
                
                //NSLog(@"log 6");
                
            [CATransaction commit];

            if (!callback) {
                while (done == NO)
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                return;
            }

        } else {
            [self._headerView.layer setPosition:toValue1];
            [self._rootView.layer setPosition:toValue2];
            [self._rootView.layer setBounds:toValue3];
            
            if (callback)
                callback(TRUE);
            return;
        }
        
    } else {
        if (callback)
            callback(TRUE);
        return;
    }
}

- (void)hideOnCompletion:(void (^)(BOOL isHidden))callback animated:(BOOL)animated;
{
    if (self._headerView && self._headerView.frame.origin.y != -self._headerView.frame.size.height) {
        
        if ([self._delegate respondsToSelector:@selector(tableViewHeaderFormViewShouldHide:)]) {
            if (![self._delegate tableViewHeaderFormViewShouldHide:self]) {
                if (callback)
                    callback(FALSE);
                return;
            }
        }
        
        CGPoint toValue1 = CGPointMake(self._headerView.layer.position.x, self._headerView.layer.position.y-self._headerView.layer.bounds.size.height);
        CGPoint toValue2 = CGPointMake(self._rootView.layer.position.x, self._rootView.layer.position.y-self._headerView.layer.bounds.size.height/2);
        CGRect toValue3 = CGRectMake(self._rootView.layer.bounds.origin.x, self._rootView.layer.bounds.origin.y, self._rootView.layer.bounds.size.width, self._rootView.layer.bounds.size.height+self._headerView.layer.bounds.size.height);
        
        if (animated) {
            __block BOOL done = NO;
            [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    if ([self._delegate respondsToSelector:@selector(tableViewHeaderFormViewDidHide:)])
                        [self._delegate tableViewHeaderFormViewDidHide:self];
                    
                    /*if (callback) {
                        callback(TRUE);
                        return;

                    } else {
                        done = YES;
                    }*/
                    
                    if (callback)
                        callback(TRUE);
                    
                    done = YES;
                    return;
                }];
                
                CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
                animation1.fromValue = [NSValue valueWithCGPoint:self._headerView.layer.position];
                animation1.toValue = [NSValue valueWithCGPoint:toValue1];
                //self.upAnimation1.delegate = self;
                animation1.duration = 0.3f;
                animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [self._headerView.layer setPosition:toValue1];
                            
                //CAAnimationGroup *upAnimation2 = [CAAnimationGroup animation];
                
                CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
                animation2.fromValue = [NSValue valueWithCGPoint:self._rootView.layer.position];
                animation2.toValue = [NSValue valueWithCGPoint:toValue2];
                animation2.duration = 0.3f;
                animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                //animation2.removedOnCompletion = NO;
                //animation2.fillMode = kCAFillModeForwards;
                [self._rootView.layer setPosition:toValue2];
                
                CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"bounds"];
                animation3.fromValue = [NSValue valueWithCGRect:self._rootView.layer.bounds];
                animation3.toValue = [NSValue valueWithCGRect:toValue3];
                animation3.duration = 0.3f;
                animation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                //animation3.removedOnCompletion = NO;
                //animation3.fillMode = kCAFillModeForwards;
                [self._rootView.layer setBounds:toValue3];
                
                /*upAnimation2.duration = 0.2f;
                upAnimation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                upAnimation2.animations = [NSArray arrayWithObjects:animation2, animation3, nil];*/
                
                if ([self._delegate respondsToSelector:@selector(tableViewHeaderFormViewWillHide:)])
                    [self._delegate tableViewHeaderFormViewWillHide:self];

                [self._headerView.layer addAnimation:animation1 forKey:@"animatePosition"];
                [self._rootView.layer addAnimation:animation2 forKey:@"animatePosition2"];
                [self._rootView.layer addAnimation:animation3 forKey:@"animateBounds"];
        
            [CATransaction commit];

            /*while (done == NO)
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
            return;*/
            
            if (!callback) {
                while (done == NO)
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
                return;
            }
            
        } else {
            [self._headerView.layer setPosition:toValue1];
            [self._rootView.layer setPosition:toValue2];
            [self._rootView.layer setBounds:toValue3];
            
            if (callback)
                callback(TRUE);
            return;
        }
        
    } else {
        if (callback)
            callback(TRUE);
        return;
    }
}

- (BOOL)isHeaderShown
{
    if (self._headerView && self._headerView.frame.origin.y == 0.0) return TRUE;
    return FALSE;
}

- (BOOL)isHeaderHidden
{
    return ![self isHeaderShown];
}

- (UIView*)rootView
{
    return self._rootView;
}

- (UIView*)headerView
{
    return self._headerView;
}

@end
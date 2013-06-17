//
//  APPFeaturedViewController.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 05.09.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPFeaturedViewController.h"

@interface APPFeaturedViewController()
@property (nonatomic, retain) GDataFeedBase *feedDefault;
@property (nonatomic, retain) NSMutableArray *customFeedDefault;
@end

@implementation APPFeaturedViewController

- (id)init
{
    self = [super init];
    if (self) {        
        self.topbarImage = [UIImage imageNamed:@"top_bar_back_featured"];
        
        id this = self;
        [[[self registerNewOrRetrieveInitialState:tInitialState] onViewState:tDidInit do:^() {
            self.feedDefault = nil;
            self.customFeedDefault = nil;
        }] onViewState:tDidLoad do:^() {
            [this toShowMode:tDefault];
        }];
        
        [self toInitialState];
    }
    return self;
}

- (void)reloadData
{
    [self.contentManager recentlyFeaturedDelegate:self didFinishSelector:@selector(reloadDataResponse:finishedWithFeed:error:)];
}

- (void)loadMoreData
{
    if ([self currentFeed])
        [self.contentManager loadMoreData:[self currentFeed] delegate:self didFinishSelector:@selector(loadMoreDataResponse:finishedWithFeed:error:)];
}

- (GDataFeedBase*)currentFeed:(GDataFeedBase*)feed
{
    switch (self.showMode)
    {
        case tDefault:
            if (feed)
                self.feedDefault = feed;
            return self.feedDefault;
        default:
            return nil;
    }
}

- (NSMutableArray*)currentCustomFeed:(NSMutableArray*)feed;
{
    switch (self.showMode)
    {
        case tDefault:
            if (feed)
                self.customFeedDefault = feed;
            return self.customFeedDefault;
        default:
            return nil;
    }
}

@end

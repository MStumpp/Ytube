//
//  APPVideo.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 02.09.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPVideo.h"

@implementation APPVideo

static APPVideo *sharedInstance = nil;

+(APPVideo *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Work your initialising magic here as you normally would
    }
    return self;
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

-(NSArray*)mostViewedVideos
{
    NSDictionary *row1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @"Back to the future", @"Title", @"Best movies channel", @"Subtitle", @"96", @"Rating", @"6,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @"Ghost busters - movie", @"Title", @"Retor Hits", @"Subtitle", @"99", @"Rating", @"99199,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @"Ken Block at San Francisco", @"Title", @"Crazy driver", @"Subtitle", @"88", @"Rating", @"123890,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @"Rihanna live concert", @"Title", @"Rihanna Channel", @"Subtitle", @"79", @"Rating", @"9,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row5 = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @"Kid Cudi feat Kyney West", @"Title", @"Best movies channel", @"Subtitle", @"78", @"Rating", @"6,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    
    NSArray *videos = [[NSArray alloc] initWithObjects:row1, row2, row3, row4, row5, nil];
    return videos;
}

-(NSArray*)featuredVideos
{
    NSDictionary *row1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"2Back to the future", @"Title", @"Best movies channel", @"Subtitle", @"96", @"Rating", @"6,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Ghost busters - movie", @"Title", @"Retor Hits", @"Subtitle", @"99", @"Rating", @"99199,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Ken Block at San Francisco", @"Title", @"Crazy driver", @"Subtitle", @"88", @"Rating", @"123890,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Rihanna live concert", @"Title", @"Rihanna Channel", @"Subtitle", @"79", @"Rating", @"9,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row5 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Kid Cudi feat Kyney West", @"Title", @"Best movies channel", @"Subtitle", @"78", @"Rating", @"6,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    
    NSArray *videos = [[NSArray alloc] initWithObjects:row1, row2, row3, row4, row5, nil];
    return videos;
}

-(NSArray*)searchedVideos
{
    NSDictionary *row1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"3Back to the future", @"Title", @"Best movies channel", @"Subtitle", @"96", @"Rating", @"6,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Ghost busters - movie", @"Title", @"Retor Hits", @"Subtitle", @"99", @"Rating", @"99199,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Ken Block at San Francisco", @"Title", @"Crazy driver", @"Subtitle", @"88", @"Rating", @"123890,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Rihanna live concert", @"Title", @"Rihanna Channel", @"Subtitle", @"79", @"Rating", @"9,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    NSDictionary *row5 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Kid Cudi feat Kyney West", @"Title", @"Best movies channel", @"Subtitle", @"78", @"Rating", @"6,346", @"Views", @"video_1.jpg", @"Thumbnail", @"8:90", @"Duration", nil];
    
    NSArray *videos = [[NSArray alloc] initWithObjects:row1, row2, row3, row4, row5, nil];
    return videos;
}

@end

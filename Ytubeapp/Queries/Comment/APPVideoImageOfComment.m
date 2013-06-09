//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoImageOfComment.h"

@implementation APPVideoImageOfComment

-(void)load:(id)data
{
    NSDictionary *dict = (NSDictionary*) data;
    GDataEntryYouTubeComment *comment = [dict objectForKey:@"comment"];
    NSURL *entryURL = [NSURL URLWithString:[[[comment authors] objectAtIndex:0] URI]];

    if ([self service]) {
        self.ticket = [[self service] fetchEntryWithURL:entryURL completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
            if (!error) {
                GDataEntryYouTubeUserProfile *profile = (GDataEntryYouTubeUserProfile*)entry;
                [APPContent loadImage:[NSURL URLWithString:[[profile thumbnail] URLString]] callback:^(UIImage *image){
                    if (image) {
                        [self loadedWithData:image andError:nil];
                    } else {
                        [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"unable to load image from url"] code:1 userInfo:nil]];
                    }
                }];
            } else {
                [self loadedWithData:nil andError:error];
            }
        }];

    } else {
        [self loadedWithData:nil andError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
    }
}

@end
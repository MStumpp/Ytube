//
// Created by Matthias Stumpp on 09.06.13.
// Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "APPVideoImageOfComment.h"

@implementation APPVideoImageOfComment

-(void)load:(id)props
{
    NSDictionary *dict = (NSDictionary*) props;
    GDataEntryYouTubeComment *comment = [dict objectForKey:@"comment"];
    NSURL *entryURL = [NSURL URLWithString:[[[comment authors] objectAtIndex:0] URI]];

    id this = self;
    if ([self service]) {
        self.ticket = [[self service] fetchEntryWithURL:entryURL completionHandler:^(GDataServiceTicket *ticket, GDataEntryBase *entry, NSError *error) {
            if (!error) {
                GDataEntryYouTubeUserProfile *profile = (GDataEntryYouTubeUserProfile*)entry;
                [APPContent loadImage:[NSURL URLWithString:[[profile thumbnail] URLString]] callback:^(UIImage *image){
                    if (image) {
                        [this setResult:image];
                        [this loaded];
                    } else {
                        [this setError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"unable to load image from url"] code:1 userInfo:nil]];
                        [this loaded];
                    }
                }];
            } else {
                [this setError:error];
                [this loaded];
            }
        }];

    } else {
        [this setError:[[NSError alloc] initWithDomain:[NSString stringWithFormat:@"service not available"] code:1 userInfo:nil]];
        [this loaded];
    }
}

@end
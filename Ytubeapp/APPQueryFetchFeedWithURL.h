//
//  APPQueryFetchFeedWithURL.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 23.01.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "APPQueryGData.h"

@interface APPQueryFetchFeedWithURL : APPQueryGData

-(APPQuery*)fetchFeedWithURL:(NSURL*)feedURL;

@end

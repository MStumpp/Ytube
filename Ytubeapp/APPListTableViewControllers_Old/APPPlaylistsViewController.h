//
//  APPPlaylistsViewController.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 12.09.12.
//  Copyright (c) 2012 Matthias Stumpp. All rights reserved.
//

#import "APPSingleTableCustomNavigationBarViewController.h"

typedef void(^APPPlaylistsViewControllerCallback)(GDataEntryYouTubePlaylistLink *playlist);

@interface APPPlaylistsViewController : APPSingleTableCustomNavigationBarViewController

@property (nonatomic, copy) APPPlaylistsViewControllerCallback callback;

@end

//
//  DataCache.h
//  Ytubeapp
//
//  Created by Matthias Stumpp on 05.10.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataYouTube.h"
#import "Query.h"
#import "APPContent.h"

#define eventDataReloadedFinished @"dataReloadedFinished"
#define eventDataReloadedError @"dataReloadedError"
#define eventDataMoreLoadedFinished @"dataMoreLoadedFinished"
#define eventDataMoreLoadedError @"dataMoreLoadedError"

typedef void(^QueryHandler)(NSString *key, Query *query);
typedef void(^ResponseHandler)(NSString *key, id context, id data, NSError *error);
typedef void(^ReloadHandlerCallback)(NSString *key, id context, QueryHandler queryHandler, ResponseHandler responseHandler);
typedef void(^LoadMoreHandlerCallback)(NSString *key, id previous, id context, QueryHandler queryHandler, ResponseHandler responseHandler);

@interface DataCache : NSObject
+(DataCache*)instance;
-(BOOL)configureReloadDataForKey:(NSString*)key withHandler:(ReloadHandlerCallback)callback;
-(BOOL)configureLoadMoreDataForKey:(NSString*)key withHandler:(LoadMoreHandlerCallback)callback;
-(BOOL)configureReloadDataForKeys:(NSArray*)keys withHandler:(ReloadHandlerCallback)callback;
-(BOOL)configureLoadMoreDataForKeys:(NSArray*)keys withHandler:(LoadMoreHandlerCallback)callback;
-(BOOL)hasData:(NSString*)key;
-(BOOL)canLoadMoreData:(NSString*)key;
-(id)getData:(NSString*)key;
-(id)getData:(NSString*)key withContext:(id)context;
-(BOOL)reloadData:(NSString*)key;
-(BOOL)reloadData:(NSString*)key withContext:(id)context;
-(BOOL)loadMoreData:(NSString*)key;
-(BOOL)loadMoreData:(NSString*)key withContext:(id)context;
-(BOOL)clearData:(NSString*)key;
@end

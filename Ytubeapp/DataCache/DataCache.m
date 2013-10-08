//
//  DataCache.m
//  Ytubeapp
//
//  Created by Matthias Stumpp on 05.10.13.
//  Copyright (c) 2013 Matthias Stumpp. All rights reserved.
//

#import "DataCache.h"
#import "APPQueryHelper.h"

@interface DataCache()
@property NSMutableDictionary *handlerReload;
@property NSMutableDictionary *handlerLoadMore;
@property NSMutableDictionary *queriesReload;
@property NSMutableDictionary *queriesLoadMore;
@property NSMutableDictionary *feeds;
@property NSMutableDictionary *customFeeds;
@end

@implementation DataCache

static DataCache *classInstance = nil;

+(DataCache*)instance
{
    if (classInstance == nil) {
        classInstance = [[super allocWithZone:nil] init];
        
        classInstance.handlerReload = [[NSMutableDictionary alloc] init];
        classInstance.handlerLoadMore = [[NSMutableDictionary alloc] init];
        classInstance.queriesReload = [[NSMutableDictionary alloc] init];
        classInstance.queriesLoadMore = [[NSMutableDictionary alloc] init];
        classInstance.feeds = [[NSMutableDictionary alloc] init];
        classInstance.customFeeds = [[NSMutableDictionary alloc] init];
    }
    return classInstance;
}

-(BOOL)configureReloadDataForKey:(NSString*)key withHandler:(ReloadHandlerCallback)callback
{
    if (!key) return FALSE;
    if (![self hasKey:key]) [self addKey:key];
    [self.handlerReload setObject:callback forKey:key];
    return TRUE;
}

-(BOOL)configureLoadMoreDataForKey:(NSString*)key withHandler:(LoadMoreHandlerCallback)callback
{
    if (!key) return FALSE;
    if (![self hasKey:key]) [self addKey:key];
    [self.handlerLoadMore setObject:callback forKey:key];
    return TRUE;
}

-(BOOL)configureReloadDataForKeys:(NSArray*)keys withHandler:(ReloadHandlerCallback)callback
{
    if (!keys) return FALSE;
    for (NSString *key in keys) {
        [self configureReloadDataForKey:key withHandler:callback];
    }
    return TRUE;
}

-(BOOL)configureLoadMoreDataForKeys:(NSArray*)keys withHandler:(LoadMoreHandlerCallback)callback
{
    if (!keys) return FALSE;
    for (NSString *key in keys) {
        [self configureLoadMoreDataForKey:key withHandler:callback];
    }
    return TRUE;
}

-(BOOL)hasData:(NSString*)key
{
    if (!key || ![self hasKey:key]) return FALSE;
    Query *query = [self queryForKey:key forType:self.queriesReload];
    if (query != (id)[NSNull new] && [query isFinished]) {
        return TRUE;
    } else {
        return FALSE;
    }
}

-(BOOL)canLoadMoreData:(NSString*)key
{
    if (!key || ![self hasKey:key]) return FALSE;
    GDataFeedBase *feed = [self feedForKey:key];
    if (!feed || [feed isEqual:[NSNull new]]) return FALSE;
    if ([feed nextLink]) return TRUE;
    return FALSE;
}

-(id)getData:(NSString*)key
{
    return [self getData:key withContext:NULL];
}

-(id)getData:(NSString*)key withContext:(id)context
{
    if (!key || ![self hasKey:key]) return NULL;
    if ([self hasData:key]) {
        return [self customFeedForKey:key];
    } else {
        Query *query = [self queryForKey:key forType:self.queriesReload];
        if (query == (id)[NSNull new]) {
            [self reloadData:key withContext:context];
        }
        return NULL;
    }
}

-(BOOL)reloadData:(NSString*)key
{
    return [self reloadData:key withContext:NULL];
}

-(BOOL)reloadData:(NSString*)key withContext:(id)context
{
    if (!key || ![self hasKey:key]) return FALSE;
    
    // reset mode and eventually cancel other reload/load more queries
    [self resetKey:key];
    
    // if there is no handler for reload
    if (![self reloadHandlerForKey:key]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:eventDataReloadedError object:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil, @"data", [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"no reload handler for key"] code:1 userInfo:nil], @"error", nil]];
        return FALSE;
    }
    
    // reload the data
    [self reloadHandlerForKey:key](key, context,
                                   ^(NSString *key, Query *query) {
                                       [self setQuery:query forKey:key forType:self.queriesReload];
                                   },
                                   ^(NSString *key, id context, id data, NSError *error) {
                                       
                                       // no error
                                       if (!error) {
                                           // replace current feed for mode
                                           [self feed:data forKey:key];
                                           
                                           // clear custom feed array
                                           [[self customFeedForKey:key] removeAllObjects];
                                           
                                           // finally, add feed entries to custom feed
                                           [[self customFeedForKey:key] addObjectsFromArray:[data entries]];
                                           
                                           [[NSNotificationCenter defaultCenter] postNotificationName:eventDataReloadedFinished object:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", data, @"data", error, @"error", nil]];
                                           
                                       // error
                                       } else {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:eventDataReloadedError object:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", data, @"data", error, @"error", nil]];
                                       }
                                   });
    return TRUE;
}

-(BOOL)loadMoreData:(NSString*)key
{
    return [self loadMoreData:key withContext:NULL];
}

-(BOOL)loadMoreData:(NSString*)key withContext:(id)context
{
    if (!key || ![self hasKey:key]) return FALSE;
    
    GDataFeedBase *previous = [self feedForKey:key];
    
    // if there is no feed, cant load more data
    if (!previous) {
        [[NSNotificationCenter defaultCenter] postNotificationName:eventDataMoreLoadedError object:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil, @"data", [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"no feed for key"] code:1 userInfo:nil], @"error", nil]];
        return FALSE;
    }
    
    // if feed doesn't has more data
    if (![self canLoadMoreData:key]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:eventDataMoreLoadedError object:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil, @"data", [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"feed for key doesn't has more data"] code:1 userInfo:nil], @"error", nil]];
        return FALSE;
    }
    
    // eventualy do not process if there is currently another load more query running
    if ([self queryForKey:key forType:self.queriesLoadMore] &&
        [self queryForKey:key forType:self.queriesLoadMore] != (id)[NSNull new]) {
        return FALSE;
    }
    
    // if there is no handler for load more
    if (![self loadMoreHandlerForKey:key]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:eventDataMoreLoadedError object:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", nil, @"data", [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"no load more handler for key"] code:1 userInfo:nil], @"error", nil]];
        return FALSE;
    }
    
    // reload the data
    [self loadMoreHandlerForKey:key](key, previous, context,
                                   ^(NSString *key, Query *query) {
                                       [self setQuery:query forKey:key forType:self.queriesLoadMore];
                                   },
                                   ^(NSString *key, id context, id data, NSError *error) {
                                       
                                       // no error
                                       if (!error) {
                                           
                                           // replace current feed for mode
                                           [self feed:data forKey:key];
                                           
                                           // finally, add feed entries to custom feed
                                           [[self customFeedForKey:key] addObjectsFromArray:[data entries]];
                                           
                                           [[NSNotificationCenter defaultCenter] postNotificationName:eventDataMoreLoadedFinished object:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", data, @"data", error, @"error", nil]];
                                           
                                       // error
                                       } else {
                                           
                                           [[NSNotificationCenter defaultCenter] postNotificationName:eventDataMoreLoadedError object:[NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", context, @"context", data, @"data", error, @"error", nil]];
                                       }
                                   });
    return TRUE;
}

-(BOOL)clearData:(NSString*)key
{
    if (!key || ![self hasKey:key]) return FALSE;
    return [self resetKey:key];
}

-(BOOL)clearAllData
{
    NSArray *keys = [self.queriesReload allKeys];
    for (NSString *key in keys) {
        [self clearData:key];
    }
    return TRUE;
}

// private

-(void)setQuery:(Query*)ticket forKey:(NSString*)key forType:(NSMutableDictionary*)type
{
    if (ticket && key && type) [type setObject:ticket forKey:key];
}

-(Query*)queryForKey:(NSString*)key forType:(NSMutableDictionary*)type
{
    if (key) return (Query*)[type objectForKey:key];
    return NULL;
}

-(GDataFeedBase*)feedForKey:(NSString*)key
{
    return [self feed:nil forKey:key];
}

-(GDataFeedBase*)feed:(GDataFeedBase*)feed forKey:(NSString*)key
{
    if (feed) [self.feeds setObject:feed forKey:key];
    return (GDataFeedBase*)[self.feeds objectForKey:key];
}

-(NSMutableArray*)customFeedForKey:(NSString*)key
{
    return [self customFeed:nil forKey:key];
}

-(NSMutableArray*)customFeed:(NSMutableArray*)feed forKey:(NSString*)key
{
    if (feed) [self.customFeeds setObject:feed forKey:key];
    return (NSMutableArray*)[self.customFeeds objectForKey:key];
}

-(ReloadHandlerCallback)reloadHandlerForKey:(NSString*)key
{
    if (key) return (ReloadHandlerCallback)[self.handlerReload objectForKey:key];
    return NULL;
}

-(LoadMoreHandlerCallback)loadMoreHandlerForKey:(NSString*)key
{
    if (key) return (LoadMoreHandlerCallback)[self.handlerLoadMore objectForKey:key];
    return NULL;
}

-(BOOL)resetKey:(NSString*)key
{
    if ([self queryForKey:key forType:self.queriesReload] &&
        [self queryForKey:key forType:self.queriesReload] != (id)[NSNull new])
        [[self queryForKey:key forType:self.queriesReload] cancel];
    [self.queriesReload setObject:[NSNull new] forKey:key];
    
    if ([self queryForKey:key forType:self.queriesLoadMore] &&
        [self queryForKey:key forType:self.queriesLoadMore] != (id)[NSNull new])
        [[self queryForKey:key forType:self.queriesLoadMore] cancel];
    [self.queriesLoadMore setObject:[NSNull new] forKey:key];
    
    [self.feeds setObject:[NSNull new] forKey:key];
    [[self customFeedForKey:key] removeAllObjects];
    return TRUE;
}

-(BOOL)addKey:(NSString*)key
{
    if (!key || [self hasKey:key]) return FALSE;
    [self.handlerReload setObject:[NSNull new] forKey:key];
    [self.handlerLoadMore setObject:[NSNull new] forKey:key];
    [self.queriesReload setObject:[NSNull new] forKey:key];
    [self.queriesLoadMore setObject:[NSNull new] forKey:key];
    [self.feeds setObject:[NSNull new] forKey:key];
    [self.customFeeds setObject:[[NSMutableArray alloc] init] forKey:key];
    return TRUE;
}

-(BOOL)hasKey:(NSString*)key
{
    NSArray *keys = [self.queriesReload allKeys];
    for(NSString* tmp in keys) if ([tmp isEqualToString:key]) return TRUE;
    return FALSE;
}

@end

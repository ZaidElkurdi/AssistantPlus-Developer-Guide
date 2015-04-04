//
//  spotifyCommands.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "spotifySearchCommands.h"
#import "AFNetworking/AFNetworking.h"

@implementation SpotifySearchCommands

- (BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session {
  //Do a quick/rough check first to see if we should do any more thorough processing
  if ([tokens containsObject:@"search"] && [tokens containsObject:@"on"] && [tokens containsObject:@"spotify"]) {
    /*Handle different permutations of query eg.
        Hey Siri search for Taylor Swift on Spotify
        Search for Drake on Spotify
        Search Drake on Spotify
    */
    NSRegularExpression *queryRegex = [NSRegularExpression regularExpressionWithPattern:@"(?:.*)Search (?:for)?(.*) on Spotify" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *arrayOfAllMatches = [queryRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    NSString *query = nil;
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
      if (match.numberOfRanges > 1) {
        query = [text substringWithRange:[match rangeAtIndex:1]];
      }
    }
    
    if (!query || query.length == 0) {
      return NO;
    }
    
    //Display a temporary message that will be replaced by the result. Notice that the dialogPhase is "Reflection".
    [session sendTextSnippet:@"Searching..." temporary:YES scrollToTop:NO dialogPhase:@"Reflection"];
    
    //Don't want to do the network calls on the Siri UI thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self searchSpotifyForQuery:query forSession:session];
    });
    
    //We will be handling this request
    return YES;
  }

  return NO;
}

- (void)searchSpotifyForQuery:(NSString*)query forSession:(id<APSiriSession>)session {
  query = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  __block NSArray *trackResults = [NSArray array];
  __block NSArray *albumResults = [NSArray array];
  __block NSArray *artistResults = [NSArray array];
  
  NSURL *trackURL = [NSURL URLWithString:[[NSString stringWithFormat:@"http://ws.spotify.com/search/1/track.json?q=%@", query] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  NSURL *artistURL = [NSURL URLWithString:[[NSString stringWithFormat:@"http://ws.spotify.com/search/1/artist.json?q=%@", query] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  NSURL *albumURL = [NSURL URLWithString:[[NSString stringWithFormat:@"http://ws.spotify.com/search/1/album.json?q=%@", query] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  
  NSURLRequest *trackRequest = [NSURLRequest requestWithURL:trackURL];
  AFHTTPRequestOperation *trackOperation = [[AFHTTPRequestOperation alloc] initWithRequest:trackRequest];
  trackOperation.responseSerializer = [AFJSONResponseSerializer serializer];
  [trackOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    trackResults = responseObject[@"tracks"] ? responseObject[@"tracks"] : trackResults;
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
  
  NSURLRequest *albumRequest = [NSURLRequest requestWithURL:albumURL];
  AFHTTPRequestOperation *albumOperation = [[AFHTTPRequestOperation alloc] initWithRequest:albumRequest];
  albumOperation.responseSerializer = [AFJSONResponseSerializer serializer];
  [albumOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    albumResults = responseObject[@"albums"] ? responseObject[@"albums"] : albumResults;
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
  
  NSURLRequest *artistRequest = [NSURLRequest requestWithURL:artistURL];
  AFHTTPRequestOperation *artistOperation = [[AFHTTPRequestOperation alloc] initWithRequest:artistRequest];
  artistOperation.responseSerializer = [AFJSONResponseSerializer serializer];
  [artistOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    artistResults = responseObject[@"artists"] ? responseObject[@"artists"] : artistResults;
    
    if (trackResults.count + albumResults.count + artistResults.count == 0) {
      NSString *errorMsg = [NSString stringWithFormat:@"Sorry, I wasn't able to find anything for '%@'", query];
      
      //We didn't find any results so just display the error message. This will replace the "Searching..." message.
      [session sendTextSnippet:errorMsg temporary:NO scrollToTop:NO dialogPhase:@"Completion"];
    } else {
      /* You could also send the views like this:
      NSMutableDictionary *textSnippet = [session createTextSnippet:@"Here's what I found..."];
      NSMutableDictionary *customSnippet = [session createSnippet:@"SpotifySearchResultsViewController" properties:@{@"tracks" : [trackResults subarrayWithRange:NSMakeRange(0, MIN(trackResults.count, 5))],
                                                                                        @"albums" : [albumResults subarrayWithRange:NSMakeRange(0, MIN(albumResults.count, 5))],
                                                                                        @"artists" : [artistResults subarrayWithRange:NSMakeRange(0, MIN(artistResults.count, 5))]}];
      [session sendAddViews:@[textSnippet, customSnippet]]; */
      
      //Display our custom snippet with the results. This will replace the "Searching..." message.
      [session sendTextSnippet:@"Here's what I found..." temporary:NO scrollToTop:NO dialogPhase:@"Summary"];
      [session sendCustomSnippet:@"SpotifySearchResultsViewController" withProperties:@{@"tracks" : [trackResults subarrayWithRange:NSMakeRange(0, MIN(trackResults.count, 5))],
                                                                                      @"albums" : [albumResults subarrayWithRange:NSMakeRange(0, MIN(albumResults.count, 5))],
                                                                                      @"artists" : [artistResults subarrayWithRange:NSMakeRange(0, MIN(artistResults.count, 5))]}];
    }
    
    //Make sure to tell the APSiriSession that we're done.
    [session sendRequestCompleted];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [session sendRequestCompleted];
  }];
  
  
  NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
  
  [albumOperation addDependency:trackOperation];
  [artistOperation addDependency:albumOperation];
  
  [operationQueue addOperation:trackOperation];
  [operationQueue addOperation:albumOperation];
  [operationQueue addOperation:artistOperation];
}

@end

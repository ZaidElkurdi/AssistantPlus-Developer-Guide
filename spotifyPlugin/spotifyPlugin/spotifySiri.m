//
//  spotifySiri.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "spotifySiri.h"
#import "spotifySearchCommands.h"
#import "SpotifyPlayCommands.h"
#import "SpotifySearchResultsViewController.h"

@implementation spotifySiri

-(id)initWithPluginManager:(id<APPluginManager>)manager {
  if (self = [super init]) {
    //Register the commands and snippet with the plugin manager
    [manager registerCommand:[SpotifySearchCommands class]];
    [manager registerCommand:[SpotifyPlayCommands class]];
    [manager registerSnippet:[SpotifySearchResultsViewController class]];
  }
  return self;
}

@end

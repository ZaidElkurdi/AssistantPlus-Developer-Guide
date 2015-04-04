//
//  SpotifyPlayCommands.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/30/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "SpotifyPlayCommands.h"
#import "AFNetworking/AFNetworking.h"

@implementation SpotifyPlayCommands

- (BOOL)handleSpeech:(NSString *)text withTokens:(NSSet *)tokens withSession:(id<APSiriSession>)session {
  if ([tokens containsObject:@"play"] && [tokens containsObject:@"on"] && [tokens containsObject:@"spotify"]) {
    NSRegularExpression *songAndArtistRegex = [NSRegularExpression regularExpressionWithPattern:@"(?:.*)Play (.*) by (.*) on Spotify" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *justSongRegex = [NSRegularExpression regularExpressionWithPattern:@"(?:.*)Play(.*)on Spotify" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *justSongMatches = [justSongRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    NSArray *songAndArtistMatches = [songAndArtistRegex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    NSString *artistName = nil;
    NSString *songName = nil;
    
    for (NSTextCheckingResult *match in songAndArtistMatches) {
      if (match.numberOfRanges > 2) {
        songName = [text substringWithRange:[match rangeAtIndex:1]];
        artistName = [text substringWithRange:[match rangeAtIndex:2]];
      }
    }
    
    if (!artistName || !songName) {
      for (NSTextCheckingResult *match in justSongMatches) {
        if (match.numberOfRanges > 1) {
          songName = [text substringWithRange:[match rangeAtIndex:1]];
        }
      }
    }
    
    if (!songName || songName.length == 0) {
      return NO;
    }
    
    [session sendTextSnippet:@"Searching..." temporary:YES scrollToTop:NO dialogPhase:@"Reflection"];
    
    //Don't do network calls on Siri UI thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self searchForSong:songName byArtist:artistName forSession:session];
    });
    
    return YES;
  }
  
  return NO;
}

- (void)searchForSong:(NSString*)songName byArtist:(NSString*)artistName forSession:(id<APSiriSession>)session {
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  [manager GET:@"http://ws.spotify.com/search/1/track.json" parameters:@{@"q" : songName} success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSArray *tracks = responseObject[@"tracks"];
    
    if (!tracks || tracks.count == 0) {
      [session sendTextSnippet:@"Sorry, I couldn't find anything" temporary:NO scrollToTop:NO dialogPhase:@"Completion"];
      return;
    }
    
    NSString *href = nil;
    
    //Search with artist name first
    if (artistName) {
      href = [self getSongForArtist:artistName fromSongs:tracks];
    }
    
    //If we couldn't find a song with this name by the artist, default to the
    //top result for the song name
    if (!artistName) {
      NSDictionary *topResult = tracks[0];
      href = topResult[@"href"];
    }
    
    //If we found the song, go to it.
    if (href) {
      [[UIApplication sharedApplication]openURL:[NSURL URLWithString:href]];
    }
    
    //End session
    [session sendRequestCompleted];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [session sendTextSnippet:@"Sorry, I couldn't find that song" temporary:NO scrollToTop:YES dialogPhase:@"Completion"];
    [session sendRequestCompleted];
  }];
}

- (NSString*)getSongForArtist:(NSString*)artistName fromSongs:(NSArray*)songs {
  for (NSDictionary *currSong in songs) {
    NSArray *artistsInfo = currSong[@"artists"];
    if (artistsInfo) {
      for (NSDictionary *currArtist in artistsInfo) {
        NSString *currName = currArtist[@"name"];
        if ([artistName compare:currName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
          NSString *songHref = currSong[@"href"];
          if (songHref) {
            return songHref;
          }
        }
      }
    }
  }
  return nil;
}


@end

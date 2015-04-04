//
//  spotifySongListViewController.h
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssistantPlusHeaders.h"

//Your UIViewController subclass must conform to APPluginSnippet
@interface SpotifySearchResultsViewController : UIViewController <APPluginSnippet, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *songsTable;
-(id)initWithProperties:(NSDictionary*)props;
@end

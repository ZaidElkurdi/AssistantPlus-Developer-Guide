//
//  spotifySongListViewController.m
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import "SpotifySearchResultsViewController.h"
#import "spotifySongTableViewCell.h"

@implementation SpotifySearchResultsViewController {
  NSArray *artistResults;
  NSArray *trackResults;
  NSArray *albumResults;
}

-(id)initWithProperties:(NSDictionary*)props {
  if (self = [super init]) {
    artistResults = [props objectForKey:@"artists"];
    trackResults = [props objectForKey:@"tracks"];
    albumResults = [props objectForKey:@"albums"];
  }
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.songsTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
  self.songsTable.delegate = self;
  self.songsTable.dataSource = self;
  self.songsTable.backgroundColor = [UIColor clearColor];
  self.songsTable.layoutMargins = UIEdgeInsetsZero;
  self.songsTable.scrollEnabled = NO;
  
  [self.songsTable layoutIfNeeded];
  CGRect newFrame = self.songsTable.frame;
  newFrame.size.height = self.songsTable.contentSize.height;

  self.view.frame = newFrame;
  self.songsTable.frame = self.view.frame;
  
  [self.view addSubview:self.songsTable];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *selectedEntity;
  if (indexPath.section == 0) {
    selectedEntity = [artistResults objectAtIndex:indexPath.row];
  } else if (indexPath.section == 1) {
    selectedEntity = [trackResults objectAtIndex:indexPath.row];
  } else {
    selectedEntity = [albumResults objectAtIndex:indexPath.row];
  }
  
  NSString *href = selectedEntity[@"href"];
  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:href]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return indexPath.section == 0 ? 50 : 77;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
  UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView*)view;
  header.textLabel.textColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NSString *title = nil;
  switch (section) {
    case 0:
      title = @"Artists";
      break;
    case 1:
      title = @"Tracks";
      break;
    case 2:
      title = @"Albums";
    default:
      break;
  }
  
  return title;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SpotifySongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songCell"];
  
  if (!cell) {
    //The code is going to be run by the Siri UI process, so we can't just use [NSBundle mainBundle]
    NSBundle *pluginBundle = [NSBundle bundleWithPath:@"/Library/AssistantPlusPlugins/spotifySiri.assistantPlugin"];
    [tableView registerNib:[UINib nibWithNibName:@"SpotifySongTableViewCell" bundle:pluginBundle] forCellReuseIdentifier:@"songCell"];
    cell = [tableView dequeueReusableCellWithIdentifier:@"songCell"];
  }
  
  cell.backgroundColor = [UIColor clearColor];
  
  NSDictionary *currEntity;
  if (indexPath.section == 0) {
    currEntity = [artistResults objectAtIndex:indexPath.row];
    cell.songDetailLabel.text = @"";
  } else if (indexPath.section == 1) {
    currEntity = [trackResults objectAtIndex:indexPath.row];
    cell.songDetailLabel.text = [NSString stringWithFormat:@"%@ - %@", currEntity[@"artists"][0][@"name"], currEntity[@"album"][@"name"]];
  } else {
    currEntity = [albumResults objectAtIndex:indexPath.row];
    cell.songDetailLabel.text = [NSString stringWithFormat:@"%@", currEntity[@"artists"][0][@"name"]];
  }

  cell.songTitleLabel.text = currEntity[@"name"];
  
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger numRows = 0;
  switch (section) {
    case 0:
      numRows = MIN(artistResults.count, 5);
      break;
    case 1:
      numRows = MIN(trackResults.count, 5);
      break;
    case 2:
      numRows = MIN(albumResults.count, 5);
    default:
      break;
  }
  
  return numRows;
}

@end

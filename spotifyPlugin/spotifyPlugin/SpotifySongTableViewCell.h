//
//  spotifySongTableViewCell.h
//  spotifyPlugin
//
//  Created by Zaid Elkurdi on 3/28/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpotifySongTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *songDetailLabel;

@end

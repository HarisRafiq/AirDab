//
//  SongsCell.h
//  IMMedia
//
//  Created by YAZ on 8/8/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongsCell : UITableViewCell
{
    BOOL isPlayer;
   

}
-(void)setPlayer:(BOOL)selected;
  @property (nonatomic, strong) IBOutlet UIView *bg;
 @property (nonatomic, strong) IBOutlet UILabel *duration;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UIView *leftView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
-(void)setToggle;
-(void)offToggle;
 @end

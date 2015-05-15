//
//  SongsCell_Ipad.h
//  AirDab
//
//  Created by YAZ on 10/3/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongsCell_Ipad : UITableViewCell
{
    BOOL isPlayer;
    
    
}
-(void)setPlayer:(BOOL)selected;
@property (nonatomic, strong) IBOutlet UIView *bg;
@property (nonatomic, strong) IBOutlet UILabel *duration;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UIView *leftView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

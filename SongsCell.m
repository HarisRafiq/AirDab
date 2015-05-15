//
//  SongsCell.m
//  IMMedia
//
//  Created by YAZ on 8/8/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//

#import "SongsCell.h"

@implementation SongsCell
@synthesize  title,duration,leftView,bg,imageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBackgroundColor:[UIColor clearColor].CGColor];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self.contentView.layer setBackgroundColor:[UIColor clearColor].CGColor];
        isPlayer=NO;
           }
    return self;
}
 
-(void)layoutSubviews

{[super layoutSubviews];

    [self setBackgroundColor:[UIColor clearColor]];
    [self.layer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.contentView.layer setBackgroundColor:[UIColor clearColor].CGColor];
  

    
    
}


-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
}
 -(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(!isPlayer){
    imageView.image=selected ? [UIImage imageNamed:@"white-pause.png"] :[UIImage imageNamed:@"play-black.png"] ;
           leftView.backgroundColor =  selected ? [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]:[UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0] ;
     title.textColor = selected ?  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] :[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] ;
    bg.backgroundColor=selected ? [UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0]:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]  ;
        duration.textColor = selected ?  [UIColor colorWithRed:0.933 green:0.133 blue:0.133 alpha:1.0] :[UIColor colorWithRed:0.933 green:0.133 blue:0.133 alpha:1.0] ;
    }
    else{
        imageView.image= selected ?[UIImage imageNamed:@"up-dark.png"]:[UIImage imageNamed:@"up.png"] ;
        [imageView setFrame:CGRectMake(11, 11, 30, 30)];
        leftView.backgroundColor =  selected ? [UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0] :[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] ;
        title.textColor = selected ?  [UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0] :[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] ;
        bg.backgroundColor=selected ? [UIColor colorWithRed:1.0  green:1.0 blue:1.0 alpha:1.0] :[UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0] ;
     duration.textColor = selected ?  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] :[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] ;
    }
    }
-(void)setPlayer:(BOOL)selected{
    
    isPlayer=selected;
        
    
}
 
-(void)setToggle {
    
    
    bg.backgroundColor= [UIColor clearColor];
}
-(void)offToggle {
    
    
    bg.backgroundColor=isPlayer ? [UIColor colorWithRed:1.0  green:1.0 blue:1.0 alpha:1.0] :[UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0] ;
}
@end

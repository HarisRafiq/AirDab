//
//  ToggleTopView.m
//  AirDab
//
//  Created by YAZ on 10/10/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "ToggleTopView.h"
#import "AudioPlayer.h"
@implementation ToggleTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, 5, self.bounds.size.width-20, 30)];
        
        
        
        [self addSubview:seekSlider];
        [self setupLeftAndRightLabels];
        [[AudioPlayer sharedInstance] enableScrubbingFromSlider:seekSlider];
    }
    return self;
}
-(void)setupLeftAndRightLabels{
    _leftLabel=[[UILabel alloc] initWithFrame:CGRectMake(5, 38,self.bounds.size.width/4,12)];
    _rightLabel=[[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-self.bounds.size.width/4-5, 40,self.bounds.size.width/4,10)];
    _rightLabel.textColor=_leftLabel.textColor =  [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] ;
    [_leftLabel setBackgroundColor:[UIColor clearColor]];
    [_rightLabel setBackgroundColor:[UIColor clearColor]];
    _leftLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    _leftLabel.textAlignment=NSTextAlignmentLeft;
    _rightLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    _rightLabel.textAlignment=NSTextAlignmentRight;
    
    [self addSubview:_leftLabel];
    [self addSubview:_rightLabel];
    
}
-(UISlider *)seekSlider;
{

    return seekSlider;
}
-(void)update{

seekSlider.value=([[AudioPlayer sharedInstance] currentTime]/44100)/[[AudioPlayer sharedInstance] tduration];
    
    
    _leftLabel.text=[self convertTimeFromSeconds:[NSString stringWithFormat:@"%i",[[AudioPlayer sharedInstance] currentTime]/44100  ] ];
   _rightLabel.text=[self convertTimeFromSeconds:[NSString stringWithFormat:@"%f",([[AudioPlayer sharedInstance] tduration]-[[AudioPlayer sharedInstance] currentTime]/44100)  ] ];
}
-(void)cleanUp{
    [seekSlider removeFromSuperview];
    [_leftLabel removeFromSuperview];
    [_rightLabel removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (NSString *)convertTimeFromSeconds:(NSString *)seconds {
    
    // Return variable.
    NSString *result = @"";
    
    // Int variables for calculation.
    int secs = [seconds intValue];
    int tempHour    = 0;
    int tempMinute  = 0;
    int tempSecond  = 0;
    
    NSString *hour      = @"";
    NSString *minute    = @"";
    NSString *second    = @"";
    
    // Convert the seconds to hours, minutes and seconds.
    tempHour    = secs / 3600;
    tempMinute  = secs / 60 - tempHour * 60;
    tempSecond  = secs - (tempHour * 3600 + tempMinute * 60);
    
    hour    = [[NSNumber numberWithInt:tempHour] stringValue];
    minute  = [[NSNumber numberWithInt:tempMinute] stringValue];
    second  = [[NSNumber numberWithInt:tempSecond] stringValue];
    
    // Make time look like 00:00:00 and not 0:0:0
    if (tempHour < 10) {
        hour = [@"0" stringByAppendingString:hour];
    }
    
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    
    if (tempHour == 0) {
        
        result = [NSString stringWithFormat:@"%@:%@", minute, second];
        
    } else {
        
        
        result = [NSString stringWithFormat:@"%@:%@:%@",hour, minute, second];
        
    }
    
    return result;
    
}

@end

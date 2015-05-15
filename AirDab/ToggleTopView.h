//
//  ToggleTopView.h
//  AirDab
//
//  Created by YAZ on 10/10/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToggleTopView : UIView
{
    UISlider *seekSlider;
UILabel *_leftLabel;
UILabel *_rightLabel;
}
-(UISlider *)seekSlider;
-(void)update;
-(void)cleanUp;
@end

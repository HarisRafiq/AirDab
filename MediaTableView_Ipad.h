//
//  MediaTableView_Ipad.h
//  AirDab
//
//  Created by YAZ on 10/1/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CircleTableView.h"
#import <CoreData/CoreData.h>
@protocol MediaTableView_IpadDelegate;
@interface MediaTableView_Ipad : UIView<UITableViewDataSource ,UITableViewDelegate,  UIScrollViewDelegate>
{
    
    id <MediaTableView_IpadDelegate> delegate;
    CircleTableView   *tView;
    UIView *bottomView;
    NSString *firstLetter;
    NSString *lastLetter;
    UIButton *bottomButton;
    UILabel *_leftLabel;
    UILabel *_rightLabel;
    BOOL isVideoSessionActive;
    CALayer *mImageLayer;
    int maxValue;
}
@property (assign, nonatomic) CGPoint lastContentOffset;
@property(nonatomic, assign) id <MediaTableView_IpadDelegate> delegate;
-(CircleTableView *)tView;
-(void)setMaxValue:(double)v;
-(void)updateDurationLabel:(double)p;
- (void)teardown;
-(void)reloadTableFromDelegate ;
@end
@protocol MediaTableView_IpadDelegate<NSObject>
-(void)playNextTrack;
-(void)call;

-(void)addSongsViewWithArtist:(NSString *)artist AtIndex:(int)i isLocal:(BOOL)s AndImage:(UIImage *)image;

@end
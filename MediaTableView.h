//
//  MediaTableView.h
//  IMMedia
//
//  Created by YAZ on 4/16/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
 #import "CircleTableView.h"
#import <CoreData/CoreData.h>
@protocol MediaTableViewDelegate;
@interface MediaTableView : UIView<UITableViewDataSource ,UITableViewDelegate   >
{
     
       id <MediaTableViewDelegate> delegate;
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
 @property(nonatomic, assign) id <MediaTableViewDelegate> delegate;
-(CircleTableView *)tView;
-(void)setMaxValue:(double)v;
-(void)updateDurationLabel:(double)p;
- (void)teardown;
-(void)reloadTableFromDelegate ;
@end
@protocol MediaTableViewDelegate<NSObject>
-(void)playNextTrack;
-(void)call;
 
-(void)addSongsViewWithArtist:(NSString *)artist AtIndex:(int)i isLocal:(BOOL)s AndImage:(UIImage *)image;
 
@end
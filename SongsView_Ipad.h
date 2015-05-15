//
//  SongsView_Ipad.h
//  AirDab
//
//  Created by YAZ on 10/1/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol SongsView_IpadDelegate;
#import "SongsCell_Ipad.h"
@interface SongsView_Ipad : UIView<UITableViewDataSource ,UITableViewDelegate >
{
    UITableView *tView;
    BOOL isLocalFile;
    NSMutableArray *currentArtistSongs;
    
}
- (void)setUpWithArtist:(NSString *)artist;
- (void)setUpLocalSongs;
-(void)setIsLocalFile:(BOOL)s;
-(void)setupTable;
@property (nonatomic, retain) UILabel *titleLabel;
@property(nonatomic, assign) id <SongsView_IpadDelegate> delegate;
-(void)setCellTitle:(NSString*)title;
-(void)reloadData;
@end
@protocol SongsView_IpadDelegate<NSObject>
-(void)addSelectedSongView:(SongsCell_Ipad *)c AtScrollPosition:(CGPoint)p;
-(void)playSongsWithUrl:(MPMediaItem *)temp atIndex:(int)i scrollPosition:(CGPoint )p;
-(void)playLocalSongsWithUrl:(NSString *)temp atIndex:(int)i scrollPosition:(CGPoint )p;

@end

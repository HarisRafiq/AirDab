//
//  SongsView.h
//  IMMedia
//
//  Created by YAZ on 8/8/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol SongsViewDelegate;
#import "SongsCell.h" 
@interface SongsView : UIView<UITableViewDataSource ,UITableViewDelegate >
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
 @property(nonatomic, assign) id <SongsViewDelegate> delegate;
-(void)setCellTitle:(NSString*)title;
-(void)reloadData;
@end
@protocol SongsViewDelegate<NSObject>
-(void)addSelectedSongView:(SongsCell *)c AtScrollPosition:(CGPoint)p;
-(void)playSongsWithUrl:(MPMediaItem *)temp atIndex:(int)i scrollPosition:(CGPoint )p;
-(void)playLocalSongsWithUrl:(NSString *)temp atIndex:(int)i scrollPosition:(CGPoint )p;

@end
































 
//
//  SongsView_Ipad.m
//  AirDab
//
//  Created by YAZ on 10/1/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "SongsCell.h"
#import "SongsView_Ipad.h"
#import "AudioPlayer.h"

@implementation SongsView_Ipad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(void)setupTable{
    
    tView=[[UITableView alloc] initWithFrame: CGRectMake(self.bounds.origin.x ,self.bounds.origin.y  , self.bounds.size.width  , self.bounds.size.height
                                                         )];
    tView.delegate=self;
    tView.dataSource=self;
    tView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tView.opaque=YES;
    tView.showsHorizontalScrollIndicator=NO;
    tView.showsVerticalScrollIndicator=NO;
    [self setBackgroundColor:[UIColor clearColor]];
    self.layer.backgroundColor=[UIColor clearColor].CGColor;
    tView.layer.backgroundColor=[UIColor clearColor].CGColor;
    
    [tView setBackgroundColor:[UIColor blackColor] ];
    [tView registerNib:[UINib nibWithNibName:@"SongsCell"
                                      bundle:[NSBundle mainBundle]]
forCellReuseIdentifier:@"MusicCell"];
    [self addSubview:tView];
    
}
#pragma mark - Table View Data Source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(!isLocalFile){
               MPMediaItem *temp = [currentArtistSongs objectAtIndex:indexPath.row];
        [self.delegate playSongsWithUrl: temp atIndex:indexPath.row scrollPosition:[tView contentOffset]];
    }
    else {
        SongsCell *c=(SongsCell *)[tView cellForRowAtIndexPath:indexPath];
        [[AudioPlayer sharedInstance] setCurrentSongTitle: [[[AudioPlayer sharedInstance] fileListArray] objectAtIndex:indexPath.row]] ;
        
        NSString *path=[self filePathForFileName: [[[AudioPlayer sharedInstance] fileListArray] objectAtIndex:indexPath.row]];
        NSURL *url=[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];;
        AudioFileID fileID;
        AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &fileID);
        Float64 outDataSize = 0;
        UInt32 thePropSize = sizeof(Float64);
        AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration, &thePropSize, &outDataSize);
       

        [[AudioPlayer sharedInstance] settduration: outDataSize]   ;
 AudioFileClose(fileID);
        url=nil;
        [[AudioPlayer sharedInstance] setCurrentArtwork:nil];
        
        [[AudioPlayer sharedInstance] setCurrentArtist:@"LOCAL"];
        [[AudioPlayer sharedInstance] setCurrentSongTotalDuration:c.duration.text];

                [self.delegate playLocalSongsWithUrl: [self filePathForFileName: [[[AudioPlayer sharedInstance] fileListArray] objectAtIndex:indexPath.row]] atIndex:indexPath.row scrollPosition:[tView contentOffset]];
    }
    
    
    
    
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!isLocalFile)
        return [  currentArtistSongs  count];
    return  [[[AudioPlayer sharedInstance] fileListArray] count]  ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MusicCell";
    SongsCell_Ipad *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[SongsCell_Ipad alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *songTitle;
    NSString *duration;
    if(!isLocalFile){
        MPMediaItem *song =  [currentArtistSongs objectAtIndex:indexPath.row];
        songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        duration=[song valueForProperty:MPMediaItemPropertyPlaybackDuration];
    }
    else {
        songTitle=[[[AudioPlayer sharedInstance] fileListArray] objectAtIndex:indexPath.row];
        NSString *path=[self filePathForFileName: [[[AudioPlayer sharedInstance] fileListArray] objectAtIndex:indexPath.row]];
        NSURL *url=[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];;
        AudioFileID fileID;
        AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &fileID);
        Float64 outDataSize = 0;
        UInt32 thePropSize = sizeof(Float64);
        AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration, &thePropSize, &outDataSize);
        AudioFileClose(fileID);
        duration=[NSString stringWithFormat:@"%f" ,outDataSize];
        
        
    }
    
    
    
    [cell.title setText:songTitle];
    [cell.duration setText:[self convertTimeFromSeconds:duration]];
    return cell;
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
        
        NSLog(@"Result of Time Conversion: %@:%@", minute, second);
        result = [NSString stringWithFormat:@"%@:%@", minute, second];
        
    } else {
        
        NSLog(@"Result of Time Conversion: %@:%@:%@", hour, minute, second);
        result = [NSString stringWithFormat:@"%@:%@:%@",hour, minute, second];
        
    }
    
    return result;
    
}


- (CGFloat)tableView:(UITableView *)t heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return  60;
    
}
-(void)setIsLocalFile:(BOOL)s;
{
    isLocalFile=s;
    
}
- (NSString*)filePathForFileName:(NSString*)filename
{
	NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	return [NSString stringWithFormat:@"%@/%@", docDir, filename];
}

-(void)layoutSubviews

{[super layoutSubviews];
    
    [tView setFrame: CGRectMake(self.bounds.origin.x ,self.bounds.origin.y  , self.bounds.size.width  , self.bounds.size.height
                                )];
    
    
    
}
-(void)reloadData{
    
    [tView removeFromSuperview];
    [self setupTable];
}

- (void)setUpWithArtist:(NSString *)artist{
    
    MPMediaQuery *songsQuery = [self queryFilteredByArtist:artist ];
    
    NSArray *songs = [songsQuery collections];
    
    if(currentArtistSongs!=nil){
        [currentArtistSongs removeAllObjects];
        currentArtistSongs=nil;
    }
    currentArtistSongs=[[NSMutableArray alloc] init];
    
    for (MPMediaItemCollection *artist in songs) {
        MPMediaItem *representativeItem = [artist representativeItem];
        
        [currentArtistSongs addObject:representativeItem];
    }
}

-(MPMediaQuery *)queryFilteredByArtist:(NSString *)artist {
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    MPMediaPropertyPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:artist forProperty:MPMediaItemPropertyArtist];
    [query addFilterPredicate:artistPredicate];
    
    
    return query;
}
@end


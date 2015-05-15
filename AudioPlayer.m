//
//  AudioPlayer.m
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "AudioPlayer.h"
#import "BufferChain.h"
#import "OutputNode.h"
@implementation AudioPlayer

@synthesize delegate;
static AudioPlayer *sharedInstance;
+ (void)initialize
{
	static BOOL initialized = NO;
	if(!initialized)
	{
		initialized = YES;
		sharedInstance = [[AudioPlayer alloc] init];
	}
}
+ (AudioPlayer *)sharedInstance
{
	return sharedInstance;
}

- (id)init {
    self = [super init];
	if (self)
	{  
        playstatus=0;
       
        audiounits=[[AudioUnits alloc] initWithController:self];
                 musicBufferChain = NULL;
        network=[Network sharedInstance];
		endOfInputReached = NO;
#if !TARGET_IPHONE_SIMULATOR
        MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
        //Group by Album Artist
        [artistsQuery setGroupingType:MPMediaGroupingArtist];
        //Grab the "MPMediaItemCollection"s and store it in "artistsArray"
        NSArray *artists = [artistsQuery collections];
        
        artistsArray=[[NSMutableArray alloc] init];
        for (MPMediaItemCollection *artist in  artists) {
            //Grab the individual MPMediaItem representing the collection
            MPMediaItem *representativeItem = [artist representativeItem];
            //Store it in the "artists" array
            [artistsArray addObject:representativeItem];
            
            
        }
        //[artists release];
        //[artistsQuery release];
        
        
#endif
        
        currentArtistIndex=0;
        currentArtistSongs=0;
        currentSongTitle=[[NSString alloc] init];
        currentSongTotalDuration=[[NSString alloc] init];
        currentArtwork=[[UIImage alloc] init];
        currentArtist=[[NSString alloc] init];
	}
	
	return self;
}


- (void)play:(NSURL *)url
{ [self stopMusicPlayer];
    if(outputNode)
    {[outputNode setShouldContinue:NO];
       
        [outputNode release];
        outputNode=nil;
	}
     
    outputNode=[[OutputNode alloc] initWithController:self previous:nil];

    if (musicBufferChain!=nil)
    {
        [musicBufferChain setShouldContinue:NO];
        
        [musicBufferChain release];
        musicBufferChain=nil;
    }
    
    
    musicBufferChain = [[BufferChain alloc] initWithController:self];
	
         if([artistsArray count]>currentArtistIndex){
	[musicBufferChain open:url withOutputFormat:[audiounits outputAudioDescription] isLocal:NO];
             isFirstChange=YES;

             if(([currentArtistSongs count]<nextSongIndex+1)&&([artistsArray count]<nextArtistIndex+1)){
                
                 isPrevLocal=NO;
                 isNextLocal=YES;
                 
                 
             }
             else {isPrevLocal=NO;
                 isNextLocal=NO;
             }

         
         
         }
         else {	[musicBufferChain open:url withOutputFormat:[audiounits outputAudioDescription] isLocal:YES];
             
             if((currentSongIndex>0) ){
                  
                  isFirstChange=NO;
                 isPrevLocal=YES;
                 isNextLocal=YES;
                 
                 
             }
             else {
                  
                 isPrevLocal=NO;
                 isNextLocal=YES;
             }
             
             
     }
    [audiounits setMusicOutputNode:outputNode ];
    [outputNode setup];
    [self startMusicPlayer];
   	[musicBufferChain launchThreads];
    
    
}


- (double)amountPlayed
{
	return [outputNode amountPlayed];
}


- (BufferChain *)musicBufferChain
{
	return musicBufferChain;
}
- (OutputNode *)outputNode
{
	return outputNode;
}
- (void)setPlaybackStatus:(int)status
{
    
    [self.delegate audioPlayer:self didChangeStatus:status ];
    
    
}

- (void)stopMusicPlayer
{
    
    playstatus=0;
    [audiounits stopLocalMusicPlayer];
     
}
- (void)startMusicPlayer
{
    
    [self stopMusicPlayer];
   
	[audiounits startLocalMusicPlayer];
    playstatus=1;
    
}

- (void)startVoip
{
   
    [audiounits startVOIP];
 
    
}
- (void)stopVoip
{
    
	[audiounits stopVOIP];
    if (musicBufferChain!=nil)
    {
        [musicBufferChain setShouldContinue:NO];
        
        [musicBufferChain release];
        musicBufferChain=nil;
    }
     
}
- (void)dealloc {
    [musicBufferChain release];
    [audiounits release];
    [super dealloc];
}


- (BOOL)endOfInputReached:(BufferChain *)sender //Sender is a BufferChain
{
    NSLog(@"END OF INPUT REACHED");
	
	return YES;
}
-(AudioUnits *)audiounits{
    
    return audiounits;
}
- (void)endOfInputPlayed
{
    if(outputNode){
        [outputNode setShouldContinue:NO];
    
        [outputNode setup];
    }
   [audiounits _resetTiming];
    if (musicBufferChain!=nil)
    {
        [musicBufferChain setShouldContinue:NO];
        
        [musicBufferChain release];
        musicBufferChain=nil;
    }
    if(isBackground)
        [self playNextTrack];
    else{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate audioPlayerDidFinsihPlaying:self];
    
    });
    }
    }


- (void)setUpWithArtist:(NSString *)artist{
    
    MPMediaQuery *songsQuery = [self queryFilteredByArtist:artist ];
    
    NSArray *songs = [songsQuery collections];
    if(currentArtistSongs!=nil)
        [currentArtistSongs release];
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
-(NSMutableArray *)currentArtistSongs{return currentArtistSongs;}
-(NSMutableArray *)artistsArray{return artistsArray;}
-(void)setCurrentSongIndex:(int)i{
    currentSongIndex=i;
    nextSongIndex=i+1;
    prevSongIndex=i-1;
    
}
-(void)setCurrentArtistIndex:(int)i{
    currentArtistIndex=i;
    nextArtistIndex=i+1;
    prevArtistIndex=i-1;
}
-(int)currentSongIndex{

    return currentSongIndex;
}
-(int)currentArtistIndex{
    
    return currentArtistIndex;
}
-(void)playPrevTrack{
    if(outputNode){
        [outputNode setShouldContinue:NO];
        
        [outputNode setup];
    }
    if([artistsArray count] >0){
    if(([currentArtistSongs count]>prevSongIndex&&prevSongIndex>=0&&!isPrevLocal)||(!isFirstChange&&!isPrevLocal))
    {
        if(!isFirstChange){
            
            [self setCurrentArtistIndex:[artistsArray count] -1] ;
            MPMediaItem *artistTemp = [artistsArray objectAtIndex:currentArtistIndex];
            
            [self setUpWithArtist:[artistTemp valueForProperty:MPMediaItemPropertyArtist]];
            currentSongIndex=[currentArtistSongs count];
            prevSongIndex=currentSongIndex-1;
             
            
            isFirstChange=YES;
             NSLog(@"NEXT isFirstChange");
        }
        nextSongIndex=currentSongIndex;
        currentSongIndex=prevSongIndex;
        MPMediaItem *temp = [currentArtistSongs objectAtIndex:currentSongIndex];
        prevSongIndex--;
        if (musicBufferChain!=nil)
        {
            [musicBufferChain setShouldContinue:NO];
            
            [musicBufferChain release];
            musicBufferChain=nil;
        }
        if(([currentArtistSongs count]<nextSongIndex+1)&&([artistsArray count]<nextArtistIndex+1)){
             
              isNextLocal=YES;
            isPrevLocal=NO;
            isFirstChange=YES;
             NSLog(@"NEXT is LOCAL");
             NSLog(@"PREV is ITUNES");
        }
        else {
            isNextLocal=NO;
            isPrevLocal=NO;
         NSLog(@"NEXT is ITUNES");
             NSLog(@"PREV is ITUNES");
        }
        
        musicBufferChain = [[BufferChain alloc] initWithController:self];
        MPMediaItemArtwork *artWork = [temp valueForProperty:MPMediaItemPropertyArtwork];
        tduration=[[temp valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        [self setCurrentArtwork: [artWork imageWithSize:CGSizeMake(150, 150)]  ] ;
        currentArtist= [[temp valueForProperty:MPMediaItemPropertyArtist] copy] ;
        currentSongTitle= [[temp valueForProperty:MPMediaItemPropertyTitle] copy] ;
        currentSongTotalDuration= [[self convertTimeFromSeconds:[temp valueForProperty:MPMediaItemPropertyPlaybackDuration]] copy] ;
        
        [musicBufferChain open:[temp valueForProperty:MPMediaItemPropertyAssetURL] withOutputFormat:[audiounits outputAudioDescription] isLocal:NO];
        [musicBufferChain launchThreads];
     
       
        if(!isBackground)
            [self.delegate audioPlayerDidStartPlayingPrevTrackWithMPItem:temp];
        if(isBackground)
            [self setNowPlayingInfo:0];

        
        
        return;
    }
         if([artistsArray count]>prevArtistIndex&&prevArtistIndex>=0&&(!isPrevLocal)){
            
            nextArtistIndex=currentArtistIndex;
            currentArtistIndex=prevArtistIndex;
            MPMediaItem *artistTemp = [artistsArray objectAtIndex:currentArtistIndex];
            prevArtistIndex--;
            [self setUpWithArtist:[artistTemp valueForProperty:MPMediaItemPropertyArtist]];
                        currentSongIndex=[currentArtistSongs count]-1;
            nextSongIndex=currentSongIndex+1;
            prevSongIndex=currentSongIndex-1;
            MPMediaItem *temp = [currentArtistSongs objectAtIndex:currentSongIndex];
           
            if (musicBufferChain!=nil)
            {
                [musicBufferChain setShouldContinue:NO];
                
                [musicBufferChain release];
                musicBufferChain=nil;
            }
            
            
            musicBufferChain = [[BufferChain alloc] initWithController:self];
             MPMediaItemArtwork *artWork = [temp valueForProperty:MPMediaItemPropertyArtwork];
             tduration=[[temp valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
            [self setCurrentArtwork: [artWork imageWithSize:CGSizeMake(150, 150)]  ] ;
             currentArtist= [[temp valueForProperty:MPMediaItemPropertyArtist] copy] ;
             currentSongTitle= [[temp valueForProperty:MPMediaItemPropertyTitle] copy] ;
             currentSongTotalDuration= [[self convertTimeFromSeconds:[temp valueForProperty:MPMediaItemPropertyPlaybackDuration]] copy] ;
            
            [musicBufferChain open:[temp valueForProperty:MPMediaItemPropertyAssetURL] withOutputFormat:[audiounits outputAudioDescription] isLocal:NO];
          
    [musicBufferChain launchThreads];
             
             
             if(!isBackground)
                 [self.delegate audioPlayerDidStartPlayingPrevTrackWithMPItem:temp];
             if(isBackground)
                 [self setNowPlayingInfo:0];
            return;
        }
    }
        if(([[self fileListArray] count]>prevSongIndex||isFirstChange)&&([[self fileListArray] count]>0)) {
        
            if(isFirstChange){
            prevSongIndex=0;
                currentSongIndex=1;
                
                isFirstChange=NO;
            }
        nextSongIndex=currentSongIndex;
        currentSongIndex=prevSongIndex;
        NSString *file=[self filePathForFileName:[[self fileListArray] objectAtIndex:currentSongIndex]];
        NSURL *url=[NSURL URLWithString:[file stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]] ;
            prevSongIndex--;

        if (musicBufferChain!=nil)
        {
            [musicBufferChain setShouldContinue:NO];
            
            [musicBufferChain release];
            musicBufferChain=nil;
        }
                   musicBufferChain = [[BufferChain alloc] initWithController:self];
        
            AudioFileID fileID;
            AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &fileID);
            Float64 outDataSize = 0;
            UInt32 thePropSize = sizeof(Float64);
            AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration, &thePropSize, &outDataSize);
            tduration=outDataSize;
            currentArtist=@"LOCAL";
            currentSongTitle= [[self fileListArray] objectAtIndex:currentSongIndex] ;
            currentSongTotalDuration=  [[self convertTimeFromSeconds:[NSString stringWithFormat:@"%f",outDataSize] ] copy]  ;
            [self setCurrentArtwork: nil ] ;
          

        [musicBufferChain open:url withOutputFormat:[audiounits outputAudioDescription] isLocal:YES];
            [musicBufferChain launchThreads];

            if(!isBackground)
            [self.delegate setTotalDuration:outDataSize];
            if(!isBackground)
            [self.delegate audioPlayerDidStartPlayingPrevTrackWithLocalSongs:[[self fileListArray] objectAtIndex:currentSongIndex] ];
            AudioFileClose(fileID);
            
        
            
            if(( prevSongIndex<0) ){
                
              
                                isPrevLocal=NO;
                isNextLocal=YES;
                isFirstChange=NO;
                 NSLog(@"PREV is ITUNES");
            }
            else {
                isPrevLocal=YES;
                isNextLocal=YES;
                NSLog(@"PREV is LOCAL");
            }
            if(isBackground)
                [self setNowPlayingInfo:0];
        return;
        
        
    }
    
    if(!isBackground)
        [self.delegate audioPlayerIsAlreadyPlayingFirstSong];
    
}

 
-(void)playNextTrack{
    if(outputNode){
        [outputNode setShouldContinue:NO];
        
        [outputNode setup];
    }
     if([artistsArray count] >0){
     if(([currentArtistSongs count]>nextSongIndex&&!isNextLocal)||(!isFirstChange&&!isNextLocal))
    {
        if(!isFirstChange){
            
            MPMediaItem *artistTemp = [artistsArray objectAtIndex:[artistsArray count ]-1];
            [self setUpWithArtist:[artistTemp valueForProperty:MPMediaItemPropertyArtist]];
            [self setCurrentArtistIndex:[artistsArray count] -1] ;
            currentSongIndex=[currentArtistSongs count]-2;
            nextSongIndex=[currentArtistSongs count]-1;
            
             isFirstChange=YES;
             NSLog(@"NEXT isFirstChange");
 
        }
        
        prevSongIndex=currentSongIndex;
        currentSongIndex=nextSongIndex;
        MPMediaItem *temp = [currentArtistSongs objectAtIndex:currentSongIndex];
        nextSongIndex++;
        if (musicBufferChain!=nil)
        {
            [musicBufferChain setShouldContinue:NO];
            
            [musicBufferChain release];
            musicBufferChain=nil;
        }
        if(([currentArtistSongs count]<nextSongIndex+1)&&([artistsArray count]<nextArtistIndex+1)){
             

            isNextLocal=YES;
            isPrevLocal=NO;
            isFirstChange=YES;
        }
        else {
            isNextLocal=NO;
            isPrevLocal=NO;
            
        }
        musicBufferChain = [[BufferChain alloc] initWithController:self];
        MPMediaItemArtwork *artWork = [temp valueForProperty:MPMediaItemPropertyArtwork];
        tduration=[[temp valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
        [self setCurrentArtwork: [artWork imageWithSize:CGSizeMake(150, 150)]  ] ;
        currentArtist= [[temp valueForProperty:MPMediaItemPropertyArtist] copy] ;
        currentSongTitle= [[temp valueForProperty:MPMediaItemPropertyTitle] copy] ;
        currentSongTotalDuration= [[self convertTimeFromSeconds:[temp valueForProperty:MPMediaItemPropertyPlaybackDuration]] copy] ;
        
        [musicBufferChain open:[temp valueForProperty:MPMediaItemPropertyAssetURL] withOutputFormat:[audiounits outputAudioDescription] isLocal:NO];
    
        [musicBufferChain launchThreads];
        
       
        if(!isBackground)
            [self.delegate audioPlayerDidStartPlayingNextTrackWithMPItem:temp];
        if(isBackground)
            [self setNowPlayingInfo:0];

        return;
    }
    
            if([artistsArray count]>nextArtistIndex &&(!isNextLocal)){
                        prevArtistIndex=currentArtistIndex; 

            currentArtistIndex=nextArtistIndex;
                        MPMediaItem *artistTemp = [artistsArray objectAtIndex:currentArtistIndex];
            nextArtistIndex++;
            
            [self setUpWithArtist:[artistTemp valueForProperty:MPMediaItemPropertyArtist]];
            nextSongIndex=1;
            currentSongIndex=0;
            prevSongIndex=-1;
            MPMediaItem *temp = [currentArtistSongs objectAtIndex:currentSongIndex];
             
            if (musicBufferChain!=nil)
            {
                [musicBufferChain setShouldContinue:NO];
                
                [musicBufferChain release];
                musicBufferChain=nil;
            }
            
            
            musicBufferChain = [[BufferChain alloc] initWithController:self];
            
                MPMediaItemArtwork *artWork = [temp valueForProperty:MPMediaItemPropertyArtwork];
                tduration=[[temp valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
                [self setCurrentArtwork: [artWork imageWithSize:CGSizeMake(150, 150)]  ] ;
                currentArtist= [[temp valueForProperty:MPMediaItemPropertyArtist] copy];
                currentSongTitle= [[temp valueForProperty:MPMediaItemPropertyTitle] copy] ;
                currentSongTotalDuration= [[self convertTimeFromSeconds:[temp valueForProperty:MPMediaItemPropertyPlaybackDuration]] copy] ;

            [musicBufferChain open:[temp valueForProperty:MPMediaItemPropertyAssetURL] withOutputFormat:[audiounits outputAudioDescription] isLocal:NO];
       
            [musicBufferChain launchThreads];
                                               if(!isBackground)
                    [self.delegate audioPlayerDidStartPlayingNextTrackWithMPItem:temp];
                if(isBackground)
                    [self setNowPlayingInfo:0];
            return;
                     
         
    
        }
         }
    if([[self fileListArray] count]>nextSongIndex||([[self fileListArray] count]>0&&isFirstChange ) ) {
        if(isFirstChange){
            nextSongIndex=0;
            currentSongIndex=-1;
            
            isFirstChange=NO;
            isPrevLocal=NO;
            isNextLocal=YES;
        }
        
        prevSongIndex=currentSongIndex;
        currentSongIndex=nextSongIndex;
        NSString *file=[self filePathForFileName:[[self fileListArray] objectAtIndex:currentSongIndex]];
        NSURL *url=[NSURL URLWithString:[file stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]] ;
        nextSongIndex++;
        if (musicBufferChain!=nil)
        {
            [musicBufferChain setShouldContinue:NO];
            
            [musicBufferChain release];
            musicBufferChain=nil;
        }
        if(( prevSongIndex<0) ){
            
          
            isPrevLocal=NO;
            isNextLocal=YES;
        }
        else {
            
            isPrevLocal=YES;
            isNextLocal=YES;
            
        }
 
                
        musicBufferChain = [[BufferChain alloc] initWithController:self];
        AudioFileID fileID;
        AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &fileID);
        Float64 outDataSize = 0;
        UInt32 thePropSize = sizeof(Float64);
        AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration, &thePropSize, &outDataSize);
        
        currentArtist=@"LOCAL";
        currentSongTitle= [[self fileListArray] objectAtIndex:currentSongIndex] ;
        tduration=outDataSize;
        currentSongTotalDuration=  [[self convertTimeFromSeconds:[NSString stringWithFormat:@"%f",outDataSize] ] copy] ;
        [self setCurrentArtwork: nil  ] ;
        [musicBufferChain open:url withOutputFormat:[audiounits outputAudioDescription] isLocal:YES];
          [musicBufferChain launchThreads];
     
        if(!isBackground)
            [self.delegate audioPlayerDidStartPlayingNextTrackWithLocalSongs:[[self fileListArray] objectAtIndex:currentSongIndex] ];
        if(isBackground)
            [self setNowPlayingInfo:0];

        AudioFileClose(fileID);

        
        
        
      
        
        
        return;
    
    
    }
    
    if(!isBackground)
        [self.delegate audioPlayerIsAlreadyPlayingLastSong];
}
-(void)setIsBackground:(BOOL)s{

    isBackground=s;

}
- (int)currentTime
{
         return   [audiounits playedFrames] ;
}  
- (int)totalTime
{
    return   [audiounits playedFrames] ;
}
-(NSArray *)fileListArray{

    return [network fileList];
}
-(NSString *)currentSongTitle{


    return currentSongTitle;
}
-(void)setCurrentSongTitle:(NSString *)s{
    
    
      currentSongTitle=[s copy];
}
-(void)setCurrentSongTotalDuration:(NSString *)s{
    
 
       currentSongTotalDuration=[s copy];
}
-(void)setCurrentArtist:(NSString *)s{
    
   
    currentArtist=[s copy];
}
-(void)setCurrentArtwork:(UIImage *)s {
    if(s==nil)
    {
        
        s=[UIImage imageNamed: @"wave-white.png"];
        
    }

    
 
    currentArtwork=[s copy];
}
- (NSString*)filePathForFileName:(NSString*)filename
{
	NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	return [NSString stringWithFormat:@"%@/%@", docDir, filename];
}
-(void)playPause{
    if(playstatus==1){
        
        [outputNode setShouldContinue:NO];
        playstatus=0;
    }
    else{
        [self startMusicPlayer];
       [outputNode setShouldContinue:YES] ;
         playstatus=1;
        
    }
}
-(NSString *)currentSongTotalDuration
{return currentSongTotalDuration;}
-(NSString *)currentArtist
{return currentArtist;}
-(UIImage *)currentArtwork{
    
    
    
    return currentArtwork;


}
- (int)playStatus{ return playstatus;}
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
-(void)seek:(float)frames{


    [[musicBufferChain inputNode] seek:frames];
}
- (void)enableScrubbingFromSlider:(UISlider *)slider
{
 
    [slider addTarget:self action:@selector(beginSeek) forControlEvents:UIControlEventTouchDown];
	[slider addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchDown];
	[slider addTarget:self action:@selector(endSeek) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside |UIControlEventTouchCancel];
 
}

- (void)disableScrubbingFromSlider:(UISlider *)slider
{
 
	[slider removeTarget:self action:@selector(beginSeek) forControlEvents:UIControlEventTouchDown];
	[slider removeTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchDown];
	[slider removeTarget:self action:@selector(endSeek) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside |UIControlEventTouchCancel];
}

- (void)scrub:(id)sender
{
    
    
	UISlider *playbackSlider = (UISlider*)sender;
    
	 
	NSTimeInterval seekTime = tduration * playbackSlider.value;
    [self seek:seekTime];
    [audiounits _resetTiming];
    [audiounits setPlayedFrames:seekTime*44100];
	
    
}
- (void)beginSeek
{
	[self playPause];
}

- (void)endSeek
{
	[self playPause];
}
-(double)tduration{

return tduration
    ;}

-(void)settduration:(double)s{
    tduration=s;
}
-(void)setNowPlayingInfo:(int)currentInx{
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[self currentArtwork] ];
        
        [songInfo setObject:[self currentSongTitle] forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:[self currentArtist]  forKey:MPMediaItemPropertyArtist];
        
        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
    }
    
}
@end

//
//  ICFViewController.m
//  player
//
//  Created by Kyle Richter on 3/2/13.
//  Copyright (c) 2013 Kyle Richter. All rights reserved.
//

#import "ICFViewController.h"


@implementation ICFViewController

@synthesize player;

#pragma mark -
#pragma mark Build up and Tear Down

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    player = [MPMusicPlayerController applicationMusicPlayer];
    
    volumeView.showsVolumeSlider = YES;
    volumeView.showsRouteButton = YES;
   
    if ([player playbackState] == MPMusicPlaybackStatePlaying)
    {
        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else
    {
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    [self updateSongDuration];
    [self updateCurrentPlaybackTime];
}




-(void)viewWillAppear:(BOOL)animated
{
    [self registerMediaPlayerNotifications];
    
    [super viewWillAppear: animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                  object: player];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                  object: player];
    
    [player endGeneratingPlaybackNotifications];
    
    [super viewWillDisappear: animated];
}

- (void)registerMediaPlayerNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (nowPlayingItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: player];
    
    [notificationCenter addObserver: self
                           selector: @selector (playbackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: player];
    
    [player beginGeneratingPlaybackNotifications];
}

#pragma mark -
#pragma mark Media Player Callbacks


- (void) nowPlayingItemChanged: (id) notification
{
    MPMediaItem *currentItem = [player nowPlayingItem];
    
    UIImage *artworkImage = [UIImage imageNamed:@"noArt.png"];
   
    MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
    
    if (artwork)
    {
        artworkImage = [artwork imageWithSize: CGSizeMake (120, 120)];
    
        if(artworkImage == nil)
        {
            artworkImage = [UIImage imageNamed:@"noArt.png"];
        }
    }
       
    [albumImageView setImage:artworkImage];
    
    NSString *titleString = [currentItem valueForProperty:MPMediaItemPropertyTitle];
    
    if (titleString)
    {
        songLabel.text = [NSString stringWithFormat:@"%@",titleString];
    }
    
    else
    {
        songLabel.text = @"Unknown Song";
    }
    
    NSString *artistString = [currentItem valueForProperty:MPMediaItemPropertyArtist];
   
    if (artistString)
    {
        artistLabel.text = [NSString stringWithFormat:@"%@",artistString];
    }
    
    else
    {
        artistLabel.text = @"Unknown artist";
    }
    
    NSString *albumString = [currentItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    if (albumString)
    {
        recordLabel.text = [NSString stringWithFormat:@"%@",albumString];
    }
    
    else
    
    {
        recordLabel.text = @"Unknown Record";
    }
}

- (void) playbackStateChanged: (id) notification
{
    MPMusicPlaybackState playbackState = [player playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused)
    {
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
        
        if([playbackTimer isValid])
            [playbackTimer invalidate];
    }
    else if (playbackState == MPMusicPlaybackStatePlaying)
    {
        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                              target:self
                                            selector:@selector(updateCurrentPlaybackTime)
                                            userInfo:nil
                                             repeats:YES];
        
    }
    
    else if (playbackState == MPMusicPlaybackStateStopped)
    {
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
        [player stop];
        
        if([playbackTimer isValid])
            [playbackTimer invalidate];
    }
}

#pragma mark -
#pragma mark  Playback Time

-(void)updateCurrentPlaybackTime;
{
    currentSongPlaybackTime = player.currentPlaybackTime;
    
    int tHours = (currentSongPlaybackTime / 3600);
    int tMins = ((currentSongPlaybackTime / 60) - tHours*60);
    int tSecs = (currentSongPlaybackTime) - (tMins*60) - (tHours *3600);
    currentTimeLabel.text = [NSString stringWithFormat:@"%i:%02d:%02d", tHours, tMins, tSecs ];
    
    float percentagePlayed = currentSongPlaybackTime/currentSongDuration;
    
    [playbackProgressIndicator setProgress:percentagePlayed];
    
    player.repeatMode = MPMusicRepeatModeAll;
    
    player.shuffleMode = MPMusicShuffleModeSongs;
    
}


-(void)updateSongDuration;
{
    currentSongPlaybackTime = 0;
    
    currentSongDuration = [[[player nowPlayingItem] valueForProperty: @"playbackDuration"] floatValue];
    int tHours = (currentSongDuration / 3600);
    int tMins = ((currentSongDuration / 60) - tHours*60);
    int tSecs = (currentSongDuration) - (tMins*60) - (tHours *3600);
    
    songDurationLabel.text = [NSString stringWithFormat:@"%i:%02d:%02d", tHours, tMins, tSecs ];
    
    currentTimeLabel.text = @"0:00:00";
    
}

#pragma mark -
#pragma mark  Actions

- (IBAction)previousButtonAction:(id)sender
{
    [player skipToPreviousItem];
    [self updateSongDuration];
}

- (IBAction)playButtonAction:(id)sender
{
    if ([player playbackState] == MPMusicPlaybackStatePlaying)
    {
        [player pause];
    }
  
    else
    {
        [player play];
    }
}

- (IBAction)nextButtonAction:(id)sender
{
    [player skipToNextItem];
    [self updateSongDuration];
}

- (IBAction)skipBack30Seconds:(id)sender
{
    int newPlayHead = player.currentPlaybackTime - 30;
    
    if(newPlayHead < 0)
    {
        newPlayHead = 0;
    }
    
    player.currentPlaybackTime = newPlayHead;
}

- (IBAction)skipForward30Seconds:(id)sender
{
    int newPlayHead = player.currentPlaybackTime + 30;
    
    if(newPlayHead > currentSongDuration)
    {
        [player skipToNextItem];
    }
    
    else
    {
        player.currentPlaybackTime = newPlayHead;
    }
}

#pragma mark -
#pragma mark Media Picker

- (IBAction)mediaPickerButtonAction:(id)sender
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.prompt = @"Select songs to play";
    [self presentViewController:mediaPicker animated:YES completion: nil];
    
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection)
    {
        [player setQueueWithItemCollection: mediaItemCollection];
        [player play];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Song Selection

- (IBAction)playRandomSongAction:(id)sender
{
    MPMediaItem *itemToPlay = nil;
    MPMediaQuery *allSongQuery = [[MPMediaQuery alloc] init];
    NSArray *allTracks = [allSongQuery items];
    
    if([allTracks count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No music found!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if ([allTracks count] < 2)
    {
        itemToPlay = [allTracks lastObject];
    }
    
    int trackNumber = arc4random() % [allTracks count];
    itemToPlay = [allTracks objectAtIndex:trackNumber];
        
    MPMediaItemCollection * collection = [[MPMediaItemCollection alloc] initWithItems:[NSArray arrayWithObject:itemToPlay]];
    [player setQueueWithItemCollection:collection];
    
    [player play];
        
    [self updateSongDuration];
    [self updateCurrentPlaybackTime];
}

- (IBAction)playDylan:(id)sender
{
    MPMediaPropertyPredicate *artistNamePredicate =
    [MPMediaPropertyPredicate predicateWithValue: @"James Morrison"
                                     forProperty: MPMediaItemPropertyArtist];
    
    MPMediaQuery *artistQuery = [[MPMediaQuery alloc] init];
    
    [artistQuery addFilterPredicate: artistNamePredicate];
    
    NSArray *tracks = [artistQuery items];

    
    if([tracks count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No music found!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    MPMediaItemCollection * collection = [[MPMediaItemCollection alloc] initWithItems:tracks];
    [player setQueueWithItemCollection:collection];
    
    [player play];
    
    [self updateSongDuration];
    [self updateCurrentPlaybackTime];

}

@end

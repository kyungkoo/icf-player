//
//  ICFViewController.h
//  player
//
//  Created by Kyle Richter on 3/2/13.
//  Copyright (c) 2013 Kyle Richter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>

@interface ICFViewController : UIViewController <MPMediaPickerControllerDelegate>
{
    
    IBOutlet UILabel *recordLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UILabel *songLabel;
    IBOutlet UIImageView *albumImageView;
    
    IBOutlet UIProgressView *playbackProgressIndicator;
    IBOutlet UIButton *playButton;
    
    MPMusicPlayerController *player;
    IBOutlet MPVolumeView *volumeView;
    
    float currentSongPlaybackTime;
    float currentSongDuration;
    
    IBOutlet UILabel *songDurationLabel;
    IBOutlet UILabel *currentTimeLabel;
    
    NSTimer *playbackTimer;
}

@property (nonatomic, strong) MPMusicPlayerController *player;

- (IBAction)mediaPickerButtonAction:(id)sender;
- (IBAction)previousButtonAction:(id)sender;
- (IBAction)playButtonAction:(id)sender;
- (IBAction)nextButtonAction:(id)sender;
- (IBAction)skipBack30Seconds:(id)sender;
- (IBAction)skipForward30Seconds:(id)sender;
- (IBAction)playRandomSongAction:(id)sender;
- (IBAction)playDylan:(id)sender;	

-(void)registerMediaPlayerNotifications;
-(void)updateSongDuration;
-(void)updateCurrentPlaybackTime;
@end

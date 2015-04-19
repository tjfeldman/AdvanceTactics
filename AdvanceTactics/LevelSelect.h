//
//  LevelSelect.h
//  AdvanceTactics
//
//  Created by Student on 5/20/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LevelSelect : SKScene

-(id) initWithSize:(CGSize)size andArmy: (NSArray *) army andBackgroundSoundPlaying: (AVAudioPlayer *) currentSound;

@end

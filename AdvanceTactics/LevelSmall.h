//
//  LevelSmall.h
//  AdvanceTactics
//
//  Created by Student on 5/19/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@interface LevelSmall : GameScene

-(id) initWithSize:(CGSize)size andArmy: (NSArray *) army onDifficulty: (kGameDifficulty) difficulty;

@end

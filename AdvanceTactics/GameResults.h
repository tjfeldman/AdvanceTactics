//
//  GameResults.h
//  AdvanceTactics
//
//  Created by Student on 5/17/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameResults : SKScene

-(id) initWithArmy: (NSArray *) army withGoldWon: (int) gold andUnitStatus: (NSString *) unitStatus didWin: (BOOL) win andSize: (CGSize) size;

@end

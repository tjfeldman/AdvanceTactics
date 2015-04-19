//
//  Tile.h
//  AdvanceTactics
//
//  Created by Student on 5/5/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Tile : SKSpriteNode
@property (nonatomic) CGPoint gridLocation;
@property (nonatomic) BOOL isAttackTile;
@property (nonatomic) float moveLeft;
@property (nonatomic) Tile *lastTile;

-(id) initWithGridLocation: (CGPoint) loc;
@end

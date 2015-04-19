//
//  Terrain.h
//  AdvanceTactics
//
//  Created by Student on 5/16/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameManager.h"

@interface Terrain : SKSpriteNode
@property (nonatomic) int moveCost;
@property (nonatomic) int defenseRating;
@property (nonatomic) int healPerTurn;
@property (nonatomic) kTerrainType type;
@property (nonatomic) CGPoint gridCoordinate;

-(id) initWithTerrainType: (kTerrainType) type;

@end

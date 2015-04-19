//
//  Unit.h
//  AdvanceTactics
//
//  Created by Student on 4/30/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameManager.h"

@interface Unit : SKSpriteNode

//stats
@property (nonatomic) int level;
@property (nonatomic) float hitpoints;
@property (nonatomic) float attack;
@property (nonatomic) float defense;
@property (nonatomic) int movement;
@property (nonatomic) int minRange;
@property (nonatomic) int maxRange;
@property (nonatomic) bool canMove;
@property (nonatomic) bool canAttack;
@property (nonatomic) NSMutableArray * abilities;

//enum types
@property (nonatomic) kUnitAlignment alignment;
@property (nonatomic) kUnitType type;
@property (nonatomic) kUnitState state;

//game helpers
@property (nonatomic) CGPoint lastPosition;
@property (nonatomic) int threatDisplay;



-(id) initWithUnitType: (kUnitType) unitType andIsAlignedTo: (kUnitAlignment) alignment;

-(void) resetTexture;
+(Unit *) getMobileUnitForPlayer;
+(Unit *) getTankUnitForPlayer;
+(Unit *) getRangeUnitForPlayer;
+(Unit *) getMobileUnitForEnemy;
+(Unit *) getTankUnitForEnemy;
+(Unit *) getRangeUnitForEnemy;

@end

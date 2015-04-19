//
//  GameManager.h
//  AdvanceTactics
//
//  Created by Student on 5/1/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface GameManager : SKSpriteNode


typedef enum
{
    kUnitTypeMobile,
    kUnitTypeTank,
    kUnitTypeRange,
    kUnitTypeNone
}kUnitType;

typedef enum
{
    kTerrainTypePlain,
    kTerrainTypeForest,
    kTerrainTypeMountain,
    kTerrainTypeFort,
    kTerrainTypeRoadHorizontal,
    kTerrainTypeRoadVertical,
    kTerrainTypeRoadBendUpRight,
    kTerrainTypeRoadBendUpLeft,
    kTerrainTypeRoadBendDownRight,
    kTerrainTypeRoadBendDownLeft
}kTerrainType;

typedef enum
{
    kUnitAlignmentPlayer,
    kUnitAlignmentEnemy
}kUnitAlignment;

typedef enum
{
    kUnitActive,
    kUnitStandby,
    kUnitDisplay,
    kUnitMoveLeft,
    kUnitMoveRight,
    kUnitMoveUp,
    kUnitMoveDown
}kUnitState;

typedef enum
{
    kConflictStatusNone,
    kConflictStatusLost,
    kConflictStatusTie,
    kConflictStatusWon
}kConflictStatus;

typedef enum
{
    kGameDifficultyTutorial, //x0
    kGameDifficultyEasy, // x.5
    kGameDifficultyMedium, // x1
    kGameDifficultyHard // x1.5
}kGameDifficulty;


+(NSString *) getFontName;

+(NSDictionary *) getStatsForUnitType: (kUnitType) type;
+(NSDictionary *) getStatsForTerrain: (kTerrainType) type;

+(NSString *) getImageNameForUnitType: (kUnitType) type andInState: (kUnitState) state;
+(NSString *) getImageNameForTerrainType: (kTerrainType) type andForDisplay: (BOOL) display;

+(int) getOverlayBlend: (kUnitAlignment) alignment;

+(float) getDamageDealtWithAttack: (float) attack againstDefense: (float) defense betweenAttackingType: (kUnitType) attacker andDefenderType: (kUnitType) defender withAttackerHealth: (float) atkHealth andDefenderHealth: (float) defHealth onTerrainDefense: (int) defenseRating;
+(kConflictStatus) doesUnit: (kUnitType) attacker winAgainst: (kUnitType) defender;

+(CGPoint) getAdjustedUnitSpawnForUnitNumber: (int) num;

+(NSArray *) createEnemyArmyWithPlayerStrength: (float) str playerArmySize: (int) size betweenMinNumer: (int) min andMaxNumber: (int) max onGameDifficulty: (kGameDifficulty) difficulty;

+(NSArray *) getExplosionTextures;
+ (NSArray *) getUnitMoveTexturesInDirection: (CGPoint) point forUnit: (kUnitType) type;

#pragma UPGRADE 
+(int) getUpgradeCostFor: (kUnitType) type atLevel: (int) level;
+(int) getBaseUnitCostFor: (kUnitType) type;
+(float) getIncreaseDefPerLevelFor: (kUnitType) type;
+(float) getIncreaseAtkPerLevelFor: (kUnitType) type;

@end

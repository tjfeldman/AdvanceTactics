//
//  GameScene.h
//  AdvanceTactics
//
//  Created by Student on 4/30/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GridManager.h"
#import "Unit.h"
#import "Tile.h"
#import "Terrain.h"
#import "GameManager.h"
#import "GameResults.h"


typedef enum
{
    kDrawingOrderBackground,
    kDrawingOrderGrid,
    kDrawingOrderTerrain,
    kDrawingOrderUnits,
    kDrawingOrderDisplay,
    kDrawingOrderForecast
}kDrawingOrder;

typedef enum
{
    kCurrentActionTurnSwitch,
    kCurrentActionGameLost,
    kCurrentActionGameWon,
    kCurrentActionNothing,
    kCurrentActionMovingUnit,
    kCurrentActionSelectingUnit,
    kCurrentActionAttackingUnit,
    kCurrentActionAI
}kCurrentAction;

typedef enum
{
    kObjectTypePlayerUnit,
    kObjectTypeEnemyUnit,
    kObjectTypeNothing
}kObjectType;

typedef enum
{
    kTurnPlayer,
    kTurnEnemy
}kTurn;

@interface GameScene : SKScene <UIAlertViewDelegate>
@property (nonatomic) GridManager * gridManager;
@property (nonatomic) kGameDifficulty difficulty;
@property (nonatomic) int turnNumber;
@property (nonatomic) kTurn currentTurn;
@property (nonatomic) kCurrentAction currentAction;
@property (nonatomic) CGPoint playerBase;
@property (nonatomic) CGPoint enemyBase;
@property (nonatomic) float averageStrength;

-(Unit *) getUnitAt: (CGPoint) location;

-(void) moveUnit: (Unit *) unit toTile: (Tile *) tile;
-(Unit *) findUnitAtLocation: (CGPoint) location;
-(CGPoint) getPlayerArmyAverage;
-(NSArray *) createOverlayWithUnit: (Unit *) unit;
-(int) getTileLocationIn: (NSArray*) array atLocation: (CGPoint) location;
-(void) givePositionToTile: (Tile *) tile;
-(kObjectType) getObjectTypeAt: (CGPoint) location;
-(Terrain *) getTerrainAtLocation: (CGPoint) location;
-(BOOL) canTargetUnit: (Unit *) target attackUnit: (Unit *) unit;
-(BOOL) canUnit: (Unit *) unit killTarget: (Unit *) target;

#pragma SETUP METHODS
-(void) setBackground: (Terrain *) background;
-(void) addPlayerArmy: (NSArray *) units;
-(void) addEnemyArmy: (NSArray *) units;
-(void) setTerrain: (NSArray *) terrain;

#pragma GET CONST
-(int) getGridWidth;
-(int) getGridHeight;
-(int) getInfoDisplayHeight;

#pragma END GAME
-(NSArray *) getArmyToSend;
-(void) endGame: (int) gold withPossibleBonus: (int) bonus;

@end

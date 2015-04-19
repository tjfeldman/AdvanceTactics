//
//  SelectedUnitDisplay.h
//  AdvanceTactics
//
//  Created by Student on 5/8/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Button.h"
#import "Unit.h"
#import "Terrain.h"

@interface SelectedUnitDisplay : SKSpriteNode

-(void) updateDisplayWithUnit: (Unit *) unit onTerrain: (Terrain *) terrain onEnemyTurn: (BOOL) enemyTurn;

-(Button *) getEndTurnButton;
-(Button *) getCancelTurnButton;
-(Button *) getEndMoveButton;

@end

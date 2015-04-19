//
//  UnitDisplay.h
//  AdvanceTactics
//
//  Created by Student on 5/19/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Unit.h"

@interface UnitDisplay : SKSpriteNode

-(id) initWithUnit: (Unit *) unit andDisplaySize: (CGSize) size;
-(BOOL) checkIfUpgradeIsTouched: (SKSpriteNode *) touchedNode;

-(void) updateUpgradeCost: (int) cost;
-(void) checkIfUpgradeCanBeBroughtWith: (int) gold;
-(void) increaseUnitALevel;
-(void) disableButton;
-(void) enableButton;
-(int) getUpgradeCost;
@end

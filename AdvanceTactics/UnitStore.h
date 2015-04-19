//
//  UnitStore.h
//  AdvanceTactics
//
//  Created by Student on 5/19/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface UnitStore : SKSpriteNode

-(id) initWithSize: (CGSize) size;

-(void) checkIfAbleToBuyWithGold: (int) gold andRoomLeft: (int) roomLeft;

-(BOOL) buyMobileClicked: (SKSpriteNode *) touchedNode;
-(BOOL) buyTankClicked: (SKSpriteNode *) touchedNode;
-(BOOL) buyRangeClicked: (SKSpriteNode *) touchedNode;

-(BOOL) shouldWeCloseStore: (SKSpriteNode *) touchedNode;

@end

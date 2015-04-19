//
//  UnitDisplay.m
//  AdvanceTactics
//
//  Created by Student on 5/19/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "UnitDisplay.h"
#import "Button.h"
#import "GameManager.h"

@implementation UnitDisplay
{
    Unit * _unit;
    Button * _upgrade;
    
    int _cost;
    
    SKSpriteNode *_unitPicture;
    SKLabelNode *_unitLevel;
    SKLabelNode *_unitAtk;
    SKLabelNode *_unitDef;
    SKLabelNode *_unitMove;
    SKLabelNode *_unitRange;
}

-(id) initWithUnit: (Unit *) unit andDisplaySize: (CGSize) size
{
    self = [super initWithColor:[UIColor grayColor] size:size];
    if (self)
    {
        _unit = unit;
        NSString * fontName = [GameManager getFontName];
        int fontSize = size.height/6;
        
        _unitPicture = [[SKSpriteNode alloc] initWithImageNamed: [GameManager getImageNameForUnitType:unit.type andInState:kUnitDisplay]];
        _unitPicture.position = CGPointMake(-size.width/4, 30);
        _unitPicture.size = CGSizeMake(size.width / 2, size.height - 15);
        [self addChild: _unitPicture];
        
        _unitLevel = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _unitLevel.fontSize = fontSize;
        _unitLevel.text = [NSString stringWithFormat: @"Level: %d", _unit.level];
        _unitLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _unitLevel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _unitLevel.position = CGPointMake(size.width/6, size.height/3);
        [self addChild: _unitLevel];
        
        _unitAtk = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _unitAtk.fontSize = fontSize;
        _unitAtk.text = [NSString stringWithFormat: @"Attack: %.0f", _unit.attack];
        _unitAtk.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _unitAtk.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _unitAtk.position = CGPointMake(size.width/6, _unitLevel.position.y - size.height/6);
        [self addChild: _unitAtk];
        
        _unitDef = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _unitDef.fontSize = fontSize;
        _unitDef.text = [NSString stringWithFormat: @"Defense: %.0f", _unit.defense];
        _unitDef.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _unitDef.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _unitDef.position = CGPointMake(size.width/6, _unitAtk.position.y - size.height/6);
        [self addChild: _unitDef];
        
        _unitMove = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _unitMove.fontSize = fontSize;
        _unitMove.text = [NSString stringWithFormat: @"Move: %d", _unit.movement];
        _unitMove.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _unitMove.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _unitMove.position = CGPointMake(size.width/6, _unitDef.position.y - size.height/6);
        [self addChild: _unitMove];
        
        _unitRange = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _unitRange.fontSize = fontSize;
        
        int minRange = _unit.minRange;
        int maxRange = _unit.maxRange;
        
        if (minRange < maxRange)
        {
            _unitRange.text = [NSString stringWithFormat: @"Range: %d-%d", minRange, maxRange];
        }
        else
        {
            _unitRange.text = [NSString stringWithFormat: @"Range: %d",minRange];
        }
        
        _unitRange.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _unitRange.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _unitRange.position = CGPointMake(size.width/6, _unitMove.position.y - size.height/6);
        [self addChild: _unitRange];
        
        _cost = 999999;
        NSString *testUpgrade = [NSString stringWithFormat: @"Upgrade(%d)", _cost];
        
        _upgrade = [[Button alloc] initWithButtonText:testUpgrade andSize:CGSizeMake(size.width/1.75, size.height/3.25)];
        _upgrade.position = CGPointMake(-size.width/5, -size.height/3);
        [self addChild: _upgrade];
        
    }
    return self;
}

-(int) getUpgradeCost
{
    return _cost;
}

-(void) increaseUnitALevel
{
    _unit.level ++;
    _unit.attack += [GameManager getIncreaseAtkPerLevelFor: _unit.type];
    _unit.defense += [GameManager getIncreaseDefPerLevelFor: _unit.type];
    
    _unitLevel.text = [NSString stringWithFormat: @"Level: %d", _unit.level];
    _unitAtk.text = [NSString stringWithFormat: @"Attack: %.0f", _unit.attack];
    _unitDef.text = [NSString stringWithFormat: @"Defense: %.0f", _unit.defense];
}

-(void) disableButton
{
    [_upgrade disableButton];
}

-(void) enableButton
{
    [_upgrade enableButton];
}

//returns true if button is in the state of being touched
-(BOOL) checkIfUpgradeIsTouched: (SKSpriteNode *) touchedNode
{
    return [_upgrade checkButtonTouchAt: touchedNode] == kButtonStateHit;
}

-(void) updateUpgradeCost: (int) cost
{
    _cost = cost;
    NSString *upgradeCost = [NSString stringWithFormat: @"Upgrade(%d)",  _cost];
    [_upgrade changeText: upgradeCost];
}

-(void) checkIfUpgradeCanBeBroughtWith: (int) gold
{
    if (gold >= _cost) [_upgrade enableButton];//enable button if it can be afforded
    else [_upgrade disableButton];//disable if player doesn't have enough money
}

@end

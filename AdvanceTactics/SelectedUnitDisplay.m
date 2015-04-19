//
//  SelectedUnitDisplay.m
//  AdvanceTactics
//
//  Created by Student on 5/8/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "SelectedUnitDisplay.h"


@implementation SelectedUnitDisplay
{
    SKLabelNode *_health;
    SKLabelNode *_atk;
    SKLabelNode *_def;
    SKLabelNode *_move;
    SKLabelNode *_range;
    SKSpriteNode *_selectedSprite;
    SKLabelNode *_level;
    
    Button *_endTurn;
    Button *_cancelUnitMove;
    Button *_endUnitMove;
}


-(id) initWithColor:(UIColor *)color size:(CGSize)size
{
    self = [super initWithColor:color size:size];
    if (self)
    {
        NSString *fontName = [GameManager getFontName];
        int fontSize = 32;
        
        _health = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _health.text = @"Health: 0/10";
        _health.fontSize = fontSize;
        _health.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _health.position = CGPointMake(3*fontSize/4, size.height -  size.height/3);
        _health.alpha = 0;
        [self addChild: _health];
        
        _level = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _level.text = @"Level: 1";
        _level.fontSize = fontSize;
        _level.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _level.position = CGPointMake (_health.position.x, _health.position.y + fontSize);
        [self addChild: _level];

        _atk = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _atk.text = @"Attack: 0";
        _atk.fontSize = fontSize;
        _atk.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _atk.position = CGPointMake(size.width/4 + fontSize, size.height - 1.5*fontSize - 2*size.height/6);
        _atk.alpha = 0;
        [self addChild: _atk];
        
        _def = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _def.text = @"Defense: 0";
        _def.fontSize = fontSize;
        _def.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _def.position = CGPointMake(size.width/4 + fontSize, size.height - 2*fontSize - 3*size.height/6);
        _def.alpha = 0;
        [self addChild: _def];
        
        _move = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _move.text = @"Movement: 0";
        _move.fontSize = fontSize;
        _move.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _move.position = CGPointMake(2*size.width/3 + fontSize, size.height - 1.5*fontSize - 2*size.height/6);
        _move.alpha = 0;
        [self addChild: _move];
        
        _range = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _range.text = @"Range: 0";
        _range.fontSize = fontSize;
        _range.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _range.position = CGPointMake(2*size.width/3 + fontSize, size.height - 2*fontSize - 3*size.height/6);
        _range.alpha = 0;
        [self addChild: _range];
        
        _selectedSprite = [[SKSpriteNode alloc] init];
        _selectedSprite.size = CGSizeMake(size.width / 5, size.width / 5);
        _selectedSprite.position = CGPointMake(size.width/8, size.height/3);
        _selectedSprite.alpha = 0;
        [self addChild:_selectedSprite];
        
        CGSize buttonSize = CGSizeMake(size.width/4, size.height/3.25);
        
        _endTurn = [[Button alloc] initWithButtonText:@"End Turn" andSize: buttonSize];
        _endTurn.position = CGPointMake(self.size.width/4 + fontSize*2 + 10, size.height -  size.height/5.9);
        _endTurn.fontSize = fontSize * 1.5;
        [self addChild: _endTurn];
        
       
        _endUnitMove = [[Button alloc] initWithButtonText:@"End Move" andSize:buttonSize];
        _endUnitMove.position = CGPointMake(_endTurn.position.x + self.size.width/4 + 2, size.height -  size.height/5.9);
        _endUnitMove.fontSize = fontSize * 1.5;
        _endUnitMove.alpha = 0;
        [self addChild: _endUnitMove];
        
        _cancelUnitMove = [[Button alloc] initWithButtonText:@"Cancel Action" andSize:buttonSize];
        _cancelUnitMove.position = CGPointMake(_endUnitMove.position.x + self.size.width/4 + 2, size.height -  size.height/5.9);
        _cancelUnitMove.fontSize = fontSize * 1.5;
        _cancelUnitMove.alpha = 0;
        [self addChild: _cancelUnitMove];
                             
    }
    
    return self;
}

-(void) updateDisplayWithUnit: (Unit *) unit onTerrain: (Terrain *) terrain onEnemyTurn: (BOOL) enemyTurn
{
    if (unit != nil)
    {
        NSString *imageName = [GameManager getImageNameForUnitType:unit.type andInState:kUnitDisplay];
        SKTexture *texture = [SKTexture textureWithImageNamed:imageName];
        _selectedSprite.texture = texture;
        
        _level.text = [NSString stringWithFormat: @"Level: %d", unit.level];
        _health.text = [NSString stringWithFormat:@"Health: %.0f/10", unit.hitpoints];
        _atk.text = [NSString stringWithFormat:@"Attack: %.0f", unit.attack];
        _def.text = [NSString stringWithFormat:@"Defense: %.0f", unit.defense];
        
       
        _move.text = [NSString stringWithFormat:@"Movement: %d", unit.movement];
        
        if (unit.maxRange > unit.minRange)
        {
            _range.text = [NSString stringWithFormat:@"Range: %d-%d", unit.minRange, unit.maxRange];
        }
        else
        {
            _range.text = [NSString stringWithFormat:@"Range: %d", unit.minRange];
        }
        
        _health.alpha = 1;
        _atk.alpha = 1;
        _def.alpha = 1;
        _move.alpha = 1;
        _range.alpha = 1;
        _level.alpha = 1;
        _selectedSprite.alpha = 1;
        [_selectedSprite setScale: 1];
        
        if (unit.canMove || unit.canAttack)
        {
            [_endTurn enableButton];
        }
        else
        {
            [_endTurn disableButton];
        }
        
        if (unit.alignment == kUnitAlignmentPlayer)
        {
            
            if (unit.canMove)
            {
                [_endUnitMove enableButton];
            }
            else
            {
                [_endUnitMove disableButton];
            }
            
            
            if (unit.canMove || unit.canAttack) { [_cancelUnitMove enableButton]; }
            //else if (!unit.canAttack && !unit.canMove) { [_cancelUnitMove enableButton]; }
            else { [_cancelUnitMove disableButton];  }
            [_endTurn changeText:@"End Unit"];
        }
        else
        {
            
            if (unit.threatDisplay != -1) [_endTurn changeText:@"Remove Threat"];
            else  [_endTurn changeText:@"Show Threat"];
            [_cancelUnitMove disableButton];
            [_endUnitMove disableButton];
            _cancelUnitMove.alpha = 0;
            _endUnitMove.alpha = 0;
        }
        
        if (enemyTurn) { _endTurn.alpha = 0;}
        
        
    }
    else
    {
        [self updateDisplayWithTerrain: terrain];
    }
}

-(void) updateDisplayWithTerrain:(Terrain *)terrain
{
    if (terrain != nil)
    {
        NSString *imageName = [GameManager getImageNameForTerrainType: terrain.type andForDisplay:YES];
        SKTexture *texture = [SKTexture textureWithImageNamed:imageName];
        _selectedSprite.texture = texture;
        
        _atk.text = [NSString stringWithFormat:@"Defense Rating: %d", terrain.defenseRating];
        _move.text = [NSString stringWithFormat:@"Movement Cost: %d", terrain.moveCost];
        
        _atk.alpha = 1;
        _move.alpha = 1;
        _selectedSprite.alpha = 1;
        [_selectedSprite setScale:.75];
        
        [_endTurn changeText:@"End Turn"];
        [_endTurn enableButton];
        
        _health.alpha = 0 ;
        _def.alpha = 0;
        _range.alpha = 0;
        _endUnitMove.alpha = 0;
        _cancelUnitMove.alpha = 0;
        _level.alpha = 0;

    }
}

-(Button *) getEndTurnButton
{
    return _endTurn;
}

-(Button *) getCancelTurnButton
{
    return _cancelUnitMove;
}

-(Button *) getEndMoveButton
{
    return _endUnitMove;
}
@end

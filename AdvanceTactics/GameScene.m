//
//  GameScene.m
//  AdvanceTactics
//
//  Created by Student on 4/30/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "GameScene.h"
#import "AIManager.h"
#import "SelectedUnitDisplay.h"
#import "CombatForecast.h"
#import "Button.h"
#import <AVFoundation/AVFoundation.h>

typedef enum
{
    kMovePriorityUp,
    kMovePriorityRight,
    kMovePriorityDown,
    kMovePriorityLeft,
    kMovePriorityDone
}kMovePriority;

const int kGridWidth = 64;
const int kGridHeight = 64;

const int kInfoDisplayHeight = 200;

const int goldIncreasePerEnemyStr = 25;//this is on easy difficulty. multiply it by difficulty
const int goldLostPerUnit = 15;//for each unit you lose this much gold

@implementation GameScene
{
    //Managers
    AIManager *_aiManager;

    Terrain *_background;
    
    SelectedUnitDisplay *_unitDisplay;
    CombatForecast *_combatForecast;
    
    CGPoint _lastTouch;
    bool _objectTouched;
    
    //objects being selected
    Unit *_currentObjectSelected;
    Unit *_selectedAttackTarget;
    Tile *_tileTouched;
    Terrain * _terrainSelected;
    
    NSArray *_overlay;
    NSMutableArray *_threatRanges;
    
    //unit arrays
    NSArray *_armyStart;//this holds the army the player started with, if they lose they are forced to start over with what they had
    NSMutableArray *_playerUnits;
    NSMutableArray *_enemyUnits;
    //terrain array
    NSArray *_terrainOnMap;
    
    CGPoint _cursorMemory;
    
    SKSpriteNode *_endTurn;

    BOOL _attack;
    
    //Controls background sound
    AVAudioPlayer *_playerTurn;
    AVAudioPlayer *_enemyTurn;
    
    int enemyStr;
}

#pragma GET CONST
-(int) getGridWidth { return kGridWidth; }
-(int) getGridHeight { return kGridHeight; }
-(int) getInfoDisplayHeight { return kInfoDisplayHeight; }


-(id) initWithSize:(CGSize)size
{
    self = [super initWithSize: size];
    if (self)
    {
        
        //default set ups
        _aiManager = [[AIManager alloc] initWithGameScene:self];
        
        _enemyUnits = [NSMutableArray array];
        _playerUnits = [NSMutableArray array];
        
        _currentTurn = kTurnPlayer;
        
        _currentAction = kCurrentActionNothing;//the player is not currently doing anything
        _objectTouched = NO;
        _currentObjectSelected = nil;
        _tileTouched = nil;
        
        _combatForecast = [[CombatForecast alloc] initWithSize:CGSizeMake(self.size.width/2, self.size.height/2) withFontName:[GameManager getFontName]];
        _combatForecast.position = CGPointMake(self.size.width/2, self.size.height/2);
        _combatForecast.zPosition = kDrawingOrderForecast;
        
        _threatRanges = [NSMutableArray array];
        
        _unitDisplay = [[SelectedUnitDisplay alloc] initWithColor:[UIColor grayColor] size:CGSizeMake(self.size.width, kInfoDisplayHeight)];
        _unitDisplay.position = CGPointMake(0, 0);
        _unitDisplay.zPosition = kDrawingOrderDisplay;
        _unitDisplay.anchorPoint = CGPointZero;
        [self addChild:_unitDisplay];
        
        self.turnNumber = 1;//you start at turn 1;
        
        //set the sounds of the game
        NSError *error;
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"08-sami-s-theme" ofType: @"mp3"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        
        _playerTurn = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error: &error];
        _playerTurn.numberOfLoops = -1;
        
        soundFilePath = [[NSBundle mainBundle] pathForResource: @"52-black-hole-theme" ofType: @"mp3"];
        fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        
        _enemyTurn = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error: &error];
        _enemyTurn.numberOfLoops = -1;
        
        [_playerTurn play];
    }
    
    return self;
}

//sets up the background
-(void) setBackground: (Terrain *) background
{
    _background = background;
    _terrainSelected = background;
    [self addChild: _background];
    
    //draw the grid
    int numberVertical = round(background.size.width/kGridWidth);
    int numberHorizontal = round (background.size.height/kGridHeight);
    CGSize gridVerticalSize = CGSizeMake(1, background.size.height);
    CGSize gridHorizontalSize = CGSizeMake(background.size.width, 1);
    
    for (int i = 0; i < numberVertical; i ++)
    {
        SKSpriteNode *line = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:gridVerticalSize];
        line.anchorPoint = CGPointMake(0, 0);
        line.position = CGPointMake(i * kGridWidth, 0);
        line.zPosition = kDrawingOrderGrid;
        [_background addChild: line];
    }
    for (int i = 0; i < numberHorizontal; i ++)
    {
        SKSpriteNode *line = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:gridHorizontalSize];
        line.anchorPoint = CGPointMake(0, 0);
        line.position = CGPointMake(0, i * kGridHeight);
        line.zPosition = kDrawingOrderGrid;
        [_background addChild: line];
    }
    
    //add the tiles to the array
    NSMutableArray * tilesLocationX = [NSMutableArray array];
    NSMutableArray * tilesLocationY = [NSMutableArray array];
    for (int i = 0; i <= numberVertical; i ++)
    {
        [tilesLocationX addObject: [NSNumber numberWithInt:i*kGridWidth + kGridWidth/2]];
    }
    for (int i = 0; i <= numberHorizontal; i ++)
    {
        [tilesLocationY addObject: [NSNumber numberWithInt:i*kGridHeight + kGridHeight/2]];
    }
    
    _gridManager = [[GridManager alloc] initWithGridX:tilesLocationX andWithGridY:tilesLocationY];
}

-(void) addPlayerArmy: (NSArray *) units
{
    [self addUnits: units forAlignment:kUnitAlignmentPlayer];
}

-(void) addEnemyArmy: (NSArray *) units
{
    NSMutableArray *enemies = [NSMutableArray array];
    
    enemyStr = 0;
    
    for (NSDictionary * d in units)
    {
        Unit * enemy;
        //let's create the enemy based on type
        switch ([d[@"Type"] intValue])
        {
            case kUnitTypeMobile:
                enemy = [Unit getMobileUnitForEnemy];
                break;
            case kUnitTypeTank:
                enemy = [Unit getTankUnitForEnemy];
                break;
            case kUnitTypeRange:
                enemy = [Unit getRangeUnitForEnemy];
                break;
            default:
                enemy = nil;
                break;
        }
        
        
        
        //as long as no nil enemies were created
        if (enemy != nil)
        {
            int level = [d[@"Level"] intValue];
            enemyStr += level;
            enemy.level = level;
            for (int count = 1; count < level; count ++)
            {
                enemy.attack += [GameManager getIncreaseAtkPerLevelFor: enemy.type];
                enemy.defense += [GameManager getIncreaseDefPerLevelFor: enemy.type];
            }
            
            [enemies addObject: enemy];
        }
        
        
    }//end for loop
    
    enemyStr /= enemies.count;
    
    [self addUnits: enemies forAlignment:kUnitAlignmentEnemy];
}

//set up the units in an array
-(void) addUnits: (NSArray *) units forAlignment: (kUnitAlignment) alignment
{
    for (Unit * unit in units)
    {
        int loc = (int)[units indexOfObject: unit] + 1;
        unit.zPosition = kDrawingOrderUnits;
        
        if (alignment == kUnitAlignmentPlayer)
        {
        
            CGPoint gridCoord = [_gridManager addX:_playerBase.x andAddY:_playerBase.y toPosition:[GameManager getAdjustedUnitSpawnForUnitNumber:loc]];
        
            unit.position = [_gridManager getCoordinatePositionAtGridPosition: gridCoord];
            
            self.averageStrength += unit.level;
        }
        else
        {
            CGPoint temp = [GameManager getAdjustedUnitSpawnForUnitNumber:loc];
            CGPoint gridCoord = [_gridManager addX:-temp.x andAddY:-temp.y toPosition:_enemyBase];
            
            unit.position = [_gridManager getCoordinatePositionAtGridPosition: gridCoord];
        }
        
        unit.lastPosition = unit.position;
        unit.canMove = YES;
        [_background addChild: unit];
    }
    if (alignment == kUnitAlignmentPlayer)
    {
        _playerUnits = [units mutableCopy];
        _armyStart = units;
        self.averageStrength = (float)self.averageStrength / (float)_playerUnits.count;
        //NSLog(@"Player Strenght: %f", self.averageStrength);
    }
    else if (alignment == kUnitAlignmentEnemy)
    {
        _enemyUnits = [units mutableCopy];
    }
}

//sets up the terrain
-(void) setTerrain:(NSArray *)terrain
{
    _terrainOnMap = terrain;
    for (Terrain * t in _terrainOnMap)
    {
        t.position = [_gridManager getCoordinatePositionAtGridPosition: t.gridCoordinate];
        t.zPosition = kDrawingOrderTerrain;
        if (t.type >= kTerrainTypeRoadHorizontal) t.zPosition = kDrawingOrderBackground;
        [_background addChild: t];
    }
}

#pragma TOUCHES
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self];
    
    _objectTouched = NO;
    
    [self checkTouches:touches onTouchesEnd:NO];
    
    //if player is doing nothing they can move the map
    _lastTouch = position;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self];
    
    //move map if it's the players turn and not currently switching turns
    if (_currentTurn == kTurnPlayer && _currentAction >= kCurrentActionNothing)
    {
        if (_currentAction != kCurrentActionAttackingUnit && _currentAction != kCurrentActionMovingUnit)
        {
            //if not doing attacking with or moving a unit, then move the map around
            int xDisplacement = _lastTouch.x - position.x;
            int yDisplacement = _lastTouch.y - position.y;
            
            CGPoint newPos = CGPointMake(_background.position.x - xDisplacement, _background.position.y - yDisplacement);
            
            _background.position = newPos;
            
            if (xDisplacement != 0 && yDisplacement != 0)
            {
                _objectTouched = YES;
            }
        }
        
        
    }
    
    [self checkTouches:touches onTouchesEnd:NO];
    
    _lastTouch = position;
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
    //CGPoint position = [touch locationInNode:self];
    
    [self checkTouches:touches onTouchesEnd:YES];
    
    
    //if we are moving or attacking and an object was touched and we have a tile to move to,
    //let's move the selected object
    if ((_currentAction == kCurrentActionAttackingUnit || _currentAction == kCurrentActionMovingUnit) && _objectTouched && _tileTouched != nil && _attack == NO)
    {
        [self moveUnit:_currentObjectSelected toTile: _tileTouched];
    }
    
    if (_attack) _attack = NO;
    
    if (!_objectTouched && _currentObjectSelected.alignment == kUnitAlignmentEnemy)
    {
        _currentAction = kCurrentActionNothing;
        _currentObjectSelected = nil;
    }
    
    
}

-(void) checkTouches: (NSSet *)touches onTouchesEnd: (BOOL) onEnd
{
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self];
    
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:position];
    
    Unit * temp = _currentObjectSelected;
  
    //we should only check touches if it's the players turn
    //we shouldn't check buttons if the player is attacking or moving
    //we also shouldn't check if the turns are switching over
    if (_currentTurn == kTurnPlayer && _currentAction != kCurrentActionMovingUnit && _currentAction != kCurrentActionAttackingUnit)
    {
        //let's check if a button is being touched
        if (_currentAction >= kCurrentActionNothing) [self checkButtonPresses:touchedNode onTouchesEnd: onEnd];
        //if we haven't touched an object, let's check player units
        if (onEnd && _currentAction >= kCurrentActionNothing)[self checkPlayerUnitTouch:touchedNode];
        //if we haven't touched an object, let's check enemy units
        if (onEnd && _currentAction >= kCurrentActionNothing)[self checkEnemyUnitTouch:touchedNode];
        //if we still ahvent' touched an object, let's check  terrain
        if (onEnd && _currentAction >= kCurrentActionNothing) [self checkTerrainTouch: touchedNode];
        //if we still haven't touched an object, let's check tiles
        if (onEnd && _currentAction >= kCurrentActionNothing)[self checkTileTouch:touchedNode];

        if (onEnd && _currentAction >= kCurrentActionNothing) { [self checkButtonPresses:nil onTouchesEnd: onEnd]; }//let's clear the buttons
        
        if (onEnd && position.y <= kInfoDisplayHeight && !_objectTouched)
        {
            _objectTouched = YES;
            _currentObjectSelected = temp;
        }
        
        
    }
    else if (_combatForecast.parent != nil)
    {
        [self checkCombatForecastButtons:touchedNode onTouchesEnd:onEnd];
    }
    
}

//let's check button press:
//end (unit) turn button
//deselect unit button
//confirm/cancel attack buttons
-(void) checkButtonPresses: (SKSpriteNode *) touchedNode onTouchesEnd: (BOOL) onEnd
{
    //check the end turn button
    kButtonState buttonState = [[_unitDisplay getEndTurnButton] checkButtonTouchAt:touchedNode];
    [self checkButtonState: buttonState onTouchesEnd: onEnd withBlock:^{
            _objectTouched = YES;
            //end the unit's turn
            if (_currentObjectSelected != nil)
            {
                if (_currentObjectSelected.alignment == kUnitAlignmentEnemy)
                {
                    //toggle the display
                    Unit *temp = _currentObjectSelected;
                    [self toggleThreatRangeFor: _currentObjectSelected];
                    _currentObjectSelected = temp;
                }
                else
                {
                    _currentObjectSelected.lastPosition = CGPointZero;
                    _currentObjectSelected.canAttack = NO;
                    
                    [self removeTilesInArray:_overlay];
                    _currentAction = kCurrentActionNothing;
                    [self updateThreatRange];
                }
            }
            //end player turn
            else
            {
                [self endTurn];
            }
    }];
    
    //check the cancel action button
    buttonState = [[_unitDisplay getCancelTurnButton] checkButtonTouchAt: touchedNode];
    [self checkButtonState: buttonState onTouchesEnd: onEnd withBlock:^{
        _currentObjectSelected.position = _currentObjectSelected.lastPosition;
        _currentAction = kCurrentActionNothing;
        [self updateThreatRange];
        [self removeTilesInArray: _overlay];
        _objectTouched = YES;

    }];
    
    //check the end move button
    buttonState = [[_unitDisplay getEndMoveButton] checkButtonTouchAt: touchedNode];
    [self checkButtonState: buttonState onTouchesEnd: onEnd withBlock:^{
        Unit * temp = _currentObjectSelected;
        _currentObjectSelected.lastPosition = CGPointZero;
        [self removeTilesInArray:_overlay];
        [self updateThreatRange];
        [self displayOverlayForUnit: temp];
        _currentAction = kCurrentActionSelectingUnit;
        _objectTouched = YES;
        
    }];
}

//if combat forecast is up, we only want to check the buttons on it, so we don't let anything else happen while it is up
-(void) checkCombatForecastButtons: (SKSpriteNode *) touchedNode onTouchesEnd: (BOOL) onEnd
{
    kButtonState buttonState = [[_combatForecast getConfirmButton] checkButtonTouchAt: touchedNode];
    [self checkButtonState: buttonState onTouchesEnd: onEnd withBlock:^{
        _objectTouched = YES;
        SKAction * attack = [self getAttackActionsForUnit:_currentObjectSelected atTileStep:_tileTouched];
        [_combatForecast removeFromParent];
        [_currentObjectSelected runAction: attack];
        [[_combatForecast getConfirmButton] unselectButton];
        _attack = YES;
    }];
    buttonState = [[_combatForecast getCancelButton] checkButtonTouchAt: touchedNode];
    [self checkButtonState: buttonState onTouchesEnd: onEnd withBlock:^{
        _objectTouched = YES;
        _currentAction = kCurrentActionSelectingUnit;
        _currentObjectSelected.position = _currentObjectSelected.lastPosition;
        [[_combatForecast getCancelButton] unselectButton];
        [_combatForecast removeFromParent];
        _tileTouched = nil;
    }];
}

-(void) checkButtonState: (kButtonState) state onTouchesEnd: (BOOL) onEnd withBlock: (void (^)(void)) callbackBlock
{
    if (state == kButtonStateHit && onEnd)
    {
        callbackBlock();
    }
}



//check to see if the player touched a player unit
-(void) checkPlayerUnitTouch: (SKSpriteNode *) touchedNode
{
    for (Unit *player in _playerUnits)
    {
        if ([touchedNode isEqual:player])
        {
            _objectTouched = YES;//we touched an object
            
            //if we are not already selecting a unit a player unit, let's select this unit
            if (_currentAction != kCurrentActionSelectingUnit && (player.canMove || player.canAttack))
            {
                [self removeTilesInArray: _overlay];
                [self displayOverlayForUnit: player];
            }

            
            if (_currentAction != kCurrentActionSelectingUnit)
            {
                _currentObjectSelected = player;//we selected this object
            }
        }
    }
}

-(void) checkEnemyUnitTouch: (SKSpriteNode *) touchedNode
{
    for (Unit *enemy in _enemyUnits)
    {
        //did we touch a tile
        if ([touchedNode isEqual:enemy])
        {
            _objectTouched = YES;//we touched an enemy
            if (_currentAction != kCurrentActionSelectingUnit) //if we aren't selecting a unit
            {
                _currentObjectSelected = enemy;
                
            }
            else if (_currentAction == kCurrentActionSelectingUnit)// if we are selecting a unit, can we attack it
            {
                //get the tile this unit is on
                CGPoint gridPosition = [_gridManager getGridPositionAtCoordinatePosition:enemy.position];
                int tilePos = [self getTileLocationIn:_overlay atLocation:gridPosition];
                
                //if this unit is on a tile, then let's attack it
                if (tilePos > -1)
                {
                    _tileTouched = _overlay[tilePos];//this is the tile we selected
                    _currentAction = kCurrentActionAttackingUnit;
                }
            }
        }
    }
    
}

//check terrain
-(void) checkTerrainTouch: (SKSpriteNode *) touchedNode
{
    for (Terrain *t in _terrainOnMap)
    {
        if ([touchedNode isEqual:t])
        {
            if (_currentAction == kCurrentActionSelectingUnit)
            {
                //let's prepare to move to this tile
                int tilePos = [self getTileLocationIn:_overlay atLocation:t.gridCoordinate];
                if (tilePos > 0 && tilePos < _overlay.count)
                {
                    _objectTouched = YES;//tile touched
                    _tileTouched = _overlay[tilePos];
                    if (!_tileTouched.isAttackTile)_currentAction = kCurrentActionMovingUnit;//only move if it's an attack tile
                }
                
            }
            if (_tileTouched == nil && _currentAction != kCurrentActionSelectingUnit)
            {
                //let's view this tile
                _terrainSelected = t;
                _currentObjectSelected = nil;
            }
        }
    }
    if ([touchedNode isEqual: _background] && _currentAction != kCurrentActionSelectingUnit)
    {
        _terrainSelected = _background;
        _currentObjectSelected = nil;
    }
    
}

//checks tile
-(void) checkTileTouch: (SKSpriteNode *) touchedNode
{
    for (Tile *tile in _overlay)
    {
        //let's check to see if we touched
        if ([touchedNode isEqual:tile] && _tileTouched == nil && !tile.isAttackTile)
        {
            //let's prepare to move to this tile
            _objectTouched = YES;//tile touched
            _tileTouched = tile;
            _currentAction = kCurrentActionMovingUnit;
        }
    }
}

#pragma MOVING METHODS
//returns the type of object that is at this grid location, ignores tiles
-(kObjectType) getObjectTypeAt: (CGPoint) location
{
    for (Unit *enemy in _enemyUnits)
    {
        
        CGPoint gridPosition = [_gridManager getGridPositionAtCoordinatePosition: enemy.position];
        if (gridPosition.x == location.x && gridPosition.y == location.y) { return kObjectTypeEnemyUnit; }//it's an enemy unit
        
        
    }
    
    for (Unit *player in _playerUnits)
    {
        CGPoint gridPosition = [_gridManager getGridPositionAtCoordinatePosition: player.position];
        if (gridPosition.x == location.x && gridPosition.y == location.y) { return kObjectTypePlayerUnit; }//it's a player unit
        
    }
    return kObjectTypeNothing;
}



//move a unit to target location
-(void) moveUnit: (Unit *) unit toTile: (Tile *) tile
{
    
    NSMutableArray * steps = [NSMutableArray array];
    BOOL goodMove = NO;
    //make sure the move is okay
    
  if (tile.isAttackTile)
    {
        //check for enemies on player turn
        if ([self getObjectTypeAt:tile.gridLocation] == kObjectTypeEnemyUnit && _currentTurn == kTurnPlayer)
        {
            goodMove = YES;
        }
        //check for player on enemy turn
        else if ([self getObjectTypeAt:tile.gridLocation] == kObjectTypePlayerUnit && _currentTurn == kTurnEnemy)
        {
            goodMove = YES;
        }
        
    }
    else if (tile != nil)
    {
        //if moving to a tile and not attacking, is the tile empty
        if ([self getObjectTypeAt:tile.gridLocation] == kObjectTypeNothing)
        {
            goodMove = YES;
        }
    }

    if (goodMove)
    {
        _currentAction = kCurrentActionMovingUnit;
        [unit removeAllActions];
        unit.position = unit.lastPosition;
        while (![tile.lastTile isEqual: tile])
        {
            [steps addObject:tile];
            tile = tile.lastTile;
        }
        if (steps.count == 0) {[steps addObject: tile];}
    }
    else
    {
        _tileTouched = nil;
        _currentAction = kCurrentActionSelectingUnit;
    }
    
    SKAction *move;
    
    for (int i = 0; i < steps.count; i ++)
    {
        Tile *tileStep = steps[i];
        //moving to tile in steps
        if (!tileStep.isAttackTile)
        {
            SKAction *moveTo = [SKAction moveTo:tileStep.position duration:.25];
            
            CGPoint direction = [_gridManager getDirectionBetween: tileStep.gridLocation and: tileStep.lastTile.gridLocation];
            
            //reverse direction for enemies so they don't appear to be moon walking
            if (unit.alignment == kUnitAlignmentEnemy) direction = CGPointMake(-direction.x, -direction.y);
            
            NSArray *movementTextures = [GameManager getUnitMoveTexturesInDirection:direction forUnit:unit.type];
            SKAction *moveAnimation = [SKAction animateWithTextures: movementTextures timePerFrame:.25/movementTextures.count];
            
            SKAction *moveToWithAnimation = [SKAction group: @[moveTo, moveAnimation]];
            
            
            if (move == nil)
            {
                move = moveToWithAnimation;
            }
            else
            {
                move = [SKAction sequence: @[moveToWithAnimation,move]];
            }
        }
        //attacking a unit at end of movement
        else
        {
            Unit * target = [self getUnitAt:tileStep.position];
            _currentAction = kCurrentActionAttackingUnit;
            SKAction * attack;
            if (_currentTurn == kTurnPlayer)
            {
                attack = [SKAction runBlock:^{
                    [self displayCombatDisplayBetween:unit and: target];
                }];
            }
            else
            {
                attack  = [self getAttackActionsForUnit:unit atTileStep:tileStep];
            }
            
            if (move == nil)
            {
                move = attack;
            }
            else
            {
                move = [SKAction sequence: @[attack,move]];
            }
            
        }
    }//end for loop
    
    SKAction *revertTexture = [SKAction runBlock:^{
        [unit resetTexture];
    }];
    
    //don't have player deal with undefined actions
    if (goodMove)
    {
    
        move = [SKAction sequence: @[move, revertTexture]];
        
        if (_currentAction == kCurrentActionMovingUnit)
        {
            SKAction * done = [SKAction runBlock:^{
                _tileTouched = nil;
                _currentAction = kCurrentActionSelectingUnit;
                if (_currentTurn == kTurnEnemy) { _currentAction = kCurrentActionAI; }
                
            }];
            move = [SKAction sequence: @[move, done]];
        }
        
        //add small wait time to before a unit moves
        if (_currentTurn == kTurnEnemy)
        {
            SKAction *wait = [SKAction waitForDuration:1];
            move = [SKAction sequence: @[wait, move]];
        }
        
        
         [unit runAction: move];
    }
    else if (_currentTurn == kTurnEnemy)
    {
         move = [SKAction waitForDuration:1];
        SKAction * done = [SKAction runBlock:^{
                _tileTouched = nil;
                _currentAction = kCurrentActionSelectingUnit;
                if (_currentTurn == kTurnEnemy) { _currentAction = kCurrentActionAI; }
                
            }];
        move = [SKAction sequence: @[move, done]];
        [unit runAction: move];
    }
    
    
    
}

#pragma ATTACKING METHODS
-(float) getDamageFromAttackBetweenUnit: (Unit *) unit andTarget: (Unit *) target
{
    int tDef = [self getTerrainDefenseAt:target.position];
    return [GameManager getDamageDealtWithAttack: unit.attack
                                  againstDefense:target.defense
                            betweenAttackingType: unit.type
                                 andDefenderType: target.type
                              withAttackerHealth: unit.hitpoints
                               andDefenderHealth: target.hitpoints
                                onTerrainDefense:tDef];
}

-(BOOL) canUnit: (Unit *) unit killTarget: (Unit *) target
{
    float damage = [self getDamageFromAttackBetweenUnit:unit andTarget:target];
    return damage > target.hitpoints;
}

-(int) getTerrainDefenseAt: (CGPoint) loc
{
    for (Terrain * t in _terrainOnMap)
    {
        if ([_gridManager isPoint:t.position equalTo:loc])
        {
            return t.defenseRating;
        }
    }
    
    return _background.defenseRating;
}

-(SKAction *) getAttackActionsForUnit: (Unit *) unit atTileStep: (Tile *) tileStep
{
    SKAction *attackActions = [SKAction runBlock:^{
        Unit * target = [self findUnitAtLocation:tileStep.position];
        SKSpriteNode *arrow = [[SKSpriteNode alloc] initWithImageNamed:@"arrow"];
        arrow.anchorPoint = CGPointMake(0.5,0);
        arrow.position = unit.position;
        
        CGPoint unitLoc = [_gridManager getGridPositionAtCoordinatePosition: unit.position];
        CGPoint targetLoc = [_gridManager getGridPositionAtCoordinatePosition: target.position];
        CGSize size;
        
        int deltaY = target.position.y - unit.position.y;
        int deltaX = target.position.x - unit.position.x;
        
        float angle = atan2(deltaY, deltaX) - M_PI/180 * 90;
        
        
        int displacement = sqrt(pow(abs(unitLoc.y - targetLoc.y), 2) + pow(abs(unitLoc.x - targetLoc.x),2));
        size = CGSizeMake(arrow.size.width, displacement * kGridHeight);
        
        arrow.size = size;
        arrow.zRotation = angle;
        arrow.yScale = 0;
        
        [_background addChild:arrow];
        
        if (_currentTurn == kTurnPlayer)[self removeTilesInArray:_overlay];
        
        SKAction *scaleToAttack = [SKAction scaleYTo:1 duration:.5];
        
        SKAction *attack = [SKAction runBlock:^{
            BOOL unitDied = false;
            [arrow removeFromParent];
            
            SKAction *resetAction = [SKAction runBlock:^{
                if (_currentTurn == kTurnEnemy) { _currentAction = kCurrentActionAI; }
                else { _currentAction = kCurrentActionNothing; }
            }];
            
            if (target != nil)
            {
                float damage = 0;
                damage = [self getDamageFromAttackBetweenUnit:unit andTarget:target];
                target.hitpoints -= damage;
                if (target.hitpoints <= 0)
                {
                    unitDied = true;
                    [self doDeathAnimationForUnit: target withReset:resetAction];
                }
                if ([self canTargetUnit:target attackUnit:unit] && target.hitpoints > 0)
                {
                    damage = [self getDamageFromAttackBetweenUnit: target andTarget: unit];
                    unit.hitpoints -= damage;
                    if (unit.hitpoints <= 0)
                    {
                        unitDied = true;
                        [self doDeathAnimationForUnit: unit withReset:resetAction];
                    }
                }
                unit.canMove = NO;
                unit.canAttack = NO;
                if (_currentTurn == kTurnPlayer)
                {
                    [self updateThreatRange];
                }
                _currentObjectSelected = nil;
            }
            
            SKAction *waitForAttack = [SKAction waitForDuration: .5];
            SKAction * attackOver = [SKAction sequence:@[waitForAttack, resetAction]];
            if (!unitDied) [self runAction: attackOver];
            else [self runAction: waitForAttack];
        }];
        
        
        SKAction *attackAnimation = [SKAction sequence:@[scaleToAttack, attack]];
        
        [arrow runAction:attackAnimation];
        
    }];
    
    
    return attackActions;
}

//this has a unit that died do an explosion animation
//this also pauses the game from moving on so win condition doesn't activate immediately
-(void) doDeathAnimationForUnit: (Unit *) unit withReset: (SKAction *) resetAction
{
    SKAction *death = [SKAction animateWithTextures:[GameManager getExplosionTextures] timePerFrame:.075f];
    SKAction *deathSound = [SKAction playSoundFileNamed: @"Bomb 2-SoundBible.com-953367492.mp3" waitForCompletion: NO];
    
    SKAction *deathAnimationWithSound = [SKAction group:@[death,deathSound]];
        
    SKAction *goInvisible = [SKAction fadeAlphaTo:0 duration:.1];
    
    SKAction *wait = [SKAction waitForDuration: .5];
    
    SKAction *remove = [SKAction removeFromParent];
    SKAction *unitDeath = [SKAction sequence:@[deathAnimationWithSound, goInvisible, wait,resetAction,remove]];
    unit.colorBlendFactor = 0;
    [unit runAction: unitDeath];
}

//when the player declares an attack, this will show the combat forecast
//combat forecast shows the expected damage results factoring in all terrain and stats
-(void) displayCombatDisplayBetween: (Unit *) unit and: (Unit *) target
{
    [self addChild: _combatForecast];
    
    float targetStartingHealth = target.hitpoints;
    float targetDamage = 0;
    float unitDamage = 0;
    
    targetDamage = [self getDamageFromAttackBetweenUnit:unit andTarget:target];
    target.hitpoints -= targetDamage;
    
    if ([self canTargetUnit:target attackUnit:unit] && target.hitpoints > 0)
    {
        unitDamage = [self getDamageFromAttackBetweenUnit:target andTarget:unit];
    }
    target.hitpoints = targetStartingHealth;
    
    [_combatForecast displayPredictionWithDamageToTarget:targetDamage fromTargetHealth:target.hitpoints andDamageToUnit:unitDamage fromUnitHealth:unit.hitpoints];
}

//return true if target is in range to attack back
-(BOOL) canTargetUnit: (Unit *) target attackUnit: (Unit *) unit
{
    NSMutableArray *attackRange = [NSMutableArray array];
    
    
    CGPoint pos = [_gridManager getGridPositionAtCoordinatePosition:target.position];
    
    Tile * tile = [[Tile alloc] initWithGridLocation:pos];
    tile.moveLeft = 0;
    tile.lastTile = tile;
    
    [self addAttackTilesWithMinRange:target.minRange toMaxRange:target.maxRange fromTile: tile onArray:attackRange forThreatRange:YES];
    
    for (Tile * tile in attackRange)
    {
        CGPoint gridLoc = tile.gridLocation;
        
        CGPoint location = [_gridManager getCoordinatePositionAtGridPosition:gridLoc];
        
        if ([_gridManager isPoint:location equalTo: unit.position])
        {
            return YES;
        }
    }
    
    return  NO;
}

#pragma OVERLAY METHODS

//displays the overlay for a player unit
-(void) displayOverlayForUnit: (Unit *) unit
{
    _overlay = [self createOverlayWithUnit: unit];
    [self displayTilesInArray: _overlay];
    _currentAction = kCurrentActionSelectingUnit;
}


//creates tiles using an algorithm to display the locations the unit can attack or move to
-(NSArray *) createOverlayWithUnit: (Unit *) unit
{
    
    CGPoint gridLocation = [_gridManager getGridPositionAtCoordinatePosition:unit.position];
    
    int move = unit.movement;
    int minRange = unit.minRange;
    int maxRange = unit.maxRange;
    
    Tile *startTile = [[Tile alloc] initWithGridLocation:gridLocation];
    startTile.lastTile = startTile;
    startTile.moveLeft = move;
    
    _currentObjectSelected = unit;
    
    NSMutableArray * array = [NSMutableArray array];
    
    if (unit.canMove)
    {
        [array addObject:startTile];
    }
    [self createNextTileFromTile:startTile withMinRange:minRange andMaxRange:maxRange andMovementCostLeft:move withArray: array];
    return array;
    
}

//a recursive method to cycle all possible movements and make sure the lastTile is the most efficent way to get to the new tile
-(void) createNextTileFromTile: (Tile *) lastTile withMinRange: (int) min andMaxRange: (int) max andMovementCostLeft: (int) move withArray: (NSMutableArray *) array
{
    //create attackLocations at this tile
    [self addAttackTilesWithMinRange:min toMaxRange:max fromTile: lastTile onArray: array forThreatRange: NO];
    
    kMovePriority direction = kMovePriorityUp;
    kObjectType objectType;
    CGPoint loc = lastTile.gridLocation;
    
    //don't attempt to move further if move is already 0
    if (move > 0)
    {
        while (direction != kMovePriorityDone)
        {
            CGPoint newLoc = [self getNewLocationFrom:loc withPriority:direction];
            
            //move to next direction if this tile would be off grid
            if (![_gridManager checkGridBoundsForGridPosition:newLoc])
            {
                direction ++;
                continue;
            }
            
            Terrain * t = [self getTerrainAtLocation: newLoc];
            int moveCost = t.moveCost;
            
            //mobile units can tranverse mountains
            if (_currentObjectSelected.type != kUnitTypeMobile && t.type == kTerrainTypeMountain)
            {
                moveCost *= 2;
            }
            
            //mobile units only pay 1 move cost on plains, unlike other units
            if (_currentObjectSelected.type == kUnitTypeMobile && t.type == kTerrainTypePlain)
            {
                moveCost = 1;
            }
            
            objectType = [self getObjectTypeAt:newLoc];
            
            //if the object type is an enemy and the turn is player, move on
            //or if the object type is a player and turn is enemy, move on
            if ((objectType == kObjectTypeEnemyUnit && _currentObjectSelected.alignment == kUnitAlignmentPlayer) || (objectType == kObjectTypePlayerUnit && _currentObjectSelected.alignment == kUnitAlignmentEnemy))
            {
                direction ++;
                continue;
            }

            //able to move without resulting in a negative move value
            if (move >= moveCost)
            {
                Tile *tile = nil;
                int tileLoc = [self getTileLocationIn:array atLocation:newLoc];
                if (tileLoc != -1)
                {
                    tile = array[tileLoc];
                    //if tile is an attack tile remove it from overlay and create a new blue tile at that location
                    if (tile.isAttackTile)
                    {
                        [array removeObjectAtIndex:tileLoc];
                        tile = nil;
                    }

                }
                if (tile == nil)
                {
                    tile = [[Tile alloc] initWithGridLocation:newLoc];
                }
                
                //only create the next tile if you are not about to go back to the tile you just came from
                if (![tile isEqual:lastTile])
                {
                    float newMove = move - moveCost;
                    if (tile.moveLeft < newMove)
                    {
                        tile.moveLeft = newMove;
                        tile.lastTile = lastTile;
                        //add tile if it's not already in the array
                        if ([self getTileLocationIn:array atLocation:tile.gridLocation] == -1)
                        {
                            //don't add a tile if it is outside of grid
                            if ([_gridManager checkGridBoundsForGridPosition:tile.gridLocation])
                            {
                                [array addObject:tile];
                            }
                        }
                        [self createNextTileFromTile:tile withMinRange:min andMaxRange:max andMovementCostLeft:newMove withArray: array];
                    }
                }//end if (![tile isEqual:lastTile])
                
                
            }//end if (move >= moveCost)
            
            direction ++;
        }//end while loop
    }//end if (move > 0)
}

//creates attackTiles around a tile based on the range of the source
-(void) addAttackTilesWithMinRange: (int) min toMaxRange: (int) max fromTile: (Tile *) tile onArray: (NSMutableArray *) array forThreatRange: (BOOL) threatRange
{
    CGPoint loc = tile.gridLocation;
    int xLoc = loc.x;
    int yLoc = loc.y;
    
    for (int i = min; i <= max; i ++)
    {
        for (int y = yLoc - i; y <= yLoc + i; y ++)
        {
            for (int x = xLoc - i; x <= xLoc + i; x ++)
            {
                CGPoint pos = CGPointMake(x,y);
                BOOL noObjectAtLastTile = [self getObjectTypeAt:tile.gridLocation] == kObjectTypeNothing;
                if (threatRange || tile.lastTile == tile) { noObjectAtLastTile = YES;}
                if (abs(x - xLoc) + abs(y - yLoc) == i && noObjectAtLastTile)
                {
                    
					Tile *attackTile = nil;
					int tileLoc = [self getTileLocationIn:array atLocation: pos];
					if (tileLoc != -1)
					{
						attackTile = array[tileLoc];
					}
                    
                    //extra check is making a threat range, add a new attack if the present tile is not an attack tile
                    if (threatRange && !attackTile.isAttackTile)
                    {
                        attackTile = nil;
                    }
					
					if (attackTile == nil)
                    {
                        attackTile = [[Tile alloc] initWithGridLocation:pos];
                        attackTile.isAttackTile = YES;
                        
                        //don't add a tile if it is outside of grid
                        if ([_gridManager checkGridBoundsForGridPosition:attackTile.gridLocation])
                        {
                            [array addObject:attackTile];
                        }
                    }
                    
                    
                    
                    if (attackTile.isAttackTile)
					{
                        if (attackTile.moveLeft < tile.moveLeft)
                        {
                            attackTile.lastTile = tile;
                            attackTile.moveLeft = tile.moveLeft;
                        }
					}
                }//end if(abs(x - xLoc) + abs(y - yLoc) == i && noObjectAtLastTile)
            }//end for loop (int x)
        }//end for loop (int y)
    }//end for loop (int i)
}

-(void) toggleThreatRangeFor: (Unit *) enemy
{

    //create an array of all tiles the player can attack and remove all the movement tiles
    NSMutableArray *threatRange = [[self createOverlayWithUnit:enemy] mutableCopy];
    for (int i = 0; i < threatRange.count; i ++)
    {
        Tile * tile = threatRange[i];
        if (!tile.isAttackTile)
        {
            [threatRange removeObjectAtIndex: i];
            [self addAttackTilesWithMinRange:enemy.minRange toMaxRange:enemy.maxRange fromTile:tile onArray:threatRange forThreatRange:YES];
            i --;
        }
        int firstTilePos = [self getTileLocationIn: threatRange atLocation:tile.gridLocation];
        if (i > firstTilePos)
        {
            //so if another tile exists that is the same to this tile
            //we need to remove it
            [threatRange removeObjectAtIndex: i];
            i --;
        }
        tile.color = [UIColor redColor];//have different color for threat
    }
    
    //let's look through it and see if we already this threat range drawn
    if (enemy.threatDisplay == -1)
    {
        [_threatRanges addObject: threatRange];
        [self displayTilesInArray: threatRange];
        enemy.threatDisplay = _threatRanges.count - 1;
    }
    else
    {
        [self removeThreatRangeAtIndex: enemy.threatDisplay];
    }

}

//this removes a threat range at an index and readjust all other enemies threat range
-(void) removeThreatRangeAtIndex: (int) index
{
    
    [self removeTilesInArray: _threatRanges[index]];
    [_threatRanges removeObjectAtIndex:index];
    
    for (Unit *enemy in _enemyUnits)
    {
        if (enemy.threatDisplay == index) { enemy.threatDisplay = -1; }
        if (enemy.threatDisplay > index) { enemy.threatDisplay --; }
    }
}

//this updates the threat for a unit
-(void) updateThreatRange
{
    for (Unit * e in _enemyUnits)
    {
        if (e.threatDisplay != -1)
        {
            //turn the threat range on and off
            [self removeThreatRangeAtIndex: e.threatDisplay];//remove the threat range first
            [self toggleThreatRangeFor:e];//now readd it
        }
    }
}

#pragma TILE METHODS

//gives tile a position
//gives the tile a position (-1,-1) if outside background
-(void) givePositionToTile: (Tile *) tile
{
    CGPoint gridLoc = tile.gridLocation;
    tile.position = [_gridManager getCoordinatePositionAtGridPosition: gridLoc];
}

//remove the tiles from the background
-(void) removeTilesInArray: (NSArray *) array
{
    for (Tile *tile in array)
    {
        [tile removeFromParent];
    }
    _currentObjectSelected.lastPosition = _currentObjectSelected.position;
    _currentObjectSelected = nil;
    _tileTouched = nil;

    array = [NSArray array];
    
}

//displays the tile in array on to screen
-(void) displayTilesInArray: (NSArray *) array
{
    for (int i = 0; i < array.count; i ++)
    {
        Tile * tile = array[i];
        [self givePositionToTile:tile];
        tile.size = CGSizeMake(kGridWidth,kGridHeight);
        tile.zPosition = kDrawingOrderGrid;
        [_background addChild: tile];
    }
}

#pragma GRID METHODS

//returns the unit at location
-(Unit *) findUnitAtLocation: (CGPoint) location
{
    Unit * unit = nil;
    
    for (Unit * player in _playerUnits)
    {
        if ([_gridManager isPoint:player.position equalTo:location])
        {
            return player;
        }
    }
    
    for (Unit * enemy in _enemyUnits)
    {
        if ([_gridManager isPoint:enemy.position equalTo:location])
        {
            return enemy;
        }
    }
    
    return unit;
}

//get the average of the locations of all the player units
//if none, returns (0,0)
-(CGPoint) getPlayerArmyAverage
{
    CGPoint average = CGPointMake(0,0);
    
    int count = 0;
    for (Unit * unit in _playerUnits)
    {
        count ++;
        average = CGPointMake(average.x + unit.position.x, average.y + unit.position.y);
    }
    
    //if no player units left
    if (count > 0)
    {
        //let's divide by count
        average = CGPointMake(round(average.x/count), round(average.y/count));
    }
    
    return average;
}

//looks through the array to see if it finds a tile in it
//if a tile exists it returns the location in that array
//otherwise returns -1
-(int) getTileLocationIn: (NSArray*) array atLocation: (CGPoint) location
{
    NSUInteger count = array.count;
    for (int i = 0; i < count; i++)
    {
        Tile *tile = array[i];
        if ([_gridManager isPoint:tile.gridLocation equalTo:location])
        {
            return i;
        }
    }
    return -1;
}

//checks to see if a unit exists at location and returns it
//returns nil if no unit exists
-(Unit *) getUnitAt: (CGPoint) location
{
    __block Unit *toReturn = nil;
    [_background enumerateChildNodesWithName:@"Unit" usingBlock: ^(SKNode *node, BOOL *stop) {
        Unit *unit = (Unit*)node;
        BOOL exists = [_gridManager isPoint:unit.position equalTo:location];
        if (exists) { toReturn = unit; }
    }];
    return toReturn;
}

//This method finds the terrain at a grid location and returns it.
-(Terrain *) getTerrainAtLocation: (CGPoint) location
{
    for (Terrain * t in _terrainOnMap)
    {
        if ([_gridManager isPoint:t.gridCoordinate equalTo:location])
        {
            return t;
        }
    }
    return _background;
}

-(CGPoint) getNewLocationFrom: (CGPoint) loc withPriority: (kMovePriority) direction
{
    CGPoint newLoc = loc;
    switch (direction)
    {
        case kMovePriorityUp:
        {
            newLoc = CGPointMake(loc.x, loc.y + 1);
            break;
        }
        case kMovePriorityRight:
        {
            newLoc = CGPointMake(loc.x + 1, loc.y);
            break;
        }
        case kMovePriorityDown:
        {
            newLoc = CGPointMake(loc.x, loc.y - 1);
            break;
        }
        case kMovePriorityLeft:
        {
            newLoc = CGPointMake(loc.x - 1, loc.y);
            break;
        }
            default:
            break;
    }
    return newLoc;
}

#pragma UPDATE

-(void)update:(NSTimeInterval)currentTime
{
    if (_currentAction >= kCurrentActionNothing)
    {
        
        int pUnitsActive = 0;
        int eUnitsActive = 0;
        
        //remove dead player units
        for (int i = 0; i < _playerUnits.count; i ++)
        {
            Unit * unit = _playerUnits[i];
            if (unit.hitpoints <= 0)
            {
                //[unit removeFromParent];
                [_playerUnits removeObjectAtIndex:i];
                i--;
                continue;
            }
            if (unit.canMove || unit.canAttack) { pUnitsActive ++; }
        }
        
        //remove dead enemy units
        for (int i = 0; i < _enemyUnits.count; i ++)
        {
            Unit * unit = _enemyUnits[i];

            if (unit.hitpoints <= 0)
            {
                //[unit removeFromParent];
                if (unit.threatDisplay != -1) [self removeThreatRangeAtIndex: unit.threatDisplay];
                [_enemyUnits removeObjectAtIndex:i];
                i--;
                continue;
            }
            if (unit.canMove) { eUnitsActive ++; }
        }
        
        //quit exit in the enemy kills all player units
        if (pUnitsActive == 0 && _currentAction == kCurrentActionAI) { _currentAction = kCurrentActionNothing; }
        
        //end turn if no units are active while no actions are going on
        if ((pUnitsActive == 0 || eUnitsActive == 0)  &&  _currentAction == kCurrentActionNothing)
        {
            [self endTurn];
        }
        
        if (_currentTurn == kTurnEnemy && _currentObjectSelected != nil)
        {
            int x = _currentObjectSelected.position.x - self.size.width/2;
            int y = _currentObjectSelected.position.y - self.size.height/2;
            
            _background.position = CGPointMake(-x, -y);
        }
        if (_currentObjectSelected != nil &&
            (_currentAction == kCurrentActionSelectingUnit || _currentAction == kCurrentActionNothing))
        {
            _terrainSelected = [self getTerrainAtLocation:
                               [_gridManager getGridPositionAtCoordinatePosition:
                                _currentObjectSelected.position]];
        }
        [_unitDisplay updateDisplayWithUnit: _currentObjectSelected onTerrain: _terrainSelected onEnemyTurn: _currentTurn == kTurnEnemy];
        
        //do AI actions when it's not already doing actions
        if (_currentTurn == kTurnEnemy && _currentAction == kCurrentActionAI)
        {
            if (eUnitsActive > 0)
            {
                for (Unit* unit in _enemyUnits)
                {
                    unit.lastPosition = unit.position;
                    if (unit.canMove)
                    {
                        [_aiManager aiActionForUnit: unit];
                        break;
                    }
                }
            }
            else
            {
                SKAction *waitToEndTurn = [SKAction waitForDuration: .5];
                SKAction *endTurn = [SKAction runBlock:^{
                    _currentAction = kCurrentActionNothing;
                }];
                SKAction * enemyEndTurn = [SKAction sequence: @[waitToEndTurn, endTurn]];
                [self runAction: enemyEndTurn];
            }
        }//end AI actions

    }//end if _currentAction != TurnSwitch || _currentAction > kCurrentActionNothing
    
    [self checkMapBounds];
    
    if (_playerUnits.count == 0 && _currentAction == kCurrentActionNothing) { _currentAction = kCurrentActionGameLost;}
    if (_enemyUnits.count == 0 && _currentAction == kCurrentActionNothing)  { _currentAction = kCurrentActionGameWon; }
}

-(void) endTurn
{
    [self setAllUnitsActive];
    [[_unitDisplay getEndTurnButton] checkButtonTouchAt: nil];//make sure end turn button isn't tapped
    
    SKLabelNode *turnEndNotification = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
    turnEndNotification.zPosition = kDrawingOrderForecast;
    turnEndNotification.fontSize = 72;
    
    NSMutableString * turnEndText = [[NSMutableString alloc] init];
    if (_currentTurn == kTurnPlayer)
    {
        [turnEndText appendFormat: @"Enemy"];
        turnEndNotification.fontColor = [UIColor redColor];
    }
    else
    {
        [turnEndText appendFormat: @"Player"];
        turnEndNotification.fontColor = [UIColor greenColor];
        
    }
    
    [turnEndText appendFormat: @"Turn!"];
    turnEndNotification.text = turnEndText;
    
    //switch turn if it's the player turn and enemies hasn't lost
    //switch turn if it's the enemy turn and player hasn't lost
    if ((_currentTurn == kTurnPlayer && _enemyUnits.count > 0) || (_currentTurn == kTurnEnemy && _playerUnits.count > 0))
    {
        _currentAction = kCurrentActionTurnSwitch;
        [[_unitDisplay getEndTurnButton] disableButton];
    }
    
    if (_currentAction == kCurrentActionTurnSwitch)
    {
        //if we are switching turn's lets display the turn end notification
        
        turnEndNotification.position = CGPointMake(-100,self.size.height/2 + kInfoDisplayHeight/2);
        turnEndNotification.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        
        SKSpriteNode *cover = [[SKSpriteNode alloc] initWithColor: [UIColor blackColor] size:self.size];
        cover.alpha = .65;
        cover.zPosition = kDrawingOrderDisplay;
        cover.anchorPoint = CGPointZero;
        [self addChild: cover];
        
        SKAction *moveToCenter = [SKAction moveToX: self.size.width/2 duration:.5];
        SKAction *wait = [SKAction waitForDuration: .75];
        SKAction *moveOffScreen = [SKAction moveToX: self.size.width + 150 duration: .5];
        SKAction *remove = [SKAction removeFromParent];
        SKAction *pauseCurrentSound = [SKAction runBlock:^{
            if (_currentTurn == kTurnPlayer &&  _enemyUnits.count > 0)
            {
                [_playerTurn pause];
            }
            else if (_currentTurn == kTurnEnemy && _playerUnits.count > 0)
            {
                [_enemyTurn pause];
            }
        }];
        SKAction *playPhaseSwitch = [SKAction playSoundFileNamed: @"Phase Change.wav" waitForCompletion:NO];
        SKAction *playNextSound = [SKAction runBlock:^{
            if (_currentTurn == kTurnPlayer &&  _enemyUnits.count > 0)
            {
                [_enemyTurn play];
            }
            else if (_currentTurn == kTurnEnemy && _playerUnits.count > 0)
            {
                [_playerTurn play];
            }
        }];
        SKAction *endTurn = [SKAction runBlock:^{
            cover.alpha = 0;
            [cover removeFromParent];
            if (_currentTurn == kTurnPlayer &&  _enemyUnits.count > 0)
            {
                [_playerTurn pause];
                
                [_enemyTurn play];
                _currentTurn = kTurnEnemy;
                _currentAction = kCurrentActionAI;
                [self healUnitsOnFortsForUnits:_enemyUnits];//heal enemies at beginning of thier turn
                _cursorMemory = _background.position;
                _terrainSelected = _background;
            }
            else if (_currentTurn == kTurnEnemy && _playerUnits.count > 0)
            {
                [_enemyTurn pause];
                [_playerTurn play];
                _currentTurn = kTurnPlayer;
                _currentAction = kCurrentActionNothing;
                [self updateThreatRange];
                [self healUnitsOnFortsForUnits:_playerUnits];//heal players at beginning of thier turn
                _currentObjectSelected = nil;
                [[_unitDisplay getEndTurnButton] enableButton];
                _background.position = _cursorMemory;
            }
            
            
        }];
        
        SKAction *displayTurnEnd = [SKAction sequence: @[pauseCurrentSound, playPhaseSwitch, moveToCenter, wait, moveOffScreen, playNextSound, endTurn, remove]];
        if (_playerUnits.count > 0 && _enemyUnits.count > 0)
        {
            [self addChild: turnEndNotification];
            [turnEndNotification runAction: displayTurnEnd];
        }
    }
    
}

-(void) healUnitsOnFortsForUnits: (NSArray *) units
{
    //heal units on turn switch
    for (Terrain * t in _terrainOnMap)
    {
        if (t.type == kTerrainTypeFort)
        {
            //search units if a fort has been found
            for (int i = 0; i < units.count; i ++)
            {
                Unit * unit = units[i];
                if ([_gridManager isPoint:unit.position equalTo:t.position])
                {
                    //if unit is wounded, heal it
                    if (unit.hitpoints < 10)
                    {
                        unit.hitpoints += 2;
                        
                        SKSpriteNode * backdrop = [[SKSpriteNode alloc] initWithColor: [UIColor blackColor] size: CGSizeMake(42,42)];
                        backdrop.zPosition = kDrawingOrderDisplay;
                        backdrop.position =  unit.position;
                        [_background addChild: backdrop];
                        
                        SKLabelNode * healthGain = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
                        healthGain.text = @"+2";
                        healthGain.fontColor = [UIColor greenColor];
                        healthGain.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
                        [backdrop addChild: healthGain];
                        
                        SKAction *moveHeal = [SKAction moveToY: unit.position.y + self.getGridHeight duration:.20];
                        SKAction *showHeal = [SKAction waitForDuration: .15];
                        SKAction *disappear = [SKAction fadeAlphaTo:0 duration:.25];
                        SKAction *removeSelf = [SKAction removeFromParent];
                        
                        [backdrop runAction: [SKAction sequence: @[moveHeal,showHeal, disappear ,removeSelf]]];
                        
                    }
                }//end check to see if fort in at same location as unit
            }//end for int i
        }//end check for terrin being fots
    }//end for terrain
}

//check map bounds
-(void) checkMapBounds
{
    
    CGPoint mapPos = _background.position;
    //NSLog(@"%d", infoDisplayHeight);
    if (mapPos.x > 0)
    {
        mapPos = CGPointMake(0, mapPos.y);
    }
    if (abs(mapPos.x) > _background.size.width - self.size.width)
    {
        mapPos = CGPointMake(-(_background.size.width - self.size.width), mapPos.y);
    }
    if (mapPos.y < -(_background.size.height - self.size.height))
    {
        mapPos = CGPointMake(mapPos.x, -(_background.size.height - self.size.height));
    }
    if (mapPos.y > kInfoDisplayHeight)
    {
        mapPos = CGPointMake(mapPos.x, kInfoDisplayHeight);
    }
    _background.position = mapPos;
    
}

-(void) setAllUnitsActive
{
    [_background enumerateChildNodesWithName:@"Unit" usingBlock:^(SKNode *node, BOOL *stop) {
        Unit *unit = (Unit*)node;
        unit.lastPosition = unit.position;
        unit.canMove = YES;
        unit.canAttack = YES;
    }];
    _currentObjectSelected = nil;
}

-(NSArray *) getArmyToSend
{
    if (_currentAction == kCurrentActionGameLost)
    {
        return _armyStart;
    }
    else if (_currentAction == kCurrentActionGameWon)
    {
        return _playerUnits;
    }
    return nil;
}

-(void) endGame: (int) gold withPossibleBonus: (int) bonus
{
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    NSArray * armyToSend = [self getArmyToSend];
    
    //heal the army and remove them from parents
    for (Unit * unit in armyToSend)
    {
        unit.hitpoints = 10;
        unit.alpha = 1;
        [unit removeFromParent];
        [unit resetTexture];
    }
    
    NSString *results;
    int unitLost = (int)_armyStart.count  - (int)_playerUnits.count;
    
    if (unitLost == _armyStart.count)
    {
        results = @"Your mission failled";
    }
    else
    {
        results = [NSString stringWithFormat: @"Your mission was successful!\nYou lost %d unit(s)", unitLost];
    }
    
    //add bonus gold for completing map with no unit loses
    if (unitLost == 0)
    {
        gold += bonus;
    }
    else
    {
        gold -= unitLost * goldLostPerUnit;
    }
    gold += goldIncreasePerEnemyStr * (self.difficulty - 1);
    gold = round(gold * self.difficulty/2.0f);//multiple the gold by the difficulty divided by 2
    
    BOOL win = unitLost != _armyStart.count;
    
    if (!win)
    {
        gold = 0;
    }
    
    // Create and configure the scene.
    GameResults * scene = [[GameResults alloc] initWithArmy: armyToSend withGoldWon:gold andUnitStatus: results didWin: win andSize: skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    //stop sound before presenting new scene
    [_playerTurn stop];
    [_enemyTurn stop];
    
    // Present the scene.
    [skView presentScene:scene];
}


@end

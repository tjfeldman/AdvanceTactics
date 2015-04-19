//
//  AIManager.m
//  AdvanceTactics
//
//  Created by Student on 5/7/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "AIManager.h"

@implementation AIManager
{
    GameScene *_scene;
    Unit * _currentUnit;
    kConflictStatus _currentStatus;
    BOOL _canKill;
    BOOL _isSafeAttack;
    float _lastTargetHeatlh;
}

-(id) initWithGameScene: (GameScene *) scene
{
    self = [super init];
    if (self)
    {
        _scene = scene;
    }
    return self;
}

//AI
//Attack the weakest unit factorying in triangle
//If no unit can be attack then move down
-(void) aiActionForUnit: (Unit *) unit
{
    
    
    _currentUnit = unit;
    _currentStatus = kConflictStatusNone;
    _canKill = NO;
    _isSafeAttack = NO;
    _lastTargetHeatlh = 0;

    Unit * target = nil;
    Tile * tileToMove = nil;
    Tile * closestToCenter = nil;
    Tile * safetyTile = nil;
    
    BOOL onFort = [_scene getTerrainAtLocation: [_scene.gridManager getGridPositionAtCoordinatePosition: _currentUnit.position]].type == kTerrainTypeFort;
    
    int displacement = -1;
    int safetyDistance = -1;
    
    NSArray * unitMoveActions =[NSArray array];
    
    unitMoveActions = [_scene createOverlayWithUnit:unit];
    
    CGPoint averageOfPlayerArmy = [_scene getPlayerArmyAverage];
    
    //we are low on health if we are playing on hard and current health is less than or equal to 3
    BOOL lowOnHealth = _currentUnit.hitpoints < 5.5 && _scene.difficulty == kGameDifficultyHard;
    //we are on a fort if we are on a fort and it's hard difficulty while we are damaged
    BOOL unitOnFort = onFort && _scene.difficulty == kGameDifficultyHard && _currentUnit.hitpoints <= 8;
    
    for (Tile * tile in unitMoveActions)
    {
        [_scene givePositionToTile:tile];
        if (tile.isAttackTile)
        {
           //check to see if we can attack anything
            Unit * temp = [self checkForTargetAt:tile];
            if (temp != nil)
            {
                if (target == nil)
                {
                    //if we are on hard and on a fort with low health, we should oly attack if we can attack from the fort
                    if (lowOnHealth && unitOnFort)
                    {
                        //if we are on a fort and can attack an enemy from it, we should
                        if ([_scene.gridManager isPoint: tile.lastTile.position equalTo: unit.position])
                        {
                            target = temp;
                            tileToMove = tile;
                        }
                    }
                    else if (!lowOnHealth)//otherwise we are only attacking if we are not low on health
                    {
                      target = temp; tileToMove = tile;
                      _currentStatus = [GameManager doesUnit: _currentUnit.type  winAgainst: temp.type];
                    }
                }//if there was no target, this is new target
                else
                {
                    //check to see if unit can attack based on difficulty
                    switch (_scene.difficulty)
                    {
                        case kGameDifficultyEasy:
                            if ([self isUnitABetterTargetOnEasy: temp])
                            {
                                target = temp;
                                tileToMove = tile;
                            }
                            break;
                        case kGameDifficultyMedium:
                            if ([self isUnitABetterTargetOnMedium:temp])
                            {
                                target = temp;
                                tileToMove = tile;
                            }
                        case kGameDifficultyHard:
                            if ([self isUnitABetterTargetOnHard: temp])
                            {
                                //enemy units should be able to attack while on fort
                                if (lowOnHealth && unitOnFort)
                                {
                                    //if we are on a fort and can attack an enemy from it, we should
                                    if ([_scene.gridManager isPoint: tile.lastTile.position equalTo: unit.position])
                                    {
                                        target = temp;
                                        tileToMove = tile;
                                    }
                                }
                                else
                                {
                                    target = temp;
                                    tileToMove = tile;
                                }
                            }
                            break;
                        default:
                            break;
                    }
                    
                }
            }
        }//if tile is attacking tile
        
        else
        {
            
            kObjectType type = [_scene getObjectTypeAt: tile.gridLocation];
            
            //find a tile that is closest to center
            int distance = sqrt(pow(averageOfPlayerArmy.x - tile.position.x, 2) + pow(averageOfPlayerArmy.y - tile.position.y, 2));
            
            if (displacement == -1 && type == kObjectTypeNothing)
            {
                displacement = distance;
                closestToCenter = tile;
            }
            else if (distance < displacement && type == kObjectTypeNothing)
            {
                displacement = distance;
                closestToCenter = tile;
            }
            
            //for hard difficulty let's check safetly tiles
            //safety tiles are tiles with a fort or far away from player army
            
            Terrain *temp = [_scene getTerrainAtLocation: tile.gridLocation];
            Terrain *current = [_scene getTerrainAtLocation: safetyTile.gridLocation];
            
            
            if (safetyDistance == -1 && type == kObjectTypeNothing)
            {
                safetyDistance = distance;
                safetyTile = tile;
            }
            else if (temp.type == kTerrainTypeFort && current.type != kTerrainTypeFort && type == kObjectTypeNothing)
            {
                safetyDistance = distance;
                safetyTile = tile;
            }
            else if (current.type == kTerrainTypeFort && temp.type != kTerrainTypeFort && type == kObjectTypeNothing)
            {
                //nothing, we want to move to this fort
            }
            else if (distance > safetyDistance && type == kObjectTypeNothing)
            {
                //if both the terrain are forts or both are not forts we want the one away from the player army
                safetyDistance = distance;
                safetyTile = tile;
            }
            
        }//end else
    }//end for loop
   

    //attack target
    if (target != nil)
    {
       // NSLog(@"Enemy attacking");
        [_scene moveUnit:unit toTile:tileToMove];
        
    }
    //move unit, this unit has movement and is able to move
    //although on hard, unit doesn't want to move off of a fort
    else if  (unit.movement > 0)
    {
        if (!lowOnHealth && !unitOnFort)
        {
            [_scene moveUnit:unit toTile:closestToCenter];
        }
        else if (!unitOnFort)
        {
            [_scene moveUnit: unit toTile:safetyTile];
        }
    }
    unit.canMove = NO;//this unit done
}

//if a unit exists at tile, it checks to see if this target is a better target in rock paper scissor
//this method is run on easy or higher
-(BOOL) isUnitABetterTargetOnEasy: (Unit *) unit
{
    kConflictStatus newStatus = [GameManager doesUnit: _currentUnit.type  winAgainst: unit.type];
    
    if (newStatus > _currentStatus)
    {
        _currentStatus = newStatus;
        return YES;//this target is a better target than previous target
    }
    else
    {
        return NO;//target wasn't a better choice, so let's not change
    }
    
    return NO;
}

//check to see if you can kill the target before it attack backs
//this method is run on medium or higher
-(BOOL) isUnitABetterTargetOnMedium: (Unit *) unit
{
    BOOL canKill = [_scene canUnit:_currentUnit killTarget:unit];
    kConflictStatus newStatus = [GameManager doesUnit: _currentUnit.type  winAgainst: unit.type];
    
    if (canKill)
    {
        //if the current target can also be killed, let's select the target who is the worse match up
        if (_canKill)
        {
            if (newStatus < _currentStatus)
            {
                _currentStatus = newStatus;//current match up is the worse one
                return YES;
            }
            else
            {
                return NO;
            }
        }
        else
        {
            _canKill = YES;
            return YES;
        }
    }
    else if (_canKill) { return NO; }
    return [self isUnitABetterTargetOnEasy: unit];
}

//check to see if the target won't attack back
//this method is run on hard
-(BOOL) isUnitABetterTargetOnHard: (Unit *) unit
{
    
    //first is the target unit able to be killed
    BOOL canKill = [_scene canTargetUnit: _currentUnit attackUnit:unit];
    BOOL wouldItAttackOnMedium = [self isUnitABetterTargetOnMedium: unit];
    
    if (canKill && wouldItAttackOnMedium) { return YES; }//this is the best target
    if (canKill && !wouldItAttackOnMedium) { return NO; }//we alredy have the besst
    
    //now let's see if the target unit beats range
    BOOL canTargetBeAttackedSafely = [self canTargetUnitBeAttackedSafely: unit];
    
    //both current target and new target can be safely attacked
    if (_isSafeAttack && canTargetBeAttackedSafely)
    {
        if (_lastTargetHeatlh < unit.hitpoints)
        {
            //the new target has more health and has more benefit to being attacked
            _lastTargetHeatlh = unit.hitpoints;
            return YES;
        }
        else
        {
            return NO;
        }
    }
    //if the last target was a safe target and this is not, don't attack new target
    if (_isSafeAttack && !canTargetBeAttackedSafely) { return NO; }
    
    //if last target was no safe and this is, then attack this one
    if (canTargetBeAttackedSafely)
    {
        _isSafeAttack = YES;
        _lastTargetHeatlh = unit.hitpoints;
        return YES;
    }
    
 
    //we haven't found a better target based on range and can be killed
    //let's see if the target is a better target on easy
    return [self isUnitABetterTargetOnEasy: unit];
}

//returns YES if the target is safe to attack
-(BOOL) canTargetUnitBeAttackedSafely: (Unit *) unit
{
    //if a target's min range is less than unit's max range or
    //if a target's min range is more than unit's max range
    //then the unit can't attack back
    return (unit.minRange < _currentUnit.maxRange || unit.maxRange > _currentUnit.minRange);
    
}



//checks to see if a target exists at a tile
//returns nil if no unit was found
-(Unit *) checkForTargetAt: (Tile *) tile
{
    Unit * unit = nil;
    
    
    kObjectType check = [_scene getObjectTypeAt:tile.gridLocation];
    if (check == kObjectTypePlayerUnit)
    {
        unit = [_scene getUnitAt:tile.position];
    }
    
    return unit;
}

@end

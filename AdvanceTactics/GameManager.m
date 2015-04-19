//
//  GameManager.m
//  AdvanceTactics
//
//  Created by Student on 5/1/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "GameManager.h"

const int levelVariantion = 4;//the random chance in levels never exceeds a difference of 4.

const int normalWeightForMobile = 60;//on normal difficulty, 60% of enemies are mobile
const int normalWeightForTank = 30;//on normal difficulty, 30% of enemies are tanks
const int normalWeightForRange = 10;//on normal difficulty, 10% of enemies are range

const int weightAdjustment = 10;//this adjustes the weight depending on difficulty

const int mobileMoveAnimationTexturesCount = 4;
const int otherMoveAnimationTexturesCount = 3;

@implementation GameManager

+(NSString *) getFontName
{
    UIFont *customFont;
    customFont = [UIFont fontWithName:@"Advance-Wars-2-GBA" size:20];
    return [customFont fontName];
}

+(NSDictionary *) getStatsForUnitType: (kUnitType) type
{
    NSMutableDictionary *stats = [@{
                            @"Health" : [NSNumber numberWithInt: 10],
                            @"Attack" : [NSNumber numberWithInt: 0],
                            @"Defense" : [NSNumber numberWithInt: 0],
                            @"Movement" : [NSNumber numberWithInt: 0],
                            @"MinRange" : [NSNumber numberWithInt: 0],
                            @"MaxRange" : [NSNumber numberWithInt: 0],
    } mutableCopy];
    
    switch (type)
    {
        case kUnitTypeMobile:
            stats[@"Attack"] = [NSNumber numberWithFloat:  5.00];
            stats[@"Defense"] = [NSNumber numberWithFloat: 0.25];
            stats[@"Movement"] = [NSNumber numberWithInt:6];
            stats[@"MinRange"] = [NSNumber numberWithInt: 1];
            stats[@"MaxRange"] = [NSNumber numberWithInt:1];
            break;
        case kUnitTypeTank:
            stats[@"Attack"] = [NSNumber numberWithFloat:  6.50];
            stats[@"Defense"] = [NSNumber numberWithFloat: 3.00];
            stats[@"Movement"] = [NSNumber numberWithInt:5];
            stats[@"MinRange"] = [NSNumber numberWithInt: 1];
            stats[@"MaxRange"] = [NSNumber numberWithInt:1];
            break;
        case kUnitTypeRange:
            stats[@"Attack"] = [NSNumber numberWithFloat:  7.25];
            stats[@"Defense"] = [NSNumber numberWithFloat: 0.75];
            stats[@"Movement"] = [NSNumber numberWithInt:3];
            stats[@"MinRange"] = [NSNumber numberWithInt:3];
            stats[@"MaxRange"] = [NSNumber numberWithInt:4];
            break;
        default:
            break;
    }
    
    return stats;
}

+(NSDictionary *) getStatsForTerrain: (kTerrainType) type 
{
    //plain defaults
    int moveCost = 2;
    int defenseRating = 1;
    int healPerTurn = 0;
    
    //forest stats
    if (type == kTerrainTypeForest)
    {
        moveCost = 2;
        defenseRating = 2;
        healPerTurn = 0;
    }
    
    //mountain stats
    if (type == kTerrainTypeMountain)
    {
        moveCost = 3;
        defenseRating = 4;
        healPerTurn = 0;
    }
    
    //fort stats
    if (type == kTerrainTypeFort)
    {
        moveCost = 1;
        defenseRating = 3;
        healPerTurn = 2;
    }
    
    //road stats
    if (type >= kTerrainTypeRoadHorizontal)
    {
        moveCost = 1;
        defenseRating = 0;
        healPerTurn = 0;
    }
    
    NSMutableDictionary *stats = [@{
                                    @"MoveCost" : [NSNumber numberWithInt: moveCost],
                                    @"DefenseRating" : [NSNumber numberWithInt: defenseRating],
                                    @"HealPerTurn" : [NSNumber numberWithInt: healPerTurn]
                                    } mutableCopy];
    
    return stats;
}

+(NSString *) getImageNameForUnitType: (kUnitType) type andInState: (kUnitState) state
{
    NSMutableString * textureName = [[NSMutableString alloc] init];
    switch (type)
    {
        case kUnitTypeMobile:
            [textureName appendString:@"mobile"];
            break;
        case kUnitTypeTank:
            [textureName appendString:@"tank"];
            break;
        case kUnitTypeRange:
            [textureName appendString:@"range"];
            break;
        default:
            break;
    }
    
    if (state == kUnitActive)
    {
        [textureName appendString:@"Active"];
    }
    else if (state == kUnitStandby)
    {
        [textureName appendString:@"Inactive"];
    }
    else if (state == kUnitDisplay)
    {
        [textureName appendString:@"Display"];
    }
    else if (state == kUnitMoveLeft)
    {
        [textureName appendString:@"MoveLeft"];
    }
    else if (state == kUnitMoveRight)
    {
        [textureName appendString:@"MoveRight"];
    }
    else if (state == kUnitMoveUp)
    {
        [textureName appendString:@"MoveUp"];
    }
    else if (state == kUnitMoveDown)
    {
        [textureName appendString:@"MoveDown"];
    }
    return textureName;
}

+(NSString *) getImageNameForTerrainType: (kTerrainType) type andForDisplay: (BOOL) display
{
    NSMutableString * textureName = [[NSMutableString alloc] init];
    switch (type) {
        case kTerrainTypeForest:
            [textureName appendString:@"Forest"];
            break;
        case kTerrainTypePlain:
            [textureName appendString:@"Plain"];
            break;
        case kTerrainTypeMountain:
            [textureName appendString:@"Mountain"];
            break;
        case kTerrainTypeFort:
            [textureName appendString:@"Fort"];
            break;
        case kTerrainTypeRoadHorizontal:
            [textureName appendString:@"roadHorizontal"];
            break;
        case kTerrainTypeRoadVertical:
            [textureName appendString:@"roadVertical"];
            break;
        case kTerrainTypeRoadBendUpRight:
            [textureName appendString:@"roadRightUpBend"];
            break;
        case kTerrainTypeRoadBendUpLeft:
            [textureName appendString:@"roadLeftUpBend"];
            break;
        case kTerrainTypeRoadBendDownRight:
            [textureName appendString:@"roadRightDownBend"];
            break;
        case kTerrainTypeRoadBendDownLeft:
            [textureName appendString:@"roadLeftDownBend"];
            break;
        default:
            break;
    }
    
    if (display)
    {
        if (type >= kTerrainTypeRoadHorizontal) { textureName = [NSMutableString stringWithString:@"Road"]; }
        [textureName appendString:@"Display"];
    }
    
    return  textureName;
}


+(int) getOverlayBlend: (kUnitAlignment) alignment
{
    switch (alignment)
    {
        case kUnitAlignmentEnemy:
            return 1;
        default:
            return 0;
    }
}

+(kConflictStatus) doesUnit: (kUnitType) attacker winAgainst: (kUnitType) defender
{
    
    switch (attacker) {
        case kUnitTypeMobile:
            if (defender == kUnitTypeRange) { return kConflictStatusWon; }
            else if (defender == kUnitTypeTank) { return kConflictStatusLost;}
            else { return kConflictStatusTie; }

        case kUnitTypeTank:
            if (defender == kUnitTypeMobile) { return kConflictStatusWon; }
            else if (defender == kUnitTypeRange) { return kConflictStatusLost;}
            else { return kConflictStatusTie; }
            
        case kUnitTypeRange:
            if (defender == kUnitTypeTank) { return kConflictStatusWon; }
            else if (defender == kUnitTypeRange) { return kConflictStatusLost;}
            else { return kConflictStatusTie; }
        default:
            return kConflictStatusTie;
    }

    
    return false;
}

+(int) getBaseUnitCostFor: (kUnitType) type
{
    switch (type)
    {
        case kUnitTypeMobile:
            return 100;
            break;
        case kUnitTypeTank:
            return 250;
            break;
        case kUnitTypeRange:
            return 500;
            break;
        default:
            break;
    }
    return -1;
}

+(int) getUpgradeCostFor: (kUnitType) type atLevel: (int) level
{
    int cost = 50;
    cost += 25 * type;
    
    level --;
    cost += 25 * level;
    cost += 25 * type * level;
    
    return cost;
}

+(float) getIncreaseAtkPerLevelFor: (kUnitType) type
{
    switch (type)
    {
        case kUnitTypeMobile:
            return .75f;
            break;
        case kUnitTypeTank:
            return .50f;
            break;
        case kUnitTypeRange:
            return .25f;
            break;
        default:
            break;
    }
    return 0;
}

+(float) getIncreaseDefPerLevelFor: (kUnitType) type
{
    switch (type)
    {
        case kUnitTypeMobile:
            return .25f;
            break;
        case kUnitTypeTank:
            return .50f;
            break;
        case kUnitTypeRange:
            return .75f;
            break;
        default:
            break;
    }
    return 0;
}

+(float) getDamageDealtWithAttack: (float) attack againstDefense: (float) defense betweenAttackingType: (kUnitType) attacker andDefenderType: (kUnitType) defender withAttackerHealth: (float) atkHealth andDefenderHealth: (float) defHealth onTerrainDefense: (int) defenseRating
{
    
    float atkHealthRemaining = atkHealth / 10.0f;
    float defHealthRemaining = defHealth / 10.0f;
    
    defense = defense * defHealthRemaining + (defenseRating * .75);

    float damage = attack * atkHealthRemaining - defense;
  
    
    if (damage < .5) { damage = .5; }
    
    
    return damage;
}

+(CGPoint) getAdjustedUnitSpawnForUnitNumber: (int) num
{
    switch (num) {
        case 1:
            return CGPointMake (1,0);
            break;
        case 2:
            return CGPointMake (0,1);
            break;
        case 3:
            return CGPointMake (0,-1);
            break;
        case 4:
            return CGPointMake (0,2);
            break;
        case 5:
            return CGPointMake (0,-2);
            break;
        case 6:
            return CGPointMake (1,1);
            break;
        case 7:
            return CGPointMake (1,-1);
            break;
        case 8:
            return CGPointMake (2,0);
            break;
        case 9:
            return CGPointMake (0,3);
            break;
        case 10:
            return CGPointMake (0,-3);
            break;
        case 11:
            return CGPointMake (1,3);
            break;
        case 12:
            return CGPointMake (1,-3);
            break;
        default:
            break;
    }
    
    return CGPointMake (0,0);
}

+(int)getRandomIntBetween:(int)from to:(int)to {
    
    return (int)(from + arc4random_uniform(to - from + 1));
    
}

//this method creates an enemy army relative to the player's average strength of his army and the difficulty level
+(NSArray *) createEnemyArmyWithPlayerStrength: (float) str playerArmySize: (int) size betweenMinNumer: (int) min andMaxNumber: (int) max onGameDifficulty: (kGameDifficulty) difficulty;
{
    NSMutableArray *enemies = [NSMutableArray array];
    
    str = round(str);
    
    int minLevel = 1;
    int maxLevel = 1;
    
    if (str > 1)//if the player has upgrade units
    {
        minLevel -= levelVariantion - difficulty;//higher difficulty causes less lower levels
        maxLevel += difficulty;//higher difficulty causes more higher levels
        
    }
    
    //adjust the min and max level caps based on the difficulty
    //easy is generally 2 levels below your average str
    //normal is around your average str
    //hard is generally 2 levels above your average str
    switch (difficulty)
    {
        case kGameDifficultyEasy:
            if (minLevel > 1)minLevel -= 2;
            maxLevel -= 2;
            break;
        case kGameDifficultyHard:
            if (minLevel > 1)minLevel += 2;
            maxLevel += 2;
            break;
        default:
            break;
    }
    
    //lowest level is 1
    if (minLevel < 1) minLevel = 1;
    if (maxLevel < 1) maxLevel = 1;
    

    //let's create random assortment of enemies
    for (int count = 0; count < max; count ++)
    {
        if (count > min && count <= size)
        {
            //while we are over the min number of enemies
            //and less than the player army
            //we have a 50% - 15% per a unit less we are chance to break the loop
            if (50 - (15 * (size - count)) >= arc4random()%100) break;
        }
        if (count >= size && count >= min)
        {
            //while we are over the min number of enemies
            //and move than the player army
            //we have a 80% chance to break that increases by 10% per a unit over
            if (80 + (10 * (count - size)) >= arc4random()%100) break;
        }
        
        kUnitType enemyType = kUnitTypeNone;
        //if we haven't breaked than we have a 1 in 3 chance of selecting a unit
        float typeChance = arc4random()%100;
        int adjustment = weightAdjustment * (difficulty - kGameDifficultyMedium);//adjusted weight is 0 at difficutly medium
        int lastChance = normalWeightForMobile - adjustment;;
        
        if (lastChance >= typeChance)
        {
            enemyType = kUnitTypeMobile;
        }
        else
        {
            lastChance += normalWeightForTank + adjustment/2;
            if (lastChance >= typeChance)
            {
                enemyType = kUnitTypeTank;
            }
            else
            {
                lastChance += normalWeightForRange + adjustment/2;
                if (lastChance >= typeChance)
                {
                    enemyType = kUnitTypeRange;
                }
            }

        }

        NSDictionary * enemy = @{
                                 @"Type" : [NSNumber numberWithInt: enemyType],
                                 @"Level": [NSNumber numberWithInt: [self getRandomIntBetween:minLevel to:maxLevel]]
                                  };
        [enemies addObject: enemy];
    }
    
    return enemies;
    
}

//this method returns the array of textures for the unit explosion animation
+(NSArray *) getExplosionTextures
{
    NSMutableArray *explosion = [NSMutableArray array];
    
    for (int i = 1; i <= 12; i ++)
    {
        NSString * textureName = [NSString stringWithFormat: @"explosion%d", i];
        SKTexture *texture = [SKTexture textureWithImageNamed: textureName];
        [explosion addObject: texture];
    }
    
    return explosion;
}

//this method grabs the array of textures for the unit movement
//send in a direction point:
// (1,0) = right
// (-1, 0) = left;
// (0, 1) = up;
// (0, -1) = down;
+ (NSArray *) getUnitMoveTexturesInDirection: (CGPoint) point forUnit: (kUnitType) type
{
    kUnitState direction;
    //get the direction unit is moving in
    if (point.x == 1) direction = kUnitMoveRight;
    else if (point.x == -1) direction = kUnitMoveLeft;
    else if (point.y == 1) direction = kUnitMoveUp;
    else direction = kUnitMoveDown;
    
    NSMutableArray *textures = [NSMutableArray array];
    
    int num = 0;
    
    //different units have different animation number
    switch (type)
    {
        case kUnitTypeMobile:
            num = mobileMoveAnimationTexturesCount;
            break;
        default:
            num = otherMoveAnimationTexturesCount;
            break;
    }
    
    for (int i = 0; i < num; i ++)
    {
        NSString * textureName = [NSString stringWithFormat: @"%@%d", [self getImageNameForUnitType: type andInState:direction], i + 1];
        SKTexture *texture = [SKTexture textureWithImageNamed: textureName];
        [textures addObject: texture];
    }
    
    return textures;
}




@end

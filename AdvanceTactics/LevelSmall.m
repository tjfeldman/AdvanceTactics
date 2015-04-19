//
//  LevelSmall.m
//  AdvanceTactics
//
//  Created by Student on 5/19/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "LevelSmall.h"

const int goldGainBase = 250;//you get this much gold for completing this map
const int goldGainPerfect = 75;//you get this much extra for completing this map with no unit deaths

const int minEnemyCount = 2;
const int maxEnemyCount = 8;

@implementation LevelSmall

-(id) initWithSize:(CGSize)size andArmy: (NSArray *) army onDifficulty: (kGameDifficulty) difficulty
{
    self = [super initWithSize: size];
    if (self)
    {
        self.difficulty = difficulty;
        
        
        //set up background
        Terrain * background = [[Terrain alloc] initWithTerrainType:kTerrainTypePlain];
        [background setScale: 1];
        background.size = CGSizeMake(self.size.width, self.size.height - [self getInfoDisplayHeight]);
        background.position = CGPointMake(0, (background.size.height - self.size.height) / -2.0f + [self getInfoDisplayHeight]);
        background.zPosition = kDrawingOrderBackground;
        background.anchorPoint = CGPointMake(0,0);
        [self setBackground: background];
        
        //set up grid
        int gridWidth = [self.gridManager getGridWidth];
        int gridHeight = [self.gridManager getGridHeight];
        
        //set up player and enemy base locations
        self.playerBase = CGPointMake(0, gridHeight/2);
        self.enemyBase = CGPointMake(gridWidth - 1, gridHeight/2);
        
        //add terrain
        NSMutableArray *terrain = [NSMutableArray array];
        
        //first let's add the two bases
        Terrain *pBase = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        pBase.gridCoordinate = self.playerBase;
        
        Terrain *eBase = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        eBase.gridCoordinate = self.enemyBase;
        
        [terrain addObject: pBase];
        [terrain addObject: eBase];
        
        //now let's add the other bases
        //the small map has 4 bases at the corners of the road
        //the road corners are up 1 from the beginning of the road
        //the road starts from up 1 of the bases and ends down 1 from the bases
        
        for (int i = 0; i < 4; i ++)
        {
            Terrain *base = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
            CGPoint baseLoc = CGPointMake(gridWidth/3-1, self.playerBase.y + 2);
            if (i == 1 || i == 3) baseLoc = [self.gridManager addX:gridWidth/3+1 andAddY:0 toPosition:baseLoc];
            if (i == 2 || i == 3) baseLoc = [self.gridManager addX:0 andAddY: -4 toPosition:baseLoc];
            base.gridCoordinate = baseLoc;
            [terrain addObject: base];
        }
        
        int mountainStartX = gridWidth/3 + 1;
        int mountainEndX = gridWidth/3 * 2 - 1;
        
        int mountainStartY = gridHeight/2-1;
        int mountainEndY = gridHeight/2+2;
        
        //in the center of the map there are mountains
        for (int x = mountainStartX; x < mountainEndX; x ++)
        {
            for (int y = mountainStartY; y < mountainEndY; y ++)
            {
                Terrain *mountain = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                mountain.gridCoordinate = CGPointMake(x,y);
                [terrain addObject: mountain];
            }
        }
        
        //the top third of the map is made of forest
        //the bottom third of the map is made of forest
        for (int count = 0; count < 2; count ++)
        {
            int startFromY = gridHeight-1;
            if (count == 1) startFromY = 2;
            for (int x = 0; x < gridWidth; x++)
            {
                for (int y = 0; y < 3; y ++)
                {
                    Terrain * forest = [[Terrain alloc] initWithTerrainType: kTerrainTypeForest];
                    forest.gridCoordinate = CGPointMake(x, startFromY - y);
                    [terrain addObject: forest];
                }
            }
        }
        
        //create horizontal road from player base to mountain start
        for (int x = self.playerBase.x; x < mountainStartX; x ++)
        {
            for (int y = self.playerBase.y - 1; y <= self.playerBase.y + 1; y ++)
            {
                CGPoint gridLoc = CGPointMake(x,y);
                //don't add raod on playerBase
                if (![self.gridManager isPoint:self.playerBase equalTo:gridLoc])
                {
                    Terrain * road = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadHorizontal];
                    road.gridCoordinate = CGPointMake(x,y);
                    [terrain addObject: road];
                }
                if (x == mountainStartX - 1)//if at the end of the road, create verticle road tiles isntead
                {
                    Terrain * road = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadVertical];
                    road.gridCoordinate = CGPointMake(x,y);
                    [terrain addObject: road];
                }
            }
        }
        
        //create horizontal road from enemy base to mountain end
        for (int x = self.enemyBase.x; x >= mountainEndX; x --)
        {
           
            for (int y = self.enemyBase.y - 1; y <= self.enemyBase.y + 1; y ++)
            {
                CGPoint gridLoc = CGPointMake(x,y);
                //don't add raod on enemyBase
                if (![self.gridManager isPoint:self.enemyBase equalTo:gridLoc])
                {
                    Terrain * road = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadHorizontal];
                    road.gridCoordinate = CGPointMake(x,y);
                    [terrain addObject: road];
                }
                if (x == mountainEndX)//if at the end of the road, create verticle road tiles isntead
                {
                    Terrain * road = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadVertical];
                    road.gridCoordinate = CGPointMake(x,y);
                    [terrain addObject: road];
                }
            }
        }
        
        //let's create road above and below the mountains
        for (int x = mountainStartX - 1; x <= mountainEndX; x ++)
        {
            for (int count = 0; count < 2; count ++)
            {
                CGPoint loc;
                if (count == 0) { loc = CGPointMake(x, mountainEndY); }
                else { loc = CGPointMake(x, mountainStartY - 1); }
                
                Terrain * road;
                if (x == mountainStartX - 1 && count == 0)
                {
                    road = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadBendUpRight];
                }
                else if (x == mountainEndX && count == 0)
                {
                    road = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadBendUpLeft];
                }
                else if (x == mountainStartX - 1 && count == 1)
                {
                    road = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadBendDownRight];
                }
                else if (x == mountainEndX && count == 1)
                {
                    road = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadBendDownLeft];
                }
                else
                {
                    road = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadHorizontal];
                }
                road.gridCoordinate = loc;
                [terrain addObject: road];
            }
        }
        
        
        [self setTerrain: terrain];
        
        [self addPlayerArmy: army];
        
        NSArray * enemyTypes = [GameManager createEnemyArmyWithPlayerStrength:self.averageStrength playerArmySize: (int)army.count betweenMinNumer:minEnemyCount andMaxNumber:maxEnemyCount onGameDifficulty:self.difficulty];
        
        [self addEnemyArmy: enemyTypes];

        
    }
    return self;
}

-(void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
    if (self.currentAction == kCurrentActionGameLost || self.currentAction == kCurrentActionGameWon)
    {
        
        // Configure the view.
        int gold = 0;
        //let's calculate gold base on the map size and diffculty
        if (self.currentAction == kCurrentActionGameWon)
        {
            gold = goldGainBase;
        }
        
        [self endGame: gold withPossibleBonus: goldGainPerfect];
    }
    
    
}

@end

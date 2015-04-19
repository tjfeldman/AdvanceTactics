//
//  LevelMedium.m
//  AdvanceTactics
//
//  Created by Student on 5/20/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "LevelMedium.h"

@implementation LevelMedium

const int goldGainBase = 500;//you get this much gold for completing this map
const int goldGainPerfect = 150;//you get this much extra for completing this map with no unit deaths


const int minEnemyCount = 4;
const int maxEnemyCount = 10;

-(id) initWithSize:(CGSize)size andArmy: (NSArray *) army onDifficulty: (kGameDifficulty) difficulty
{
    self = [super initWithSize: size];
    if (self)
    {
        self.difficulty = difficulty;
        
        
        //set up background
        Terrain * background = [[Terrain alloc] initWithTerrainType:kTerrainTypePlain];
        [background setScale: 1];
        background.size = CGSizeMake(self.size.width * 2, self.size.height * 2 - [self getInfoDisplayHeight]);
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
        NSMutableArray *map = [NSMutableArray array];
        
        //first let's add the two bases
        Terrain *pBase = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        pBase.gridCoordinate = self.playerBase;
        
        Terrain *eBase = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        eBase.gridCoordinate = self.enemyBase;
        
        [map addObject: pBase];
        [map addObject: eBase];
        
        //this map has mountains at the edges of the map
        //the mountains extend the first quarter of the map, a middle third, and the final quarter on the x axis
        
        //the first corner of mountains
        //xxxxx
        //xxxx
        //xxx
        //xx
        //x
        
        int yStop = gridHeight/4;
        int xStop = gridWidth/4;
        
        //create all the corners
        for (int y = 0; y < yStop; y ++)
        {
            for (int x = 0; x < xStop - (y - 0); x ++)
            {
                Terrain * mountain = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                mountain.gridCoordinate = CGPointMake (x, y);
                [map addObject: mountain];
                
                Terrain * mountain1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                mountain1.gridCoordinate = CGPointMake(gridWidth-x-1, y);
                [map addObject: mountain1];
                
                Terrain * mountain2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                mountain2.gridCoordinate = CGPointMake (x, gridHeight - y - 1);
                [map addObject: mountain2];
                
                Terrain * mountain3 = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                mountain3.gridCoordinate = CGPointMake(gridWidth-x-1, gridHeight - y - 1);
                [map addObject: mountain3];
            }
        }
        
        //there are bases at the edge of these mountains
        Terrain * fort1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * fort2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * fort3 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * fort4 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        
        fort1.gridCoordinate = CGPointMake(xStop,0);
        fort2.gridCoordinate = CGPointMake(xStop,gridHeight - 1);
        fort3.gridCoordinate = CGPointMake(gridWidth - xStop - 1,0);
        fort4.gridCoordinate = CGPointMake(gridWidth - xStop - 1,gridHeight - 1);
        
        [map addObject: fort1];
        [map addObject: fort2];
        [map addObject: fort3];
        [map addObject: fort4];
        
        //now we create another triangle of mountains
        //between the two forts at the top and bottom of the map
        
        int xMod = 0;
        
        for (int y = 0; y <= yStop; y ++)
        {
            for (int x = xStop + 1 + xMod; x < gridWidth - xStop - xMod - 1; x ++)
            {
                Terrain * mountain1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                mountain1.gridCoordinate = CGPointMake(x, y);
                [map addObject: mountain1];
                
                Terrain * mountain2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                mountain2.gridCoordinate = CGPointMake (x, gridHeight - y - 1);
                [map addObject: mountain2];
            }
            xMod ++;
        }
        
        //let's create vertical road from the fort1 to fort2 and fort3 to fort4
        for (int y = fort1.gridCoordinate.y + 1; y < fort2.gridCoordinate.y; y ++)
        {
            Terrain *road1 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadVertical];
            Terrain *road2 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadVertical];
            
            road1.gridCoordinate = CGPointMake(fort1.gridCoordinate.x, y);
            road2.gridCoordinate = CGPointMake(fort3.gridCoordinate.x, y);
            
            [map addObject: road1];
            [map addObject: road2];
        }
        
        
        //we want to add road from the player and enemy base out a little bit
        Terrain *road1 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadHorizontal];
        Terrain *road2 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadHorizontal];
        Terrain *road3 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadHorizontal];
        Terrain *road4 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadHorizontal];
        
        road1.gridCoordinate = CGPointMake( self.playerBase.x + 2, self.playerBase.y);
        road2.gridCoordinate = CGPointMake(self.enemyBase.x  - 2 , self.enemyBase.y);
        road3.gridCoordinate = CGPointMake( self.playerBase.x + 1, self.playerBase.y);
        road4.gridCoordinate = CGPointMake(self.enemyBase.x  - 1 , self.enemyBase.y);
        
        [map addObject: road1];
        [map addObject: road2];
        [map addObject: road3];
        [map addObject: road4];
        
        //now we need to create 3 roads coming intersecting the first vertical road to the other vertical road
        for (int x = fort1.gridCoordinate.x - 3; x <= fort3.gridCoordinate.x + 3; x ++)
        {
            if (x != fort1.gridCoordinate.x && x != fort3.gridCoordinate.x)
            {
                Terrain *road1 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadHorizontal];
                Terrain *road2 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadHorizontal];
                Terrain *road3 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadHorizontal];
                
                //we ends of the highest and lowest road to curve in towards the middle road
                if (x == fort1.gridCoordinate.x - 3)
                {
                    road2 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadBendUpRight];
                    road3 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadBendDownRight];
                }
                if (x == fort3.gridCoordinate.x + 3)
                {
                    road2 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadBendUpLeft];
                    road3 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadBendDownLeft];
                }
                
                
                road1.gridCoordinate = CGPointMake(x, self.playerBase.y);
                road2.gridCoordinate = CGPointMake(x, self.playerBase.y + gridHeight/4);
                road3.gridCoordinate = CGPointMake(x, self.playerBase.y - gridHeight/4);
                
                [map addObject: road1];
                [map addObject: road2];
                [map addObject: road3];
            }
        }
        
        //now let's connect these roads together
        for (int y = self.playerBase.y - gridHeight/4 + 1;  y < self.playerBase.y + gridHeight/4; y ++)
        {
            
            if (y != self.playerBase.y)
            {
                Terrain *road1 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadVertical];
                Terrain *road2 = [[Terrain alloc] initWithTerrainType:kTerrainTypeRoadVertical];
                
                road1.gridCoordinate = CGPointMake(fort1.gridCoordinate.x - 3, y);
                road2.gridCoordinate = CGPointMake(fort3.gridCoordinate.x + 3, y);
                
                [map addObject: road1];
                [map addObject: road2];
            }
        }
        
        //let's add forest in the middle of these roads
        for (int x = fort1.gridCoordinate.x - 2; x < fort1.gridCoordinate.x; x ++)
        {
             for (int y = self.playerBase.y - gridHeight/4 + 1;  y < self.playerBase.y + gridHeight/4; y ++)
             {
                 if (y != self.playerBase.y)
                 {
                    Terrain * forest1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeForest];
                    Terrain * forest2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeForest];
                    
                     forest1.gridCoordinate = CGPointMake(x,y);
                     forest2.gridCoordinate = CGPointMake(gridWidth - x - 1,y);
                    
                    [map addObject: forest1];
                    [map addObject: forest2];
                 }
             }
        }
        
        //now we want to add some forts inside the two large sections between roads
        Terrain * roadFort1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * roadFort2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * roadFort3 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * roadFort4 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * roadFort5 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * roadFort6 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * roadFort7 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        Terrain * roadFort8 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        
        roadFort1.gridCoordinate = CGPointMake(fort1.gridCoordinate.x + 1, self.playerBase.y + 1);
        roadFort2.gridCoordinate = CGPointMake(fort1.gridCoordinate.x + 1, self.playerBase.y - 1);
        roadFort3.gridCoordinate = CGPointMake(fort3.gridCoordinate.x - 1, self.playerBase.y + 1);
        roadFort4.gridCoordinate = CGPointMake(fort3.gridCoordinate.x - 1, self.playerBase.y - 1);
        roadFort5.gridCoordinate = CGPointMake(fort1.gridCoordinate.x + 1, self.playerBase.y + gridHeight/4 - 1);
        roadFort6.gridCoordinate = CGPointMake(fort1.gridCoordinate.x + 1, self.playerBase.y - gridHeight/4 + 1);
        roadFort7.gridCoordinate = CGPointMake(fort3.gridCoordinate.x - 1, self.playerBase.y + gridHeight/4 - 1);
        roadFort8.gridCoordinate = CGPointMake(fort3.gridCoordinate.x - 1, self.playerBase.y - gridHeight/4 + 1);
        
        [map addObject: roadFort1];
        [map addObject: roadFort2];
        [map addObject: roadFort3];
        [map addObject: roadFort4];
        [map addObject: roadFort5];
        [map addObject: roadFort6];
        [map addObject: roadFort7];
        [map addObject: roadFort8];
        
        //let's add mountains in the center of this empty space
        for (int x = roadFort1.gridCoordinate.x + 2; x <= roadFort3.gridCoordinate.x - 2; x ++)
        {
            for (int y = roadFort1.gridCoordinate.y + 2; y <= roadFort5.gridCoordinate.y - 2; y ++)
            {
                Terrain * mountain1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                mountain1.gridCoordinate = CGPointMake(x, y);
                [map addObject: mountain1];
                
                Terrain * mountain2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                mountain2.gridCoordinate = CGPointMake (x, gridHeight - y - 1);
                [map addObject: mountain2];
            }
        }
        
        //finally let's add forest around those mountains
        for (int x = roadFort1.gridCoordinate.x; x <= roadFort3.gridCoordinate.x; x ++)
        {
            for (int y = roadFort1.gridCoordinate.y; y <= roadFort5.gridCoordinate.y; y ++)
            {
                CGPoint point1 = CGPointMake(x,y);
                CGPoint point2 = CGPointMake(x, gridHeight - y - 1);
                
                //make sure we are not putting forest over a fort
                if (![self.gridManager isPoint:point1 equalTo:roadFort1.gridCoordinate] && ![self.gridManager isPoint: point1 equalTo:roadFort3.gridCoordinate] && ![self.gridManager isPoint:point1 equalTo:roadFort5.gridCoordinate] && ![self.gridManager isPoint: point1 equalTo:roadFort7.gridCoordinate])
                {
                    //make sure we are not inside the mountain range
                    if ((x < fort1.gridCoordinate.x + 3 || x > fort3.gridCoordinate.x - 3) || (y < roadFort1.gridCoordinate.y + 2 || y > roadFort5.gridCoordinate.y - 2))
                    {
                        Terrain * forest1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeForest];
                        Terrain * forest2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeForest];
                        
                        forest1.gridCoordinate = point1;
                        forest2.gridCoordinate = point2;
                        
                        [map addObject: forest1];
                        [map addObject: forest2];
                    }
                }
                
            }
        }
        
        
        [self setTerrain: map];
        
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

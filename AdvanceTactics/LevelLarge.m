//
//  LevelLarge.m
//  AdvanceTactics
//
//  Created by Student on 5/21/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "LevelLarge.h"

@implementation LevelLarge

const int goldGainBase = 750;//you get this much gold for completing this map
const int goldGainPerfect = 300;//you get this much extra for completing this map with no unit deaths


const int minEnemyCount = 6;
const int maxEnemyCount = 12;

-(id) initWithSize:(CGSize)size andArmy: (NSArray *) army onDifficulty: (kGameDifficulty) difficulty
{
    self = [super initWithSize: size];
    if (self)
    {
        self.difficulty = difficulty;
        
        
        //set up background
        Terrain * background = [[Terrain alloc] initWithTerrainType:kTerrainTypePlain];
        [background setScale: 1];
        background.size = CGSizeMake(self.size.width * 3, self.size.height * 2 - [self getInfoDisplayHeight]);
        background.position = CGPointMake(0, (background.size.height - self.size.height) / -2.0f + [self getInfoDisplayHeight]);
        background.zPosition = kDrawingOrderBackground;
        background.anchorPoint = CGPointMake(0,0);
        [self setBackground: background];
        
        //set up grid
        int gridWidth = [self.gridManager getGridWidth];
        int gridHeight = [self.gridManager getGridHeight];
        
        //set up player and enemy base locations
        self.playerBase = CGPointMake(1, gridHeight/2);
        self.enemyBase = CGPointMake(gridWidth - 2, gridHeight/2);
        
        //add terrain
        NSMutableArray *map = [NSMutableArray array];
        
        //first let's add the two bases
        Terrain *pBase = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        pBase.gridCoordinate = self.playerBase;
        
        Terrain *eBase = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        eBase.gridCoordinate = self.enemyBase;
        
        [map addObject: pBase];
        [map addObject: eBase];
        
        int yStart = 0;
        int yEnd = gridHeight - 1;
        
        int xStart = 0;
        int xEnd = gridWidth - 1;
        
        //mountain creation around edge
        for (int y = yStart; y <= yEnd; y ++)
        {
            for (int x = xStart; x <= xEnd; x++)
            {
                //create mountains
                if ((x == xStart || x == xEnd) && y != self.playerBase.y)
                {
                    Terrain *mountain = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                    mountain.gridCoordinate = CGPointMake(x,y);
                    [map addObject: mountain];
                }
                else if (y == yStart || y == yEnd)
                {
                    Terrain *mountain = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                    mountain.gridCoordinate = CGPointMake(x,y);
                    [map addObject: mountain];
                }
                
            }//end for (int x)
        }//end for (int y)
        
        yStart ++;
        yEnd --;
        xStart ++;
        xEnd --;
        
        int numOfRoadCircles = 4;
        
        for (int count = 1; count <= numOfRoadCircles ; count ++)
        {
            //now we need to create a road that circles the map depending on a pre-existing start and end point
            for (int y = yStart; y <= yEnd; y ++)
            {
                for (int x = xStart; x <= xEnd; x++)
                {
                    //create a corner piece of this road, top left
                    if (x == xStart && y == yStart)
                    {
                        Terrain *road1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadBendDownRight];
                        
                        road1.gridCoordinate = CGPointMake(x, y);
                        
                        [map addObject: road1];
                    }
                    //create a corner piece of this road, bottom left
                    else if (x == xStart && y == yEnd)
                    {
                        Terrain *road1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadBendUpRight];
                        
                        road1.gridCoordinate = CGPointMake(x, y);
                        
                        [map addObject: road1];
                    }
                    //create a corner piece of this road, top right
                    else if (x == xEnd && y == yStart)
                    {
                        Terrain *road1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadBendDownLeft];
                        
                        road1.gridCoordinate = CGPointMake(x, y);
                        
                        [map addObject: road1];
                    }
                    //create a corner piece of this road, bottom right
                    else if (x == xEnd && y == yEnd)
                    {
                        Terrain *road1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadBendUpLeft];
                        
                        road1.gridCoordinate = CGPointMake(x, y);
                        
                        [map addObject: road1];
                    }
                    //we are creating horizontal road
                    else if (y == yStart || y == yEnd)
                    {
                        Terrain *road1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadHorizontal];
                        
                        road1.gridCoordinate = CGPointMake(x, y);
                        
                        [map addObject: road1];
                    }
                    //we are creating verticle road
                    else if ((x == xStart || x == xEnd) && (y != self.playerBase.y || count == numOfRoadCircles))
                    {
                        Terrain *road1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadVertical];
                        
                        road1.gridCoordinate = CGPointMake(x, y);
                        
                        [map addObject: road1];
                    }
                }//end for (int x)
            }//end for (int y)
                
            
            if (count == 1 || count == 3)//if we are on the first and third iteration
            {
                int nextRoadStartX = xStart + gridWidth/numOfRoadCircles/2;
                int nextRoadStartY = yStart + gridHeight/numOfRoadCircles/2;
                
                int nextRoadEndX = xEnd - gridWidth/numOfRoadCircles/2;
                int nextRoadEndY = yEnd - gridHeight/numOfRoadCircles/2;
                
                xStart ++;
                xEnd --;
                
                yStart ++;
                yEnd --;
                
                if (count == 3)
                {
                    nextRoadStartY += 1;
                    nextRoadEndY -= 1;
                }
                
                //we want to create some forest between the last road and this one
                for (int y = yStart; y <= yEnd; y ++)
                {
                    for (int x = xStart; x <= xEnd; x++)
                    {
                        //create mountains
                        if ((y != self.playerBase.y) && (x < nextRoadStartX || x > nextRoadEndX))
                        {
                            Terrain *forest = [[Terrain alloc] initWithTerrainType: kTerrainTypeForest];
                            forest.gridCoordinate = CGPointMake(x,y);
                            [map addObject: forest];
                        }
                        else if  (y < nextRoadStartY || y > nextRoadEndY)
                        {
                            Terrain *forest = [[Terrain alloc] initWithTerrainType: kTerrainTypeForest];
                            forest.gridCoordinate = CGPointMake(x,y);
                            [map addObject: forest];
                        }
                        
                    }//end for (int x)
                }//end for (int y)
                
                //reset the values for the loop
                xStart --;
                xEnd ++;
                
                yStart --;
                yEnd ++;
                
            }//end if (count == 1 || count == 3)
            if (count == 2)//on the second iteration, we want to add forts halfway between each side(8 total)
            {
                int nextRoadStartX = xStart + gridWidth/numOfRoadCircles/2 + 1;
                int nextRoadStartY = yStart + gridHeight/numOfRoadCircles/2 + 1;
                
                int nextRoadEndX = xEnd - gridWidth/numOfRoadCircles/2 - 1;
                int nextRoadEndY = yEnd - gridHeight/numOfRoadCircles/2 - 1;
                
                Terrain * fort1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
                Terrain * fort2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
                Terrain * fort3 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
                Terrain * fort4 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
                Terrain * fort5 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
                Terrain * fort6 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
                Terrain * fort7 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
                Terrain * fort8 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
                
                fort1.gridCoordinate = CGPointMake((nextRoadStartX + nextRoadEndX)/3+2, (yStart+nextRoadStartY)/2);
                fort2.gridCoordinate = CGPointMake((nextRoadStartX + nextRoadEndX)/3*2, (yStart+nextRoadStartY)/2);
                fort3.gridCoordinate = CGPointMake((nextRoadStartX + nextRoadEndX)/3+2, (nextRoadEndY+yEnd)/2);
                fort4.gridCoordinate = CGPointMake((nextRoadStartX + nextRoadEndX)/3*2, (nextRoadEndY+yEnd)/2);
                
                fort5.gridCoordinate = CGPointMake((xStart + nextRoadStartX)/2, (nextRoadStartY + self.playerBase.y)/2-1);
                fort6.gridCoordinate = CGPointMake((xEnd + nextRoadEndX)/2+1, (nextRoadStartY + self.playerBase.y)/2-1);
                fort7.gridCoordinate = CGPointMake((xStart + nextRoadStartX)/2, (nextRoadEndY + self.playerBase.y)/2+1);
                fort8.gridCoordinate = CGPointMake((xEnd + nextRoadEndX)/2+1, (nextRoadEndY + self.playerBase.y)/2+1);
                
                [map addObject: fort1];
                [map addObject: fort2];
                [map addObject: fort3];
                [map addObject: fort4];
                [map addObject: fort5];
                [map addObject: fort6];
                [map addObject: fort7];
                [map addObject: fort8];
                
            }//end if (count == 2)
            
            if (count != numOfRoadCircles)
            {
                xStart += gridWidth/numOfRoadCircles/2;
                xEnd -= gridWidth/numOfRoadCircles/2;
            
                yStart += gridHeight/numOfRoadCircles/2;
                yEnd -= gridHeight/numOfRoadCircles/2;
            }
            if (count == numOfRoadCircles -1)
            {
                yStart += 1;
                yEnd -= 1;
            }
        }//end for (int count)
        
        
        //road creation from edge of map to center
        for (int x = 0; x < xStart; x ++)
        {
            if (x != self.playerBase.x)
            {
                Terrain *road1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadHorizontal];
                road1.gridCoordinate = CGPointMake(x, self.playerBase.y);
                [map addObject: road1];
                
                Terrain *road2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeRoadHorizontal];
                road2.gridCoordinate = CGPointMake(gridWidth - x - 1, self.playerBase.y);
                [map addObject: road2];
            }
        }
        
        //let's create 2 fort in the center of the game
        Terrain *fort1 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        fort1.gridCoordinate = CGPointMake(gridWidth/2-1, gridHeight/2);
        [map addObject: fort1];
        
        Terrain *fort2 = [[Terrain alloc] initWithTerrainType: kTerrainTypeFort];
        fort2.gridCoordinate = CGPointMake(gridWidth/2, gridHeight/2);
        [map addObject: fort2];
        
        xStart ++;
        xEnd --;
        
        yStart ++;
        yEnd --;
        
        //lastly we want mountains around this fort
        for (int y = yStart; y <= yEnd; y++)
        {
            for (int x = xStart; x <= xEnd; x ++)
            {
                CGPoint thisLoc = CGPointMake(x, y);
                //as long as we don't put a mountain on a fort
                if (![self.gridManager isPoint:thisLoc equalTo:fort1.gridCoordinate]
                    && ![self.gridManager isPoint:thisLoc equalTo:fort2.gridCoordinate])
                {
                    Terrain * mountain = [[Terrain alloc] initWithTerrainType: kTerrainTypeMountain];
                    mountain.gridCoordinate = thisLoc;
                    [map addObject: mountain];
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

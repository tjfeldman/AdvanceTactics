//
//  GridManager.m
//  AdvanceTactics
//
//  Created by Student on 5/9/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "GridManager.h"

@implementation GridManager
{
    NSArray *_tileLocationsX;
    NSArray *_tileLocationsY;
}

-(id) initWithGridX: (NSArray *) arrayX andWithGridY: (NSArray *) arrayY
{
    self = [super init];
    if (self)
    {
        _tileLocationsX = arrayX;
        _tileLocationsY = arrayY;
    }
    return self;
}

//does position math
-(CGPoint) addX: (int) x andAddY: (int) y toPosition: (CGPoint) point
{
    return CGPointMake(point.x + x, point.y + y);
}

//gets the directional point between two units
-(CGPoint) getDirectionBetween: (CGPoint) point1 and: (CGPoint) point2
{
    int x = point1.x - point2.x;
    int y = point1.y - point2.y;
    
    if (x > 1) x = 1;
    if (y > 1) y = 1;
    if (x < -1) x = -1;
    if (y < -1) y = -1;
    
    return CGPointMake(x,y);
}



//returns the grid coordinates based on column and row in grid
-(CGPoint) getGridPositionAtCoordinatePosition: (CGPoint) point
{
    int x;
    int y;
    
    for (x = 0; x < _tileLocationsX.count; x ++)
    {
        int value = [_tileLocationsX[x] intValue];
        if (value  == point.x) break;
        else if (x == _tileLocationsX.count - 1) { x = -1; break; }
    }
    
    for (y = 0; y < _tileLocationsY.count; y ++)
    {
        int value = [_tileLocationsY[y] intValue];
        if (value == point.y) break;
        else if (y == _tileLocationsX.count - 1) { y = -1; break; }
    }
    
    
    return CGPointMake(x,y);
}

//returns the real coordinates of a grid at column/row
-(CGPoint) getCoordinatePositionAtGridPosition: (CGPoint) point
{
    
    if ([self checkGridBoundsForGridPosition:point])
    {
        int x = point.x;
        int y = point.y;
        return CGPointMake([_tileLocationsX[x] intValue], [_tileLocationsY[y] intValue]);
    }
    return CGPointMake(-1, -1);
}

//checks to make sure a grid position is not out of bounds
-(BOOL) checkGridBoundsForGridPosition: (CGPoint) point
{
    BOOL checkOne = point.x >= 0 && point.x < _tileLocationsX.count - 1;
    BOOL checkTwo = point.y >= 0 && point.y < _tileLocationsY.count - 1;
    return  checkOne && checkTwo;
}

//compares two CGPoints and returns true if they are equal
-(BOOL) isPoint: (CGPoint) p1 equalTo: (CGPoint) p2
{
    if (p1.x == p2.x)
    {
        if (p1.y == p2.y)
        {
            return YES;
        }
    }
    return NO;
}

-(int) getGridWidth
{
    return _tileLocationsX.count - 1;
}
-(int) getGridHeight
{
    return _tileLocationsY.count - 1;
}

@end

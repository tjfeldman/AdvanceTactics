//
//  GridManager.h
//  AdvanceTactics
//
//  Created by Student on 5/9/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GridManager : NSObject

-(id) initWithGridX: (NSArray *) arrayX andWithGridY: (NSArray *) arrayY;

-(CGPoint) getGridPositionAtCoordinatePosition: (CGPoint) point;
-(CGPoint) getCoordinatePositionAtGridPosition: (CGPoint) point;

-(CGPoint) addX: (int) x andAddY: (int) y toPosition: (CGPoint) point;
-(CGPoint) getDirectionBetween: (CGPoint) point1 and: (CGPoint) point2;

-(BOOL) checkGridBoundsForGridPosition: (CGPoint) point;

-(BOOL) isPoint: (CGPoint) p1 equalTo: (CGPoint) p2;

-(int) getGridWidth;
-(int) getGridHeight;


@end

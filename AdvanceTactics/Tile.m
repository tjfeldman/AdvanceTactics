//
//  Tile.m
//  AdvanceTactics
//
//  Created by Student on 5/5/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "Tile.h"

@implementation Tile

-(id) initWithGridLocation: (CGPoint) loc
{
    self = [super init];
    if (self)
    {
        self.gridLocation = loc;
        self.isAttackTile = NO;
        self.color = [UIColor blueColor];
        self.alpha = .65;
        self.moveLeft = -1;
    }
    return self;
}

-(void)setIsAttackTile:(BOOL)isAttackTile
{
    if (isAttackTile != _isAttackTile)
    {
        if (isAttackTile) { self.color = [UIColor orangeColor]; }
        else { self.color = [UIColor blueColor]; }
        _isAttackTile = isAttackTile;
    }
}


@end

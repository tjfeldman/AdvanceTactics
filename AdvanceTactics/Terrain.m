//
//  Terrain.m
//  AdvanceTactics
//
//  Created by Student on 5/16/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "Terrain.h"

@implementation Terrain

-(id) initWithTerrainType: (kTerrainType) type
{
    NSString *name = [GameManager getImageNameForTerrainType:type andForDisplay:NO];
    
    self = [super initWithImageNamed:name];
    if (self)
    {
        //test variables
        
        self.type = type;
        NSDictionary *stats = [GameManager getStatsForTerrain:type];
        
        self.moveCost = [stats[@"MoveCost"] intValue];
        self.defenseRating = [stats[@"DefenseRating"] intValue];
        self.healPerTurn = [stats[@"HealPerTurn"] intValue];
        
        self.name = @"Terrain";

        [self setScale:2.5];
    }
    return self;

}


@end

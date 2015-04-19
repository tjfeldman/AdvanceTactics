//
//  Bank.m
//  AdvanceTactics
//
//  Created by Student on 5/22/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "Bank.h"
#import "Unit.h"

static NSUInteger kGold = 0;

@implementation Bank

+(void) addGold: (NSUInteger) gold
{
    kGold += gold;
}

+(void) spendGold: (NSUInteger) gold
{
    kGold -= gold;
}

+(void) setGold: (NSUInteger) gold
{
    kGold = gold;
}

+(NSUInteger) getGold
{
    return kGold;
}
//saves the game
+(void) saveGame: (NSArray *) army
{
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    [saveData setInteger: [Bank getGold] forKey:@"Gold"];
    NSMutableArray *tempArmy = [NSMutableArray array];
    {
        for(Unit* unit in army)
        {
            [tempArmy addObject: [NSKeyedArchiver archivedDataWithRootObject: unit]];
        }
    }
    [saveData setObject: tempArmy forKey:@"Army"];
    [saveData synchronize];
    
}

//loads game returning unit
+(NSArray *) loadGame
{
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    
    NSUInteger goldData = [saveData integerForKey: @"Gold"];
    NSArray *tempArmy = [saveData arrayForKey: @"Army"];
    
    NSMutableArray *army = [NSMutableArray array];
    
    if (goldData > 0) { kGold = goldData; }
    if (tempArmy.count > 0)
    {
        army = [NSMutableArray array];
        for (int i = 0; i <tempArmy.count; i ++)
        {
            Unit * unit = [NSKeyedUnarchiver unarchiveObjectWithData: tempArmy[i]];
            [army addObject: unit];
        }
    }
    
    return army;
}

@end

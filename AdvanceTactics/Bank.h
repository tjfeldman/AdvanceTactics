//
//  Bank.h
//  AdvanceTactics
//
//  Created by Student on 5/22/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bank : NSObject

+(void) addGold: (NSUInteger) gold;
+(void) spendGold: (NSUInteger) gold;
+(void) setGold: (NSUInteger) gold;
+(NSUInteger) getGold;

+(void) saveGame: (NSArray *) army;
+(NSArray *) loadGame;

@end

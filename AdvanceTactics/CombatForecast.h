//
//  combatForecast.h
//  AdvanceTactics
//
//  Created by Student on 5/11/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Button.h"

@interface CombatForecast : SKSpriteNode

-(id) initWithSize:(CGSize)size withFontName: (NSString *) fontName;

-(void) displayPredictionWithDamageToTarget: (float) targetDamage fromTargetHealth: (float) targetHP andDamageToUnit: (float) unitDamage fromUnitHealth: (float) unitHP;

-(Button *) getConfirmButton;
-(Button *) getCancelButton;

@end

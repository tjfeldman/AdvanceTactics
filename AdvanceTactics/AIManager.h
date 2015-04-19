//
//  AIManager.h
//  AdvanceTactics
//
//  Created by Student on 5/7/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameScene.h"

@interface AIManager : NSObject

-(id) initWithGameScene: (GameScene *) scene;
-(void) aiActionForUnit: (Unit *) unit;

@end

//
//  UnitStore.m
//  AdvanceTactics
//
//  Created by Student on 5/19/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "UnitStore.h"
#import "Button.h"
#import "GameManager.h"

@implementation UnitStore
{
    Button *_buyMobile;
    Button *_buyTank;
    Button *_buyRange;
    
    SKSpriteNode *_mobilePicture;
    SKSpriteNode *_tankPicture;
    SKSpriteNode *_rangePicture;
}

-(id) initWithSize: (CGSize) size
{
    self = [super initWithColor:[UIColor grayColor] size:size];
    if (self)
    {
        _mobilePicture = [[SKSpriteNode alloc] initWithImageNamed:
                                    [GameManager getImageNameForUnitType:kUnitTypeMobile andInState:kUnitDisplay]];
        _tankPicture = [[SKSpriteNode alloc] initWithImageNamed:
                                     [GameManager getImageNameForUnitType:kUnitTypeTank andInState:kUnitDisplay]];
        _rangePicture = [[SKSpriteNode alloc] initWithImageNamed:
                                      [GameManager getImageNameForUnitType:kUnitTypeRange andInState:kUnitDisplay]];
        
        _mobilePicture.position = CGPointMake(-size.width/3, self.size.height/4);
        _tankPicture.position = CGPointMake(0,self.size.height/4);
        _rangePicture.position = CGPointMake(size.width/3, self.size.height/4);
        
        [_mobilePicture setScale:2];
        [_tankPicture setScale: 2];
        [_rangePicture setScale:2];
        
        [self addChild: _mobilePicture];
        [self addChild: _tankPicture];
        [self addChild: _rangePicture];
        
       
        CGSize buttonSize = CGSizeMake(self.size.width/4, self.size.height/5);
        
        _buyMobile = [[Button alloc] initWithButtonText:
                      [NSString stringWithFormat:@"Buy (%d)", [GameManager getBaseUnitCostFor:kUnitTypeMobile]] andSize: buttonSize];
        
        _buyTank = [[Button alloc] initWithButtonText:
                    [NSString stringWithFormat:@"Buy (%d)", [GameManager getBaseUnitCostFor:kUnitTypeTank]]
                                       andSize: buttonSize];
        
        _buyRange = [[Button alloc] initWithButtonText:
                     [NSString stringWithFormat:@"Buy (%d)", [GameManager getBaseUnitCostFor:kUnitTypeRange]] andSize: buttonSize];
        
        _buyMobile.position = CGPointMake(_mobilePicture.position.x, -self.size.height/4);
        _buyTank.position = CGPointMake(_tankPicture.position.x, -self.size.height/4);
        _buyRange.position = CGPointMake(_rangePicture.position.x, -self.size.height/4);
        
        [self addChild: _buyMobile];
        [self addChild: _buyRange];
        [self addChild: _buyTank];
        
    }
    return self;
}

//if there is no room or not enough money, these buttons won't be clickable
-(void) checkIfAbleToBuyWithGold: (int) gold andRoomLeft: (int) roomLeft
{
    if (gold < [GameManager getBaseUnitCostFor:kUnitTypeMobile] || roomLeft == 0)
    {
        [_buyMobile disableButton];
    }
    else
    {
        [_buyMobile enableButton];
    }
    ;
    
    if (gold < [GameManager getBaseUnitCostFor:kUnitTypeTank] ||  roomLeft == 0)
    {
        [_buyTank disableButton];
    }
    else
    {
        [_buyTank enableButton];
    }
    
    if (gold < [GameManager getBaseUnitCostFor:kUnitTypeRange] ||  roomLeft == 0)
    {
        [_buyRange disableButton];
    }
    else
    {
        [_buyRange enableButton];
    }
}

//if we touched nothing in the store, we should
-(BOOL) shouldWeCloseStore: (SKSpriteNode *) touchedNode
{
    if (![self isEqual: touchedNode])//check if didn't we touched the box
    {
        if (![self buyMobileClicked:touchedNode] && ![self buyRangeClicked:touchedNode] && ![self buyTankClicked:touchedNode])//check if we didn't touched any of the buttons
        {
            if (![_mobilePicture isEqual: touchedNode] && ![_tankPicture isEqual: touchedNode] && ![_rangePicture isEqual: touchedNode])//check if we didn't touch any pictures
            {
                //if nothing was touched, then yes we close
                return YES;
            }
        }
    }
    
    return NO;//something was touched so no we don't want to close
}

-(BOOL) buyMobileClicked: (SKSpriteNode *) touchedNode
{
    return [_buyMobile checkButtonTouchAt:touchedNode] == kButtonStateHit;
}

-(BOOL) buyTankClicked: (SKSpriteNode *) touchedNode
{
    return [_buyTank checkButtonTouchAt:touchedNode] == kButtonStateHit;
}

-(BOOL) buyRangeClicked: (SKSpriteNode *) touchedNode
{
    return [_buyRange checkButtonTouchAt:touchedNode] == kButtonStateHit;
}

@end

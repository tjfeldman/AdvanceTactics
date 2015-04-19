//
//  ArmyManager.m
//  AdvanceTactics
//
//  Created by Student on 5/19/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "ArmyManager.h"
#import "GameManager.h"
#import "UnitDisplay.h"
#import "Button.h"
#import "LevelSmall.h"
#import "LevelSelect.h"
#import "UnitStore.h"
#import "Bank.h"
#import <AVFoundation/AVFoundation.h>

const int kMaxArmySize = 8;

@implementation ArmyManager
{
    NSMutableArray *_army;
    NSMutableArray *_displays;
    
    
    CGSize _bar;
    SKSpriteNode *_background;
    
    Button * _buyUnit;
    Button * _done;
    
    UnitStore *_store;
    
    SKLabelNode * _currentGold;
    
    AVAudioPlayer *_gameSound;
}

-(id) initWithSize:(CGSize)size andPlayerArmy: (NSArray*) array
{
    self = [super initWithSize:size];
    if (self)
    {
        NSString *fontName = [GameManager getFontName];
        
        _army = [array mutableCopy];
        _displays = [NSMutableArray array];
        
        _background = [[SKSpriteNode alloc] initWithColor: [UIColor blackColor] size: size];
        _background.position = CGPointMake(size.width/2, size.height/2);
        [self addChild: _background];
        
        _bar = CGSizeMake(size.width, size.height / 10);
        
        SKSpriteNode *topBar = [[SKSpriteNode alloc] initWithColor: [UIColor grayColor] size: _bar];
        topBar.position = CGPointMake(size.width/2, size.height - _bar.height/2);
        [self addChild: topBar];
        
        SKSpriteNode *bottomBar = [[SKSpriteNode alloc] initWithColor: [UIColor grayColor] size: _bar];
        bottomBar.position = CGPointMake(size.width/2, _bar.height/2);
        [self addChild: bottomBar];
        
        _currentGold = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _currentGold.text = [NSString stringWithFormat: @"Gold: %d", [Bank getGold]];
        _currentGold.fontSize = _bar.height/2;
        _currentGold.fontColor = [UIColor yellowColor];
        _currentGold.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _currentGold.position = CGPointMake(-topBar.size.width/4, 0);
        [topBar addChild: _currentGold];
        
        SKLabelNode * title = [[SKLabelNode alloc] initWithFontNamed: fontName];
        title.text = @"Armory";
        title.fontColor = [UIColor whiteColor];
        title.fontSize = _bar.height/1.5;
        title.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        title.position = CGPointMake(0, 0);
        [topBar addChild: title];
        
        CGSize buttonSize = CGSizeMake(_bar.width/3, _bar.height/2);
        
        _done = [[Button alloc] initWithButtonText:@"Select Level" andSize:buttonSize];
        _done.fontSize = _bar.height/2;
        _done.position = CGPointMake (_bar.width/6, _bar.height/8);
        [bottomBar addChild: _done];
        
        _buyUnit = [[Button alloc] initWithButtonText:@"Buy Units" andSize:buttonSize];
        _buyUnit.fontSize = _bar.height/2;
        _buyUnit.position = CGPointMake (- _bar.width/6, _bar.height/8);
        [bottomBar addChild: _buyUnit];
        
        _store = [[UnitStore alloc] initWithSize: CGSizeMake (self.size.width/1.25, self.size.height/4)];
        _store.position = CGPointMake(self.size.width/2, self.size.height/2);
        
        
        for (int i = 0; i < _army.count; i ++)
        {
            Unit *unit = _army[i];
            [self addUnit:unit AtPosition:i];
        }
        
        //set up the song that plays
        NSError *error;
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"Advance Wars Dual Strike - Mode Select -- NintendoDS" ofType: @"mp3"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        
        _gameSound = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error: &error];
        _gameSound.numberOfLoops = -1;
        [_gameSound play];
    }
    return self;
}

-(void) addUnit: (Unit *) unit AtPosition: (int) pos
{
    UnitDisplay *display = [[UnitDisplay alloc] initWithUnit: unit andDisplaySize: CGSizeMake (self.size.width / 2.5, self.size.height / 6)];
    
    int sign = 1;
    if (pos % 2 == 0) sign = -1;
    
    int num = 1;
    while (pos > 1)
    {
        num ++;
        pos -= 2;
    }
    
    display.position = CGPointMake( (sign * _background.size.width/3) - (sign * _background.size.width/12), _background.size.height/2 - _bar.height / 2 - (num * _background.size.height / 6) - (num - 1) * _bar.height/4);
    
    [_background addChild: display];
    [_displays addObject: display];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self checkTouches: touches onEnd: NO];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self checkTouches: touches onEnd: NO];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self checkTouches: touches onEnd: YES];
    
    //clear buttons
    [_buyUnit checkButtonTouchAt: nil];
    [_done checkButtonTouchAt: nil];
}

//check the upgrade buttons all the display objects
-(void) checkDisplayButtons: (SKSpriteNode *) touchedNode onEnd: (BOOL) onEnd
{
    for (UnitDisplay *display in _displays)
    {
        if ([display checkIfUpgradeIsTouched: touchedNode] == kButtonStateHit && onEnd)
        {
            [Bank spendGold: [display getUpgradeCost]];
            [display increaseUnitALevel];
            [Bank saveGame: _army];//save game when unit is upgrade
        }
    }
    
}
-(void) checkTouches: (NSSet *)touches onEnd: (BOOL) onEnd
{
    BOOL leaveScreen = false;
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self];
    
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:position];

    [self checkDisplayButtons: touchedNode onEnd:onEnd];
    
    if ([_done checkButtonTouchAt: touchedNode] == kButtonStateHit && onEnd)
    {
        leaveScreen = true;
    }
    
    //store is open let's see if we clicked anything
    if (_store.parent != nil)
    {
        //checking purchase on mobile unit
        if ([_store buyMobileClicked:touchedNode] && onEnd)
        {
            [Bank spendGold: [GameManager getBaseUnitCostFor:kUnitTypeMobile]];
            Unit * unit = [Unit getMobileUnitForPlayer];
            [self addUnit: unit AtPosition: _army.count];
            [_army addObject: unit];
            [Bank saveGame: _army];//save game when new unit is added
        }
        
        //checking purchase on a tank unit
        if ([_store buyTankClicked:touchedNode] && onEnd)
        {
            [Bank spendGold: [GameManager getBaseUnitCostFor:kUnitTypeTank]];
            Unit * unit = [Unit getTankUnitForPlayer];
            [self addUnit: unit AtPosition: _army.count];
            [_army addObject: unit];
            [Bank saveGame: _army];//save game when new unit is added
        }
        
        //checking purchase on a range unit
        if ([_store buyRangeClicked:touchedNode] && onEnd)
        {
            [Bank spendGold: [GameManager getBaseUnitCostFor:kUnitTypeRange]];
            Unit * unit = [Unit getRangeUnitForPlayer];
            [self addUnit: unit AtPosition: _army.count];
            [_army addObject: unit];
            [Bank saveGame: _army];//save game when new unit is added
        }
        
        //let's see if we clicked off the store
        if ([_store shouldWeCloseStore: touchedNode])
        {
            [_store removeFromParent];
            
        }
    }
    else
    {
        if ([_buyUnit checkButtonTouchAt: touchedNode] == kButtonStateHit && onEnd)
        {
            [self addChild: _store];
        }
    }
    
    if (onEnd)
    {
        [_buyUnit checkButtonTouchAt: nil];
        [_done checkButtonTouchAt: nil];
        [self checkDisplayButtons: nil onEnd:NO];
        [_store buyMobileClicked: nil];
        [_store buyRangeClicked: nil];
        [_store buyTankClicked: nil];
        
    }
    
    
    if (leaveScreen) [self toLevelSelect];
}

-(void)update:(NSTimeInterval)currentTime
{
    for (UnitDisplay *display in _displays)
    {
        Unit *unit= _army[[_displays indexOfObject: display]];
        [display checkIfUpgradeCanBeBroughtWith: [Bank getGold]];
        [display updateUpgradeCost: [GameManager getUpgradeCostFor: unit.type atLevel: unit.level]];
    }
    
    if (_store.parent != nil)
    {
        //we only want to update the store if it's visible
        [_store checkIfAbleToBuyWithGold:[Bank getGold] andRoomLeft:kMaxArmySize - _army.count];
        
        //all other buttons are unclickable while store is open
        [_buyUnit disableButton];
        [_done disableButton];
        _background.alpha = .45;//background is faded
        for (UnitDisplay *display in _displays)
        {
            [display disableButton];
        }
    }
    else
    {
        //buttons are clickable when the store is closed
        [_buyUnit enableButton];
        [_done enableButton];
        _background.alpha = 1;//background isn't faded
        
    }
    
    _currentGold.text = [NSString stringWithFormat: @"Gold: %d", [Bank getGold]];//let's make sure the gold we show is up to date
}

-(void) toLevelSelect
{
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    //stops unknown error for some reason
    //CODE IS NEEDED HERE
    //DO NOT MOVE
    for (Unit * unit in _army)
    {
        unit.texture = nil;
    }
    
    // Create and configure the scene.
    LevelSelect * scene = [[LevelSelect alloc] initWithSize: self.size andArmy: _army andBackgroundSoundPlaying: _gameSound];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [Bank saveGame: _army];
    [skView presentScene:scene];
}




@end

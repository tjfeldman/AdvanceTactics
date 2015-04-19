//
//  TitleScene.m
//  AdvanceTactics
//
//  Created by Student on 5/19/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "TitleScene.h"
#import "GameManager.h"
#import "ArmyManager.h"
#import "Button.h"
#import "Unit.h"
#import "HelpScene.h"
#import "Bank.h"

#import <AVFoundation/AVFoundation.h>

static AVAudioPlayer *_introSound;

@implementation TitleScene
{
    Button *_play;
    Button *_howToPlay;
    Button *_clearData;
    NSMutableArray * _army;

}

-(id) initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self)
    {
        
        //set up the song that plays
        if (_introSound == nil)
        {
            NSError *error;
            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"Advance Wars - Dual Strike - Intro - Nintendo DS" ofType: @"mp3"];
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
            
            _introSound = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error: &error];
            _introSound.numberOfLoops = -1;
            [_introSound play];
        }
        
        
        
        SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:size];
        background.position = CGPointMake(size.width/2, size.height/2);
        [self addChild: background];
        
        SKLabelNode * title = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
        title.text = @"Advance Tactics";
        title.fontSize = 144;
        title.fontColor = [UIColor blackColor];
        title.position = CGPointMake(0, size.height/4);
        [background addChild: title];
        
        SKLabelNode * author = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
        author.text = @"by Tyler Feldman";
        author.fontSize = 36;
        author.fontColor = [UIColor blackColor];
        author.position = CGPointMake(0, title.position.y - 48);
        [background addChild: author];
        
        CGSize buttonSize = CGSizeMake(200, 150);
        
        _play = [[Button alloc] initWithButtonText:@"Play Game" andSize:buttonSize];
        _play.fontSize = 48;
        _play.position = CGPointMake(0, 0);
        [background addChild: _play];
        
        _howToPlay = [[Button alloc] initWithButtonText: @"How to Play" andSize:buttonSize];
        _howToPlay.fontSize = 48;
        _howToPlay.position = CGPointMake(_play.position.x, _play.position.y - buttonSize.height * 1.5);
        [background addChild: _howToPlay];
        
        _clearData = [[Button alloc] initWithButtonText:@"Clear Data" andSize:CGSizeMake(buttonSize.width/2, buttonSize.height/2)];
        _clearData.fontSize = 24;
        _clearData.position = CGPointMake(0, _howToPlay.position.y - buttonSize.height * 1.5);
        [_clearData disableButton];//this button is disabled by default
        [background addChild: _clearData];
        
        //defaults
        [self getDefaults];
        
        NSArray *temp = [Bank loadGame];
        if (temp.count > 0)
        {
            _army = [temp mutableCopy];
            [_clearData enableButton];
        }
        
        
    }
    return self;
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
    [_play checkButtonTouchAt: nil];
    [_howToPlay checkButtonTouchAt: nil];
    [_clearData checkButtonTouchAt: nil];
}

//set values to the default game new game data
-(void) getDefaults
{
    _army = [NSMutableArray array];
    
    [Bank setGold: 0];
    
    [_army addObject: [Unit getMobileUnitForPlayer]];
    [_army addObject: [Unit getRangeUnitForPlayer]];
    [_army addObject: [Unit getTankUnitForPlayer]];
}

-(void) checkTouches: (NSSet *)touches onEnd: (BOOL) onEnd
{
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self];
    
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:position];
    
    if ([_play checkButtonTouchAt: touchedNode] == kButtonStateHit && onEnd)
    {
        //show army manager
        // Configure the view.
        SKView * skView = (SKView *)self.view;
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        ArmyManager * scene = [[ArmyManager alloc] initWithSize:self.size andPlayerArmy: _army];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [_introSound stop];
        [skView presentScene:scene];
    }
    if ([_howToPlay checkButtonTouchAt: touchedNode] && onEnd)
    {
        //show how to play screen
        // Configure the view.
        SKView * skView = (SKView *)self.view;
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        HelpScene *scene = [[HelpScene alloc] initWithSize: self.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [skView presentScene:scene];
    }
    if ([_clearData checkButtonTouchAt: touchedNode] && onEnd)
    {
        [self getDefaults];//reset data to default
        //now we save this data
        [Bank saveGame: _army];
        //lastly we set _clear data to be disable
        [_clearData disableButton];
    }
}

-(void)update:(NSTimeInterval)currentTime
{

}

@end

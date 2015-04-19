//
//  LevelSelect.m
//  AdvanceTactics
//
//  Created by Student on 5/20/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "LevelSelect.h"
#import "Button.h"
#import "LevelSmall.h"
#import "LevelMedium.h"
#import "LevelLarge.h"

static kGameDifficulty difficulty = kGameDifficultyMedium;

@implementation LevelSelect
{
    NSArray *_army;
    
    Button *_small;
    Button *_medium;
    Button *_large;
    
    Button *_easy;
    Button *_normal;
    Button *_hard;
    
    AVAudioPlayer *_gameSound;
    
}

-(id) initWithSize:(CGSize)size andArmy: (NSArray *) army andBackgroundSoundPlaying: (AVAudioPlayer *) currentSound
{
    self = [super initWithSize:size];
    if (self)
    {
        _army = army;
        _gameSound = currentSound;
        
        
        
        SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor: [UIColor blackColor] size: size];
        background.position = CGPointMake(size.width/2, size.height/2);
        [self addChild: background];
        
        CGSize buttonSize = CGSizeMake(size.width/3, size.height /5);
        
        _easy = [[Button alloc] initWithButtonText: @"Easy (0.5x gold)" andSize:buttonSize];
        _easy.position = CGPointMake(-size.width/3, -size.height/3);
        [background addChild: _easy];
        
        _normal = [[Button alloc] initWithButtonText: @"Normal (1x gold)" andSize:buttonSize];
        _normal.position = CGPointMake(0, -size.height/3);
        [background addChild: _normal];
        
        _hard = [[Button alloc] initWithButtonText: @"Hard (1.5x gold)" andSize:buttonSize];
        _hard.position = CGPointMake(size.width/3, -size.height/3);
        [background addChild: _hard];
        
        buttonSize = CGSizeMake(size.width/3, size.height /3);
        
        SKTexture * smallMapTexture = [SKTexture textureWithImageNamed: @"mapSmall"];
        SKTexture * mediumMapTexture = [SKTexture textureWithImageNamed: @"mapMedium"];
        SKTexture * largeMapTexture = [SKTexture textureWithImageNamed: @"mapLarge"];
        
        _small = [[Button alloc] initWithButtonText: @"Small Map" andSize: buttonSize];
        _small.position = CGPointMake(-size.width/3, size.height/4);
        [_small setButtonBackground: smallMapTexture];
        _small.fontSize = 32;
        [background addChild: _small];
        
        SKLabelNode *smallSize = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
        smallSize.text = @"Enemy Size: 2-8 units";
        smallSize.fontColor = [UIColor redColor];
        smallSize.fontSize = 24;
        smallSize.position = CGPointMake(_small.position.x, _small.position.y - _small.size.height/4);
        [background addChild: smallSize];
        
        _medium = [[Button alloc] initWithButtonText: @"Medium Map" andSize: buttonSize];
        _medium .position = CGPointMake(0, size.height/4);
        [_medium setButtonBackground: mediumMapTexture];
        _medium.fontSize = 32;
        [background addChild: _medium ];
        
        SKLabelNode *mediumSize = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
        mediumSize.text = @"Enemy Size: 4-10 units";
        mediumSize.fontColor = [UIColor redColor];
        mediumSize.fontSize = 24;
        mediumSize.position = CGPointMake(_medium.position.x, _medium.position.y - _medium.size.height/4);
        [background addChild: mediumSize];
        
        _large = [[Button alloc] initWithButtonText: @"Large Map" andSize: buttonSize];
        _large .position = CGPointMake(size.width/3, size.height/4);
        [_large setButtonBackground: largeMapTexture];
        _large.fontSize = 32;
        [background addChild: _large ];
        
        SKLabelNode *largeSize = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
        largeSize.text = @"Enemy Size: 6-12 units";
        largeSize.fontColor = [UIColor redColor];
        largeSize.fontSize = 24;
        largeSize.position = CGPointMake(_large.position.x, _large.position.y - _large.size.height/4);
        [background addChild: largeSize];
        
        
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
    [_easy checkButtonTouchAt: nil];
    [_normal checkButtonTouchAt: nil];
    [_hard checkButtonTouchAt: nil];
}

//check touches for the objects in this screen
-(void) checkTouches: (NSSet *)touches onEnd: (BOOL) onEnd
{
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self];
    
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:position];
    
    if ([_easy checkButtonTouchAt: touchedNode] && onEnd)
    {
        difficulty = kGameDifficultyEasy;
    }
    if ([_normal checkButtonTouchAt: touchedNode] && onEnd)
    {
        difficulty = kGameDifficultyMedium;
    }
    if ([_hard checkButtonTouchAt: touchedNode] && onEnd)
    {
        difficulty = kGameDifficultyHard;
    }
    
    if ([_small checkButtonTouchAt: touchedNode] && onEnd)
    {
        LevelSmall * scene = [[LevelSmall alloc] initWithSize: self.size andArmy:_army onDifficulty: difficulty];
        [self createLevel: scene];
    }
    
    if ([_medium checkButtonTouchAt: touchedNode] && onEnd)
    {
        LevelMedium * scene = [[LevelMedium alloc] initWithSize: self.size andArmy:_army onDifficulty: difficulty];
        [self createLevel: scene];
    }
    if ([_large checkButtonTouchAt: touchedNode] && onEnd)
    {
        LevelLarge * scene = [[LevelLarge alloc] initWithSize: self.size andArmy:_army onDifficulty: difficulty];
        [self createLevel: scene];
    }
}

-(void) createLevel: (GameScene *) scene
{
    
    
    
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [_gameSound stop];
    [skView presentScene:scene];
}

-(void)update:(NSTimeInterval)currentTime
{
    
    //change which button is clicked by the difficulty that is currently set
    switch (difficulty)
    {
        case kGameDifficultyEasy:
            [_easy disableButton];
            [_normal enableButton];
            [_hard enableButton];
            break;
        case kGameDifficultyMedium:
            [_easy enableButton];
            [_normal disableButton];
            [_hard enableButton];
            break;
        case kGameDifficultyHard:
            [_easy enableButton];
            [_normal enableButton];
            [_hard disableButton];
            break;
        default:
            break;
    }
}

@end

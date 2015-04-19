//
//  GameResults.m
//  AdvanceTactics
//
//  Created by Student on 5/17/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "GameResults.h"
#import "Button.h"
#import "GameManager.h"
#import "ArmyManager.h"
#import "Unit.h"
#import "Bank.h"


@implementation GameResults
{
    Button *_manageArmy;
    Button *_saveAndQuit;
    
    NSArray *armyToSend;
    
}

-(id) initWithArmy: (NSArray *) army withGoldWon: (int) gold andUnitStatus: (NSString *) unitStatus didWin: (BOOL) win andSize: (CGSize) size
{
    self =[super initWithSize: size];
    if (self)
    {
        [Bank addGold: gold];
        armyToSend = army;
        [Bank saveGame: armyToSend];//save the game after updates
        
        SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:size];
        background.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild: background];
        
        SKLabelNode *victory = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
        SKLabelNode *victory2 = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
        
        NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
        NSRange range = [unitStatus rangeOfCharacterFromSet:cset];
        if (range.location == NSNotFound)
        {
             victory.text = unitStatus;
        }
        else
        {
            NSArray *subStrings = [unitStatus componentsSeparatedByString:@"\n"]; //or rather @" - "
            NSString *firstString = [subStrings objectAtIndex:0];
            NSString *lastString = [subStrings objectAtIndex:1];
            
            victory.text = firstString;
            victory2.text = lastString;
        }
        
        victory.fontSize = 72;
        victory.position = CGPointMake(0, self.size.height/8 + 72);
        victory.fontColor = [UIColor blackColor];
        [background addChild: victory];
        
        victory2.fontSize = 72;
        victory2.position = CGPointMake(0, self.size.height/8);
        victory2.fontColor = [UIColor blackColor];
        [background addChild: victory2];
        
        //NSLog(@"%@", victory.text);
        
        SKLabelNode *goldWon = [[SKLabelNode alloc] initWithFontNamed: [GameManager getFontName]];
        goldWon.text = [NSString stringWithFormat: @"You gained: %d G", gold];
        goldWon.fontSize = 72;
        goldWon.position = CGPointMake(0, 0);
        goldWon.fontColor = [UIColor blackColor];
        [background addChild: goldWon];
        
       // NSLog(@"%@", goldWon.text);
        
        
        
        SKAction *playSound;
        
        //sound
        if (win)
        {
            playSound = [SKAction playSoundFileNamed:@"18-success.mp3" waitForCompletion:YES];
            background.color = [UIColor greenColor];//green for victory
            //let's show some fireworks
            NSString *fireworksPath = [[NSBundle mainBundle] pathForResource:@"Fireworks" ofType:@"sks"];
            
            SKEmitterNode *fireworksEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile: fireworksPath];
            SKEmitterNode *fireworksEmitter2 = [NSKeyedUnarchiver unarchiveObjectWithFile: fireworksPath];
            
            
            fireworksEmitter.position = CGPointMake(-self.size.width/4, self.size.height/3);
            fireworksEmitter2.position = CGPointMake(self.size.width/4, self.size.height/3);
            
            [background addChild:fireworksEmitter];
            [background addChild:fireworksEmitter2];
        }
        else
        {
            playSound = [SKAction playSoundFileNamed:@"20-defeated.mp3" waitForCompletion:YES];
            background.color = [UIColor redColor];//red for loss

        }
        
        [self runAction: playSound];
        
        _manageArmy = [[Button alloc] initWithButtonText:@"Manage Army" andSize:CGSizeMake (self.size.width/2,self.size.height/4)];
        _manageArmy.fontSize = 48;
        _manageArmy.position = CGPointMake(0, -self.size.height/6);
        [background addChild: _manageArmy];
        
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
    [_manageArmy checkButtonTouchAt: nil];
    [_saveAndQuit checkButtonTouchAt: nil];
}

-(void) checkTouches: (NSSet *)touches onEnd: (BOOL) onEnd
{
   
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self];
    
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:position];
    
    [_saveAndQuit checkButtonTouchAt: touchedNode];
    
    if ([_manageArmy checkButtonTouchAt: touchedNode] == kButtonStateHit && onEnd)
    {
        SKView * skView = (SKView *)self.view;
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * scene = [[ArmyManager alloc] initWithSize:self.size andPlayerArmy:armyToSend];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        [self removeAllActions];//stop sounds
        [skView presentScene:scene];
    }
    
}


-(void)update:(NSTimeInterval)currentTime
{
}

@end

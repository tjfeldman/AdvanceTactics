//
//  HelpScene.m
//  AdvanceTactics
//
//  Created by Student on 5/20/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "HelpScene.h"
#import "GameManager.h"
#import "Button.h"
#import "TitleScene.h"

@implementation HelpScene
{
    Button *_goBack;
}

-(instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize: size];
    if (self)
    {
        NSString *fontName = [GameManager getFontName];
        SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size: size];
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        [self addChild: background];
        
        SKSpriteNode * unitPicture = [[SKSpriteNode alloc] initWithImageNamed:[GameManager getImageNameForUnitType:kUnitTypeMobile andInState:kUnitActive]];
        unitPicture.position = CGPointMake(self.size.width/4, self.size.height - self.size.height/12);
        [unitPicture setScale: 2];
        [background addChild: unitPicture];
        
        SKLabelNode *clickUnit = [[SKLabelNode alloc] initWithFontNamed: fontName];
        clickUnit.text = @"<- Tap a unit to select a unit and view its stats";
        clickUnit.fontColor = [UIColor blackColor];
        clickUnit.fontSize = 28;
        clickUnit.position = CGPointMake(unitPicture.position.x + 28, unitPicture.position.y);
        clickUnit.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        clickUnit.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        clickUnit.zPosition = 1;
        [background addChild: clickUnit];
        
        SKLabelNode *whileSelecting = [[SKLabelNode alloc] initWithFontNamed: fontName];
        whileSelecting.text = @"While you are selected on a unit you control:";
        whileSelecting.fontColor = [UIColor blackColor];
        whileSelecting.fontSize = 28;
        whileSelecting.position = CGPointMake(clickUnit.position.x, clickUnit.position.y - 64);
        whileSelecting.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        whileSelecting.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        whileSelecting.zPosition = 1;
        [background addChild: whileSelecting];
        
        CGSize tileSize = CGSizeMake(64,64);
        SKSpriteNode * moveTile = [[SKSpriteNode alloc] initWithColor:[UIColor blueColor] size: tileSize];
        moveTile.position = CGPointMake(whileSelecting.position.x + 128, whileSelecting.position.y - 64);
        moveTile.zPosition = 1;
        [background addChild: moveTile];
        
        SKSpriteNode * attackTile = [[SKSpriteNode alloc] initWithColor:[UIColor orangeColor] size: tileSize];
        attackTile.position = CGPointMake(moveTile.position.x + 128, moveTile.position.y);
        attackTile.zPosition = 1;
        [background addChild: attackTile];
        
        SKLabelNode *clickMove = [[SKLabelNode alloc] initWithFontNamed: fontName];
        clickMove.text = @"Tapping the blue tile will cause the selected unit to move to that location";
        clickMove.fontColor = [UIColor blackColor];
        clickMove.fontSize = 28;
        clickMove.position = CGPointMake(whileSelecting.position.x - 64, moveTile.position.y - 64);
        clickMove.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        clickMove.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        clickMove.zPosition = 1;
        [background addChild: clickMove];
        
        SKLabelNode *clickAttack = [[SKLabelNode alloc] initWithFontNamed: fontName];
        clickAttack.text = @"Tapping the orange tile will cause the selected unit to attack that unit";
        clickAttack.fontColor = [UIColor blackColor];
        clickAttack.fontSize = 28;
        clickAttack.position = CGPointMake(clickMove.position.x, clickMove.position.y - 32);
        clickAttack.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        clickAttack.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        clickAttack.zPosition = 1;
        [background addChild: clickAttack];
        
        SKLabelNode *howToEndTurn = [[SKLabelNode alloc] initWithFontNamed: fontName];
        howToEndTurn.text = @"Your turn will end automatically if all your unit actions are used up,";
        howToEndTurn.fontColor = [UIColor blackColor];
        howToEndTurn.fontSize = 28;
        howToEndTurn.position = CGPointMake(clickAttack.position.x, clickAttack.position.y - 64);
        howToEndTurn.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        howToEndTurn.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        howToEndTurn.zPosition = 1;
        [background addChild: howToEndTurn];
        
        SKLabelNode *howToEndTurn2 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        howToEndTurn2.text = @"or if you press the End Turn button";
        howToEndTurn2.fontColor = [UIColor blackColor];
        howToEndTurn2.fontSize = 28;
        howToEndTurn2.position = CGPointMake(howToEndTurn.position.x, howToEndTurn.position.y - 32);
        howToEndTurn2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        howToEndTurn2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        howToEndTurn2.zPosition = 1;
        [background addChild: howToEndTurn2];
        
        SKSpriteNode *tappingUnitSection = [[SKSpriteNode alloc] initWithColor: [UIColor greenColor] size: CGSizeMake(self.size.width, unitPicture.position.y + 64 - howToEndTurn2.position.y + 64)];
        tappingUnitSection.alpha = .15;
        tappingUnitSection.position = CGPointMake(tappingUnitSection.size.width/2, self.size.height - tappingUnitSection.size.height/2);
        tappingUnitSection.zPosition = 0;
        [background addChild: tappingUnitSection];
        
        Button *endUnit = [[Button alloc] initWithButtonText:@"End Unit" andSize:CGSizeMake(200, 100)];
        endUnit.position = CGPointMake(howToEndTurn2.position.x -  32, howToEndTurn2.position.y - 125);
        endUnit.zPosition = 1;
        [background addChild: endUnit];
        
        SKLabelNode *endUnit2 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        endUnit2.text = @"Pressing this button ends ALL of the selected unit's actions";
        endUnit2.fontColor = [UIColor blackColor];
        endUnit2.fontSize = 28;
        endUnit2.position = CGPointMake(endUnit.position.x + 125, endUnit.position.y);
        endUnit2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        endUnit2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        endUnit2.zPosition = 1;
        [background addChild: endUnit2];
        
        Button *endMove = [[Button alloc] initWithButtonText:@"End Move" andSize:CGSizeMake(200, 100)];
        endMove.position = CGPointMake(endUnit.position.x, endUnit.position.y - 125);
        endMove.zPosition = 1;
        [background addChild: endMove];
        
        SKLabelNode *endMove2 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        endMove2.text = @"Pressing this button ends the unit's move action. It can still attack";
        endMove2.fontColor = [UIColor blackColor];
        endMove2.fontSize = 28;
        endMove2.position = CGPointMake(endMove.position.x + 125, endMove.position.y);
        endMove2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        endMove2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        endMove2.zPosition = 1;
        [background addChild: endMove2];
        
        Button *cancelAction = [[Button alloc] initWithButtonText:@"Cancel Action" andSize:CGSizeMake(200, 100)];
        cancelAction.position = CGPointMake(endMove.position.x, endMove.position.y - 125);
        cancelAction.zPosition = 1;
        [background addChild: cancelAction];
        
        SKLabelNode *cancelAction2 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        cancelAction2.text = @"Pressing this button cancels any moves a unit has not ended";
        cancelAction2.fontColor = [UIColor blackColor];
        cancelAction2.fontSize = 28;
        cancelAction2.position = CGPointMake(cancelAction.position.x + 125, cancelAction.position.y);
        cancelAction2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        cancelAction2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        cancelAction2.zPosition = 1;
        [background addChild: cancelAction2];
        
        SKSpriteNode *buttonSection = [[SKSpriteNode alloc] initWithColor: [UIColor redColor] size: CGSizeMake(self.size.width, endUnit.position.y + 64 - cancelAction2.position.y + 96)];
        buttonSection.alpha = .15;
        buttonSection.position = CGPointMake(tappingUnitSection.size.width/2, self.size.height - tappingUnitSection.size.height - buttonSection.size.height/2);
        buttonSection.zPosition = 0;
        [background addChild: buttonSection];
        
        SKLabelNode *terrainInfo = [[SKLabelNode alloc] initWithFontNamed: fontName];
        terrainInfo.text = @"Terrain can add defensive boost and hinder movement to your units";
        terrainInfo.fontColor = [UIColor blackColor];
        terrainInfo.fontSize = 28;
        terrainInfo.position = CGPointMake(cancelAction.position.x, cancelAction.position.y - 128);
        terrainInfo.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        terrainInfo.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        terrainInfo.zPosition = 1;
        [background addChild: terrainInfo];
        
        SKLabelNode *terrainInfo2 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        terrainInfo2.text = @"NOTE: Only the infantry soldier can move on to mountains and isn't hindered by plains";
        terrainInfo2.fontColor = [UIColor blackColor];
        terrainInfo2.fontSize = 28;
        terrainInfo2.position = CGPointMake(terrainInfo.position.x - 64, terrainInfo.position.y - 32);
        terrainInfo2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        terrainInfo2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        terrainInfo2.zPosition = 1;
        [background addChild: terrainInfo2];
        
        SKLabelNode *goBackInfo = [[SKLabelNode alloc] initWithFontNamed: fontName];
        goBackInfo.text = @"Tap to go back";
        goBackInfo.fontColor = [UIColor blackColor];
        goBackInfo.fontSize = 18;
        goBackInfo.position = CGPointMake(self.size.width/2, terrainInfo2.position.y - 32);
        goBackInfo.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        goBackInfo.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        goBackInfo.zPosition = 1;
        [background addChild: goBackInfo];
        
        SKSpriteNode *terrainSection = [[SKSpriteNode alloc] initWithColor: [UIColor blueColor] size: CGSizeMake(self.size.width, terrainInfo.position.y + 64 - terrainInfo2.position.y + 96)];
        terrainSection.alpha = .15;
        terrainSection.position = CGPointMake(tappingUnitSection.size.width/2, self.size.height - tappingUnitSection.size.height - buttonSection.size.height - terrainSection.size.height/2);
        terrainSection.zPosition = 0;
        [background addChild: terrainSection];

        
    }
    return self;
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [TitleScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

@end

//
//  Button.h
//  AdvanceTactics
//
//  Created by Student on 5/14/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


typedef enum
{
    kButtonStateNone,
    kButtonStateHit,
}kButtonState;

@interface Button : SKSpriteNode
@property (nonatomic) int fontSize;

-(id) initWithButtonText: (NSString *) text andSize: (CGSize) size;

-(kButtonState) checkButtonTouchAt: (SKSpriteNode *) touchedNode;
-(void) changeText: (NSString *) text;
-(void) disableButton;
-(void) enableButton;
-(void) unselectButton;
-(void) setButtonBackground: (SKTexture *) texture;

@end

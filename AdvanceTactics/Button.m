//
//  Button.m
//  AdvanceTactics
//
//  Created by Student on 5/14/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "Button.h"
#import "GameManager.h"

@implementation Button
{
    SKLabelNode *_text;
    SKShapeNode * _border;
    SKSpriteNode *_background;
    BOOL _canUse;
}

-(id) initWithButtonText: (NSString *) text andSize: (CGSize) size
{
    self = [super initWithColor:[UIColor whiteColor] size:size];
    if (self)
    {
        _background = [[SKSpriteNode alloc] initWithColor: [UIColor clearColor] size: size];
        _background.alpha = .45;
        [self addChild: _background];
        
        NSString * fontName = [GameManager getFontName];
        _text = [[SKLabelNode alloc] initWithFontNamed:fontName];
        _text.position = CGPointZero;
        _text.text = text;
        _text.fontColor = [UIColor blackColor];
        _text.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild: _text];
        
        _border = [[SKShapeNode alloc] init];
        
        CGRect buttonRect = CGRectMake(-size.width/2, -size.height, size.width, size.height);
        
        _border.path = CGPathCreateWithRect(buttonRect, &CGAffineTransformIdentity);
        _border.position = CGPointMake(0, size.height/2);
        _border.strokeColor = [UIColor blackColor];
        [self addChild: _border];
               
        _canUse = YES;
    }
    return self;
}

-(void) setButtonBackground: (SKTexture *) texture
{
    _background.texture = texture;
}

-(void) changeText: (NSString *) text
{
    _text.text = text;
}

-(void)setFontSize:(int)fontSize
{
    _text.fontSize = fontSize;
}

-(void) disableButton
{
    self.alpha = .45;
    _canUse = NO;
}

-(void) enableButton
{
    self.alpha = 1;
    _canUse = YES;
}

-(kButtonState) checkButtonTouchAt: (SKSpriteNode *) touchedNode
{
    if ([touchedNode isEqual: self] && _canUse)
    {
        self.color = [UIColor blueColor];
        return kButtonStateHit;
    }
    if ([touchedNode isEqual: _text] && _canUse)
    {
        self.color = [UIColor blueColor];
        return kButtonStateHit;
    }
    if ([touchedNode isEqual: _border] && _canUse)
    {
        self.color = [UIColor blueColor];
        return kButtonStateHit;
    }
    
    [self unselectButton];
    return kButtonStateNone;
}

-(void) unselectButton
{
    self.color = [UIColor whiteColor];
}


@end

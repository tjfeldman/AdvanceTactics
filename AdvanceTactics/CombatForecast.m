//
//  combatForecast.m
//  AdvanceTactics
//
//  Created by Student on 5/11/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "CombatForecast.h"


@implementation CombatForecast
{
    SKLabelNode *_targetDamage;
    SKLabelNode *_targetDamage2;
    SKLabelNode *_unitDamage;
    SKLabelNode *_unitDamage2;
    SKLabelNode *_title;
    
    Button *_confirm;
    Button *_cancel;
}

-(id) initWithSize:(CGSize)size withFontName: (NSString *) fontName
{
    self = [super initWithColor:[UIColor blackColor] size:size];
    if (self)
    {
        self.alpha = .85;
        
        int fontSize = 48;
        
        CGSize textArea = CGSizeMake(size.width, 2*size.height/3);
        
        _title = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _title.text = @"Attack Predictions:";
        _title.fontColor = [UIColor whiteColor];
        _title.fontSize = fontSize;
        _title.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _title.position = CGPointMake(0, textArea.height - textArea.height/3 - fontSize/2);
        [self addChild: _title];
        
        /*
        SKLabelNode *title2 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        title2.text = @"Click this to attack";
        title2.fontColor = [UIColor whiteColor];
        title2.fontSize = fontSize/1.5;
        title2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        title2.position = CGPointMake(0, size.height/2 - 2*fontSize);
        [self addChild: title2];
        */
        
        SKLabelNode *display1 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        display1.text = @"You  ->  Target";
        display1.fontColor = [UIColor whiteColor];
        display1.fontSize = fontSize;
        display1.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        display1.position = CGPointMake(0, _title.position.y - fontSize * 1.5);
        [self addChild: display1];
        
        SKLabelNode *displayTargetDamage = [[SKLabelNode alloc] initWithFontNamed: fontName];
        displayTargetDamage.text = @"->";
        displayTargetDamage.fontColor = [UIColor whiteColor];
        displayTargetDamage.fontSize = fontSize;
        displayTargetDamage.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        displayTargetDamage.position = CGPointMake(0, display1.position.y - fontSize);
        [self addChild: displayTargetDamage];
        
        _targetDamage = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _targetDamage.text = @"100%";
        _targetDamage.fontColor = [UIColor whiteColor];
        _targetDamage.fontSize = fontSize;
        _targetDamage.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _targetDamage.position = CGPointMake(displayTargetDamage.position.x - fontSize * 1.5, displayTargetDamage.position.y);
        [self addChild: _targetDamage];
        
        _targetDamage2 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _targetDamage2.text = @"0%";
        _targetDamage2.fontColor = [UIColor whiteColor];
        _targetDamage2.fontSize = fontSize;
        _targetDamage2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _targetDamage2.position = CGPointMake(displayTargetDamage.position.x + fontSize * 1.5, displayTargetDamage.position.y);
        [self addChild: _targetDamage2];
        
        SKLabelNode *display2 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        display2.text = @"Target  ->  You";
        display2.fontColor = [UIColor whiteColor];
        display2.fontSize = fontSize;
        display2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        display2.position = CGPointMake(0, _title.position.y - displayTargetDamage.position.y - fontSize * 3);
        [self addChild: display2];
        
        SKLabelNode *displayUnitDamage = [[SKLabelNode alloc] initWithFontNamed: fontName];
        displayUnitDamage.text = @"->";
        displayUnitDamage.fontColor = [UIColor whiteColor];
        displayUnitDamage.fontSize = fontSize;
        displayUnitDamage.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        displayUnitDamage.position = CGPointMake(0, display2.position.y - fontSize);
        [self addChild: displayUnitDamage];
        
        _unitDamage = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _unitDamage.text = @"100%";
        _unitDamage.fontColor = [UIColor whiteColor];
        _unitDamage.fontSize = fontSize;
        _unitDamage.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _unitDamage.position = CGPointMake(displayUnitDamage.position.x - fontSize * 1.5, displayUnitDamage.position.y);
        [self addChild: _unitDamage];
        
        _unitDamage2 = [[SKLabelNode alloc] initWithFontNamed: fontName];
        _unitDamage2.text = @"0%";
        _unitDamage2.fontColor = [UIColor whiteColor];
        _unitDamage2.fontSize = fontSize;
        _unitDamage2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _unitDamage2.position = CGPointMake(displayUnitDamage.position.x + fontSize * 1.5, displayUnitDamage.position.y);
        [self addChild: _unitDamage2];
        
        CGSize buttonSize = CGSizeMake(size.width/3, size.height/4);
        
        _confirm = [[Button alloc] initWithButtonText:@"Attack!" andSize:buttonSize];
        _confirm.fontSize = fontSize;
        _confirm.position = CGPointMake(size.width/4, -size.height/3);
        [self addChild: _confirm];
        
        _cancel = [[Button alloc] initWithButtonText: @"Cancel" andSize:buttonSize];
        _cancel.fontSize = fontSize;
        _cancel.position = CGPointMake(-size.width/4, -size.height/3);
        [self addChild: _cancel];

   }
    return self;
}

-(void) displayPredictionWithDamageToTarget: (float) targetDamage fromTargetHealth: (float) targetHP andDamageToUnit: (float) unitDamage fromUnitHealth: (float) unitHP
{
    
  
    NSMutableString *target = [NSMutableString stringWithFormat: @"%.0f", targetHP * 10];
    [target appendString:@"%"];
    _targetDamage.text = target;
    if (targetHP > 7.5) { _targetDamage.fontColor = [UIColor greenColor]; }
    else if (targetHP >= 5.0) { _targetDamage.fontColor = [UIColor yellowColor]; }
    else if (targetHP >= 2.5) { _targetDamage.fontColor = [UIColor orangeColor]; }
    else { _targetDamage.fontColor = [UIColor redColor]; }
    
     targetHP -= targetDamage;
    if (targetHP < 0) { targetHP = 0; }
    
    target = [NSMutableString stringWithFormat: @"%.0f", targetHP * 10];
    [target appendString:@"%"];
   
    _targetDamage2.text = target;
    if (targetHP > 7.5) { _targetDamage2.fontColor = [UIColor greenColor]; }
    else if (targetHP >= 5.0) { _targetDamage2.fontColor = [UIColor yellowColor]; }
    else if (targetHP >= 2.5) { _targetDamage2.fontColor = [UIColor orangeColor]; }
    else { _targetDamage2.fontColor = [UIColor redColor]; }
    
    NSMutableString *unit = [NSMutableString stringWithFormat: @"%.0f", unitHP * 10];
    [unit appendString:@"%"];
    _unitDamage.text = unit;
    unitHP -= unitDamage;
    if (unitHP < 0) { unitHP = 0; }
    if (unitHP > 7.5) { _unitDamage.fontColor = [UIColor greenColor]; }
    else if (unitHP >= 5.0) { _unitDamage.fontColor = [UIColor yellowColor]; }
    else if (unitHP >= 2.5) { _unitDamage.fontColor = [UIColor orangeColor]; }
    else { _unitDamage.fontColor = [UIColor redColor]; }
    
    unit = [NSMutableString stringWithFormat: @"%.0f", unitHP * 10];
    [unit appendString:@"%"];
    
    _unitDamage2.text = unit;
    if (unitHP > 7.5) { _unitDamage2.fontColor = [UIColor greenColor]; }
    else if (unitHP >= 5.0) { _unitDamage2.fontColor = [UIColor yellowColor]; }
    else if (unitHP >= 2.5) { _unitDamage2.fontColor = [UIColor orangeColor]; }
    else { _unitDamage2.fontColor = [UIColor redColor]; }
}

-(Button *) getConfirmButton { return _confirm; }
-(Button *) getCancelButton { return _cancel; }

@end

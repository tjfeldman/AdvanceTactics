//
//  Unit.m
//  AdvanceTactics
//
//  Created by Student on 4/30/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "Unit.h"

@implementation Unit
{
    SKLabelNode * healthLabel;
}

#pragma CONVEINCE METHODS
+(Unit *) getMobileUnitForPlayer
{
    return [[Unit alloc] initWithUnitType:kUnitTypeMobile andIsAlignedTo:kUnitAlignmentPlayer];
}

+(Unit *) getTankUnitForPlayer
{
    return [[Unit alloc] initWithUnitType: kUnitTypeTank andIsAlignedTo:kUnitAlignmentPlayer];
}

+(Unit *) getRangeUnitForPlayer
{
    return [[Unit alloc] initWithUnitType:kUnitTypeRange andIsAlignedTo:kUnitAlignmentPlayer];
}

+(Unit *) getMobileUnitForEnemy
{
    return [[Unit alloc] initWithUnitType:kUnitTypeMobile andIsAlignedTo:kUnitAlignmentEnemy];
}

+(Unit *) getTankUnitForEnemy
{
    return [[Unit alloc] initWithUnitType:kUnitTypeTank andIsAlignedTo:kUnitAlignmentEnemy];
}

+(Unit *) getRangeUnitForEnemy
{
    return [[Unit alloc] initWithUnitType:kUnitTypeRange andIsAlignedTo:kUnitAlignmentEnemy];
}

-(id) initWithUnitType: (kUnitType) unitType andIsAlignedTo: (kUnitAlignment) align
{
    _canMove = YES;
    NSString *name = [self getImageName];
    
    self = [super initWithImageNamed:name];
    if (self)
    {
        //test variables
        
        self.type = unitType;
        NSDictionary *stats = [GameManager getStatsForUnitType:_type];
        
        self.level = 1;
        self.hitpoints = [stats[@"Health"] floatValue];        
        self.movement = [stats[@"Movement"] intValue];
        self.attack = [stats[@"Attack"] floatValue];
        self.defense = [stats[@"Defense"] floatValue];
        self.minRange = [stats[@"MinRange"] intValue];
        self.maxRange = [stats[@"MaxRange"] intValue];
        self.alignment = align;
        self.threatDisplay = -1;
        self.canAttack = YES;
        
        self.name = @"Unit";
        
        self.color = [UIColor blackColor];
        self.colorBlendFactor = [GameManager getOverlayBlend:align];
        
        healthLabel = [[SKLabelNode alloc] initWithFontNamed:[GameManager getFontName]];
        if (align == kUnitAlignmentEnemy) { healthLabel.fontColor = [UIColor whiteColor]; }
        if (align == kUnitAlignmentPlayer) { healthLabel.fontColor = [UIColor blackColor]; }
        healthLabel.position = CGPointMake(-self.position.x - self.size.width/2, self.position.y - self.size.height);
        healthLabel.fontSize = 16;
        
        [self updateHealthString];
        [self setScale:2];
        
        if (align == kUnitAlignmentEnemy)
        {
            [self setXScale: -2];
            [healthLabel setXScale: -1];
        }
    }
    return self;
}

//init for save loading
-(id) initWithCoder: (NSCoder *) decoder
{
	_canMove = YES;
    
    NSString *name = [self getImageName];
    self = [super initWithImageNamed:name];
	if (self)
	{
		self.type =  [[decoder decodeObjectForKey:@"type"] intValue];
		self.level = [[decoder decodeObjectForKey:@"level"] intValue];
		self.hitpoints = [[decoder decodeObjectForKey:@"hitpoints"] floatValue];
		self.movement = [[decoder decodeObjectForKey:@"movement"] intValue];
		self.attack = [[decoder decodeObjectForKey:@"attack"] floatValue];
		self.defense = [[decoder decodeObjectForKey:@"defense"] floatValue];
		self.minRange = [[decoder decodeObjectForKey:@"minRange"] intValue];
		self.maxRange = [[decoder decodeObjectForKey:@"maxRange"] intValue];
		self.alignment = [[decoder decodeObjectForKey:@"alignment"] intValue];
		
		self.threatDisplay = -1;
		self.canAttack = YES;
        
        self.name = @"Unit";
        
        self.color = [UIColor blackColor];
        self.colorBlendFactor = [GameManager getOverlayBlend: self.alignment];
        
        healthLabel = [[SKLabelNode alloc] initWithFontNamed:[GameManager getFontName]];
        if (self.alignment == kUnitAlignmentEnemy) { healthLabel.fontColor = [UIColor whiteColor]; }
        if (self.alignment == kUnitAlignmentPlayer) { healthLabel.fontColor = [UIColor blackColor]; }
        healthLabel.position = CGPointMake(-self.position.x - self.size.width/2, self.position.y - self.size.height);
        healthLabel.fontSize = 16;
        
        [self updateHealthString];
        [self setScale:2];
        
        if (self.alignment == kUnitAlignmentEnemy)
        {
            [self setXScale: -2];
            [healthLabel setXScale: -1];
        }
	}
	
	return self;
}

//set save data
- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject: [NSNumber numberWithInt:self.type] forKey:@"type"];
    [coder encodeObject: [NSNumber numberWithInt:self.level] forKey:@"level"];
    [coder encodeObject: [NSNumber numberWithInt:self.hitpoints] forKey:@"hitpoints"];
    [coder encodeObject: [NSNumber numberWithInt:self.movement] forKey:@"movement"];
    [coder encodeObject: [NSNumber numberWithFloat:self.attack] forKey:@"attack"];
    [coder encodeObject: [NSNumber numberWithFloat:self.defense] forKey:@"defense"];
    [coder encodeObject: [NSNumber numberWithInt:self.minRange] forKey:@"minRange"];
    [coder encodeObject: [NSNumber numberWithInt:self.maxRange] forKey:@"maxRange"];
    [coder encodeObject: [NSNumber numberWithInt:self.alignment] forKey:@"alignment"];
    
}

-(void) resetTexture
{
    [self checkUnitState];
}

-(void) updateHealthString
{
    healthLabel.text = [NSString stringWithFormat:@"%.0f", round(_hitpoints)];
    if (_hitpoints < 1 && _hitpoints > 0) { healthLabel.text = @"1"; }
    if (_hitpoints < 10 &&  healthLabel.parent == nil)
    {
        if (_hitpoints < 0) { _hitpoints = 0; }
        [self addChild: healthLabel];
    }
    if (healthLabel.parent == self && (_hitpoints >= 9 || _hitpoints <= 0))
    {
        if (_hitpoints > 10) { _hitpoints = 10; }
        [healthLabel removeFromParent];
    }
    
}

-(void)setHitpoints:(float)hitpoints
{
    if (_hitpoints != hitpoints)
    {
        _hitpoints = hitpoints;
        if (_hitpoints > 10) { _hitpoints = 10; }
        [self updateHealthString];
    }
}

-(void)setLastPosition:(CGPoint)lastPosition
{
    if (_lastPosition.x != lastPosition.x || _lastPosition.y != lastPosition.y)
    {
        self.canMove = NO;
        _lastPosition = lastPosition;
    }
}

- (int)movement
{
    if (_canMove) return _movement;
    else return 0;
}

-(void) checkUnitState
{
    if (_canMove || _canAttack) { _state = kUnitActive;  }
    else { _state = kUnitStandby; }
    
    NSString *textureName = [self getImageName];
    SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
    self.texture = texture;
}

-(void) setCanMove:(bool)canMove
{
    if (_canMove != canMove)
    {
        _canMove = canMove;
        [self checkUnitState];
    }
}

-(void)setCanAttack:(bool)canAttack
{
    if (_canAttack != canAttack)
    {
        _canAttack = canAttack;
        [self checkUnitState];
    }
}

-(NSString*) getImageName
{
   return [GameManager getImageNameForUnitType:_type andInState:_state];
}

    
                         

@end

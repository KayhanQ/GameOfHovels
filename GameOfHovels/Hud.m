//
//  Hud.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hud.h"
#import "GamePlayer.h"
#import "GHEvent.h"
#import "SparrowHelper.h"
#import "Tile.h"
#import "Village.h"
#import "Map.h"


@implementation Hud {
    
    SPButton* _endTurnButton;
    SPTextField* _woodField;
    SPTextField* _goldField;
    SPTextField* _healthField;
    SPTextField* _numTilesInRegion;

    int _yOffsetMinor;
    float _middleX;
    float _height;
    float _width;
}

@synthesize map = _map;

-(id)initWithMap:(Map *)map
{
    if (self=[super init]) {
        //custom code here
        
        _map = map;
        
        _height = 380;
        _width = 60;

        _yOffsetMinor = 3;
        
        
        SPQuad* background = [SPQuad quadWithWidth:_width height: _height];
        background.color = 0xcccccc;
        [self addChild:background];
        
        _middleX = _width/2;
        
        SPTexture* buttonTexture = [SPTexture textureWithContentsOfFile:@"button.png"];
        _endTurnButton = [SPButton buttonWithUpState:buttonTexture];
        _endTurnButton.text = @"End Turn";
        [SparrowHelper centerPivot:_endTurnButton];
        _endTurnButton.x = _middleX;
        _endTurnButton.y = _height - _endTurnButton.height;
        [self addChild:_endTurnButton];
        [_endTurnButton addEventListener:@selector(endTurnTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];

        
        _woodField = [self newTextField];
        _woodField.text = @"Wood: ";
        _woodField.y = 200;
        [self addChild:_woodField];
        
        _goldField = [self newTextField];
        _goldField.text = @"Gold: ";
        _goldField.y = _woodField.y + _woodField.height + _yOffsetMinor;
        [self addChild:_goldField];
        
        _healthField = [self newTextField];
        _healthField.text = @"Village Health: ";
        _healthField.y = _goldField.y + _goldField.height + _yOffsetMinor;
        [self addChild:_healthField];
        
        _numTilesInRegion = [self newTextField];
        _numTilesInRegion.text = @"Numb Tiles: ";
        _numTilesInRegion.y = _healthField.y + _healthField.height + _yOffsetMinor;
        [self addChild:_numTilesInRegion];
    }
    return self;
}

- (SPTextField*)newTextField
{
    SPTextField* t = [SPTextField textFieldWithWidth:_width height:15 text:@""];
    t.x = _middleX;
    t.border = true;
    t.fontSize = 5;
    [SparrowHelper centerPivot:t];
    return t;
}

- (void)update:(Tile *)tile
{
    Village* v = tile.village;
    
    NSString* woodString = [NSString stringWithFormat:@"Wood: %d", v.woodPile];
    _woodField.text = woodString;
    
    NSString* goldString = [NSString stringWithFormat:@"Gold: %d", v.goldPile];
    _goldField.text = goldString;
    
    NSString* healthString = [NSString stringWithFormat:@"Village Health: %d", v.health];
    _healthField.text = healthString;
    
    int tCount = [_map getTilesforVillage:v].count;
    NSString* _numTilesInRegionString = [NSString stringWithFormat:@"Numb Tiles: %d", tCount];
    _numTilesInRegion.text = _numTilesInRegionString;
    
    
    //who is the unit and all its stats, workstate
    //if you click a village then put up how many tiles the village has
}

- (void)endTurnTouched:(SPTouchEvent*) event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSLog(@"End turn pressed");
        GHEvent *event = [[GHEvent alloc] initWithType:EVENT_TYPE_TURN_ENDED];
        [self dispatchEvent:event];
    }
}


@end
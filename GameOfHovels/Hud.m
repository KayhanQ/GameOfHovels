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

@implementation Hud {
    
    SPButton* _endTurnButton;
    SPTextField* _woodField;
    SPTextField* _goldField;

    int _yOffsetMinor;
    float _middleX;
    float _height;
    float _width;
}

@synthesize player = _player;

-(id)initWithPlayer:(GamePlayer *)player
{
    if (self=[super init]) {
        //custom code here
        
        _player = player;
        
        
        _height = 385;
        _width = 140;

        _yOffsetMinor = 3;
        
        
       // SPQuad* background = [SPQuad quadWithWidth:_width height: _height]; //original
        //background.color = 0xcccccc;
             
        SPImage* background = [SPImage imageWithContentsOfFile:@"hudpanel.png"];
        background.width = _width;
        background.height = _height;
        
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
    }
    return self;
}

- (SPTextField*)newTextField
{
    SPTextField* t = [SPTextField textFieldWithWidth:_width height:15 text:@""];
    t.x = _middleX;
    t.border = true;
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
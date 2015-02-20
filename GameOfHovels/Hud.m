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

@implementation Hud {
    
    SPButton* _endTurnButton;
    SPTextField* _woodField;
    SPTextField* _goldField;

    int _yOffsetMinor;
}

@synthesize player = _player;

-(id)initWithPlayer:(GamePlayer *)player
{
    if (self=[super init]) {
        //custom code here
        
        _player = player;
        
        
        _yOffsetMinor = 10;
        
        
        SPTexture* buttonTexture = [SPTexture textureWithContentsOfFile:@"button.png"];
        _endTurnButton = [SPButton buttonWithUpState:buttonTexture];
        _endTurnButton.text = @"End Turn";
        [self addChild:_endTurnButton];
        [_endTurnButton addEventListener:@selector(endTurnTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];

        
        _woodField = [SPTextField textFieldWithWidth:200 height:30 text:@"Wood: 0"];
        _woodField.x = 700 - _woodField.width;
        _woodField.pivotX = _woodField.width;
        _woodField.hAlign = SPHAlignRight;
        _woodField.border = false;
        [self addChild:_woodField];
        
        _goldField = [SPTextField textFieldWithWidth:200 height:30 text:@"Gold: 0"];
        _goldField.x = _woodField.x;
        _goldField.y = _woodField.y + _woodField.height + _yOffsetMinor;
        _goldField.pivotX = _goldField.width;
        _goldField.hAlign = SPHAlignRight;

        [self addChild:_goldField];
    }
    return self;
}

- (void)update
{
    NSString* woodString = [NSString stringWithFormat:@"Wood: %d", _player.woodPile];
    _woodField.text = woodString;
    
    NSString* goldString = [NSString stringWithFormat:@"Gold: %d", _player.goldPile];
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
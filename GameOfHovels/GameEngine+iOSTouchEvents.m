//
//  GameEngine+iOSTouchEvents.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "GameEngine+iOSTouchEvents.h"
#import "Map.h"

@implementation GameEngine (iOSTouchEvents)

- (void)onMapTouched:(SPTouchEvent *)event
{
    //NSSet *touches = [event touchesWithTarget:self andPhase:SPTouchPhaseEnded];
    
    _touching = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] count] == 0;
    if (!_touching) return;
    
    SPTouch* touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseMoved] anyObject];
    SPPoint *localPos = [touch locationInSpace:self];
    SPPoint *previousLocalPos = [touch previousLocationInSpace:self];
    
    _scrollVector.x = previousLocalPos.x - localPos.x;
    _scrollVector.y = previousLocalPos.y - localPos.y;
    
    _world.x -= _scrollVector.x;
    _world.y -= _scrollVector.y;
}

// enter frame event listener
- (void)onEnterFrame:(SPEnterFrameEvent *)event
{
    if (!_touching)
    {
        float slowDown = 0.8f;
        
        if (fabsf(_lastScrollDist) < 0.5f)
            slowDown = 0;
        
        _scrollVector.x *= slowDown;
        _scrollVector.y *= slowDown;
        
        _world.x += _scrollVector.x;
        _world.y += _scrollVector.y;
    }
    
    
}



@end
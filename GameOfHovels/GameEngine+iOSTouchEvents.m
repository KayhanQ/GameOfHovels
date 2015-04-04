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
    NSArray *touchesMoved = [[event touchesWithTarget:self andPhase:SPTouchPhaseMoved] allObjects];

    _touching = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] count] == 0;
    
    if (touchesMoved.count == 2) {
        SPPoint *previousPos1 = [[touchesMoved objectAtIndex:0] previousLocationInSpace:_world];
        SPPoint *previousPos2 = [[touchesMoved objectAtIndex:1] previousLocationInSpace:_world];
        
        SPPoint *currentPos1 = [[touchesMoved objectAtIndex:0] locationInSpace:_world];
        SPPoint *currentPos2 = [[touchesMoved objectAtIndex:1] locationInSpace:_world];
        
        float distance1 = [SPPoint distanceFromPoint:currentPos1 toPoint:currentPos2];
        float distance2 = [SPPoint distanceFromPoint:previousPos1 toPoint:previousPos2];
        
        float scaleX = (([_world scaleX] / distance2) * distance1);
        float scaleY = (([_world scaleY] / distance2) * distance1);
        
        if (scaleX > 0.40 && scaleX <= 1.00) {
            _world.scaleX = scaleX;
            _world.scaleY = scaleY;
        }
    }
    if (_touching) {
        SPTouch* touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseMoved] anyObject];
        SPPoint *localPos = [touch locationInSpace:self];
        SPPoint *previousLocalPos = [touch previousLocationInSpace:self];
        
        _scrollVector.x = previousLocalPos.x - localPos.x;
        _scrollVector.y = previousLocalPos.y - localPos.y;
        
        _world.x -= _scrollVector.x;
        _world.y -= _scrollVector.y;
    }

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
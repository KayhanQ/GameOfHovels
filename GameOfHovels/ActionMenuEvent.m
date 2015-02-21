//
//  ActionMenuEvent.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 21/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionMenuEvent.h"

@implementation ActionMenuEvent
{
    Tile* _tile;
}

@synthesize tile = _tile;
@synthesize aType = _aType;

- (id)initWithType:(NSString *)type tile:(Tile *)tile actionType:(enum ActionType)aType
{
    if ((self = [super initWithType:type bubbles:YES]))
    {
        _tile = tile;
        _aType = aType;
    }
    return self;
}

@end
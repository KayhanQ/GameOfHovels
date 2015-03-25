//
//  CurrentGameAction.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 24/03/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentPlayerAction.h"


@implementation CurrentPlayerAction {
    
}

@synthesize selectedTile = _selectedTile;
@synthesize action = _action;


-(id)init
{
    if (self=[super init]) {
        //custom code here
        _selectedTile = nil;
        _action = AWAITINGCOMMAND;
    }
    return self;
}

- (void)setAwaitingCommand
{
    _action = AWAITINGCOMMAND;
}

- (BOOL)isAwaitingCommand
{
    if (_action == AWAITINGCOMMAND) return true;
    return false;
}

@end

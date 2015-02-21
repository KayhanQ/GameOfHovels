//
//  ActionMenuEvent.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 21/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "Tile.h"
#import "ActionMenu.h"

#define EVENT_TYPE_ACTION_MENU_ACTION @"actionMenuAction"

@interface ActionMenuEvent : SPEvent
{
    
}

- (id)initWithType:(NSString *)type tile:(Tile*)tile actionType:(enum ActionType)aType;

@property (nonatomic, readonly) Tile* tile;
@property (nonatomic, readonly) enum ActionType aType;

@end
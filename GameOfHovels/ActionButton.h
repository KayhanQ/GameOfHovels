//
//  ActionButton.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 21/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "BasicSprite.h"
#import "ActionMenuEvent.h"
@class Tile;

@interface ActionButton : BasicSprite {
    
    
    
}

@property (nonatomic) enum ActionType aType;
@property (nonatomic) Tile* tile;

- (id)initWithActionType:(enum ActionType)aType tile:(Tile*)tile;


@end

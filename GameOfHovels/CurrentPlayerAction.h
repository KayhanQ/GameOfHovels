//
//  CurrentGameAction.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 24/03/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//


#import "Tile.h"
#import "ActionMenu.h"

@interface CurrentPlayerAction : NSObject {
    
    
    
}

@property (nonatomic) Tile* selectedTile;
@property (nonatomic) enum ActionType action;

- (id)init;
- (BOOL)isAwaitingCommand;
- (void)setAwaitingCommand;

@end
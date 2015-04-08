//
//  Hud.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "BasicSprite.h"
@class Tile;
@class Map;
@class GamePlayer;

@interface Hud : BasicSprite {
    
    
}

@property (nonatomic, readonly) Map* map;
@property (nonatomic) GamePlayer* player;

- (id)initWithMap:(Map*)map world:(SPSprite*)world;
- (void)update:(Tile*)tile;
- (void)updateUITool;

- (void)quitTouched:(SPTouchEvent*) event;

@end
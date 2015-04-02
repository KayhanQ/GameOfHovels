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

@interface Hud : BasicSprite {
    
    
    
}

@property (nonatomic, readonly) Map* map;

- (id)initWithMap:(Map*)map;
- (void)update:(Tile*)tile;



@end
//
//  Hud.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "BasicSprite.h"
@class Tile;
@class GamePlayer;

@interface Hud : BasicSprite {
    
    
    
}

- (id)init;
- (void)updateWithPlayer:(GamePlayer*)player;



@end
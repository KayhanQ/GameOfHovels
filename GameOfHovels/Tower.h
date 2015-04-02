//
//  Tower.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 31/03/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

@class Structure;
#import "Structure.h"


@interface Tower : Structure {
    
    
    
}

-(id)initWithTile:(Tile *)tile;

@property(nonatomic, readonly) int strength;
@property(nonatomic, readonly) int buyCostWood;

@end
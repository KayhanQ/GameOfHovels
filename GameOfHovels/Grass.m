//
//  Grass.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "Grass.h"
#import "SparrowHelper.h"
#import "Media.h"

@implementation Grass {
    
}

-(id)initWithTile:(Tile *)tile
{
    
    if (self=[super initWithStructureType:GRASS]) {
        //custom code here
    
        
        SPTexture* tileTexture = [Media atlasTexture:@"tileGrass_tile.png"];
        SPImage* image = [SPImage imageWithTexture:tileTexture];
        [self addChild:image];

        
        [SparrowHelper centerPivot:self];
        
        
    }
    return self;
    
}


@end
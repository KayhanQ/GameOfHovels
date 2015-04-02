//
//  Canon.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 26/03/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cannon.h"
#import "Tile.h"
#import "SparrowHelper.h"
#import "Media.h"

@implementation Cannon {
    
}



-(id)initWithTile:(Tile *)tile {
    
    if (self=[super initWithUnitType:CANNON]) {
        //custom code here
        SPJuggler* juggler = [SparrowHelper sharedSparrowHelper].gameJuggler;
        
        
        SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"cannon.xml"];
        NSArray*textures = [atlas texturesStartingWith:@"attack s"];
        
        SPMovieClip* movie = [[SPMovieClip alloc] initWithFrames:textures fps:10];
        [SparrowHelper centerPivot:movie];
        movie.scale = 0.65;
        [self addChild:movie];
        
        [movie play];
        [juggler addObject:movie];

    }
    return self;
    
}


@end
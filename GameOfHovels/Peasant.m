//
//  Peasant.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 10/03/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peasant.h"
#import "Tile.h"
#import "SparrowHelper.h"

@implementation Peasant {
    
}



-(id)initWithTile:(Tile *)tile {
    
    if (self=[super initWithUnitType:PEASANT]) {
        //custom code here
        SPJuggler* juggler = [SparrowHelper sharedSparrowHelper].gameJuggler;
        
        
        SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"peasant.xml"];
        
        NSArray*idleTextures = [atlas texturesStartingWith:@"talking without axe"];
        _idleMovie = [[SPMovieClip alloc] initWithFrames:idleTextures fps:10];
        [SparrowHelper centerPivot:_idleMovie];
        _idleMovie.scale = 0.65;
        [self addChild:_idleMovie];
        [_idleMovie play];
        [juggler addObject:_idleMovie];
        
        //repeat this block of code for all other animations
        NSArray*walkTextures = [atlas texturesStartingWith:@"walking without axe"];
        _walkMovie = [[SPMovieClip alloc] initWithFrames:walkTextures fps:10];
        [SparrowHelper centerPivot:_walkMovie];
        _walkMovie.scale = 0.65;
        _walkMovie.visible = NO;
        [self addChild:_walkMovie];

        
    }
    return self;
}


@end
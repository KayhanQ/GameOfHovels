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
        NSArray*textures = [atlas texturesStartingWith:@"felling tree e"];
        
        SPMovieClip* movie = [[SPMovieClip alloc] initWithFrames:textures fps:10];
        
        [SparrowHelper centerPivot:movie];
        [self addChild:movie];
        
        [movie play];
        
        [juggler addObject:movie];
        
        /*
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"peasant.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.5;
        [self addChild:baseImage];
        [SparrowHelper centerPivot:self];
         */
    }
    return self;
}


@end
//
//  Infantry.m
//  GameOfHovels
//
//  Created by Aleksandra Lata on 3/17/15.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Infantry.h"
#import "Tile.h"
#import "SparrowHelper.h"

@implementation Infantry {
    
}



-(id)initWithTile:(Tile *)tile {
    
    if (self=[super initWithUnitType:INFANTRY]) {
        //custom code here
        SPJuggler* juggler = [SparrowHelper sharedSparrowHelper].gameJuggler;
        
        
        SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"infantry.xml"];
        NSArray*textures = [atlas texturesStartingWith:@"looking s"];
        
        SPMovieClip* movie = [[SPMovieClip alloc] initWithFrames:textures fps:10];
        [SparrowHelper centerPivot:movie];
        movie.scale = 0.65;
        [self addChild:movie];
        
        [movie play];
        [juggler addObject:movie];
        /*
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"infantry.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.4;
        [self addChild:baseImage];
        [SparrowHelper centerPivot:self]; 
         */
    }
    return self;
    
}


@end
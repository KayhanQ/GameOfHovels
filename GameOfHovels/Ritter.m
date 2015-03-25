//
//  Ritter.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 16/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Ritter.h"
#import "Tile.h"
#import "SparrowHelper.h"

@implementation Ritter {
    
}



-(id)initWithTile:(Tile *)tile {
    
    if (self=[super initWithUnitType:RITTER]) {
        //custom code here
        
        SPJuggler* juggler = [SparrowHelper sharedSparrowHelper].gameJuggler;

        
        SPTextureAtlas *atlas = [SPTextureAtlas atlasWithContentsOfFile:@"archer.xml"];
        NSArray*textures = [atlas texturesStartingWith:@"talking"];
        
        SPMovieClip* movie = [[SPMovieClip alloc] initWithFrames:textures fps:10];
        
        [SparrowHelper centerPivot:movie];
        movie.scale = 0.6;
        [self addChild:movie];
        
        [movie play];
        
        [juggler addObject:movie];
        
        /*
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"archer1.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.4;
        [self addChild:baseImage];
        [SparrowHelper centerPivot:self];
         */

    }
    return self;
    
}


@end
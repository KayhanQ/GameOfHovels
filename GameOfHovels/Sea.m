//
//  Sea.m
//  GameOfHovels
//
//  Created by Brendan
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Sea.h"
#import "SparrowHelper.h"
#import "Tile.h"
#import "Media.h"

@implementation Sea {
    
}

-(id)initWithTile:(Tile *)tile
{
    
    if (self=[super initWithStructureType:SEA]) {
        //custom code here
        
        
        SPTexture* tileTexture = [Media atlasTexture:@"tileWater_tile.png"];
        SPImage* image = [SPImage imageWithTexture:tileTexture];
        [self addChild:image];
        
        
        [SparrowHelper centerPivot:self];
        
        
    }
    return self;
    
}


@end
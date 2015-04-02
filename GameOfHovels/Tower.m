//
//  Tower.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 31/03/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tower.h"
#import "SparrowHelper.h"
#import "Tile.h"


@implementation Tower {
    
}

@synthesize strength = _strength;
@synthesize buyCostWood = _buyCostWood;


-(id)initWithTile:(Tile *)tile
{
    
    if (self=[super initWithStructureType:TOWER]) {
        //custom code here
        
        _strength = 2;
        _buyCostWood = 5;
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"tower.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.15;
        
        [self addChild:baseImage];
        
        [SparrowHelper centerPivot:self];
        
        
    }
    return self;
}


@end
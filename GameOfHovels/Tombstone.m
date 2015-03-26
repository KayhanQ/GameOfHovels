//
//  Tombstone.m
//  GameOfHovels
//
//  Created by Aleksandra Lata on 3/17/15.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tombstone.h"
#import "SparrowHelper.h"
#import "Tile.h"


@implementation Tombstone {
    
}

-(id)initWithTile:(Tile *)tile
{
    
    if (self=[super initWithStructureType:TOMBSTONE]) {
        //custom code here
        
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"tombstone.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.15;
        
        [self addChild:baseImage];
        
        [SparrowHelper centerPivot:self];
        
        
    }
    return self;
    
}


@end
//
//  Road.m
//  GameOfHovels
//
//  Created by Aleksandra Lata on 3/17/15.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Road.h"
#import "SparrowHelper.h"
#import "Tile.h"


@implementation Road {
    
}

-(id)initWithTile:(Tile *)tile
{
    
    if (self=[super initWithStructureType:ROAD]) {
        //custom code here
        
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"road.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.35;
        
        [self addChild:baseImage];
        
        [SparrowHelper centerPivot:self];
        
        
    }
    return self;
    
}


@end
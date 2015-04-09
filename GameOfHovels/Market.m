//
//  Market.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 08/04/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Market.h"
#import "SparrowHelper.h"
#import "Tile.h"


@implementation Market {
    
}

-(id)initWithTile:(Tile *)tile
{
    
    if (self=[super initWithStructureType:MARKET]) {
        //custom code here
        
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"market.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.25;
        
        [self addChild:baseImage];
        
        [SparrowHelper centerPivot:self];
        
        
    }
    return self;
    
}

@end
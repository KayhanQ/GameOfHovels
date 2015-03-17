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
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"peasant.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.5;
        [self addChild:baseImage];
        [SparrowHelper centerPivot:self];
        self.x = tile.x;
        self.y = tile.y;
    }
    return self;
}


@end
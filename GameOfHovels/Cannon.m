//
//  Canon.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 26/03/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cannon.h"
#import "Tile.h"
#import "SparrowHelper.h"
#import "Media.h"

@implementation Cannon {
    
}



-(id)initWithTile:(Tile *)tile {
    
    if (self=[super initWithUnitType:CANNON]) {
        //custom code here
        
        SPTexture* cannonTexture = [Media atlasTexture:@"alienPink.png"];
        SPImage* baseImage = [SPImage imageWithTexture:cannonTexture];
        baseImage.scale = 0.4;
        [self addChild:baseImage];
        [SparrowHelper centerPivot:self];
    }
    return self;
    
}


@end
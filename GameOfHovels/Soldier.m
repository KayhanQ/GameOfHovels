//
//  Soldier.m
//  GameOfHovels
//
//  Created by Aleksandra Lata on 3/17/15.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Soldier.h"
#import "Tile.h"
#import "SparrowHelper.h"

@implementation Soldier {
    
}



-(id)initWithTile:(Tile *)tile {
    
    if (self=[super initWithUnitType:SOLDIER]) {
        //custom code here
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"soldier.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.4;
        [self addChild:baseImage];
        [SparrowHelper centerPivot:self];
        
        self.x = tile.x;
        self.y = tile.y;
    }
    return self;
    
}


@end
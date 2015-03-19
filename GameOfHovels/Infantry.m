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
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"infantry.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.4;
        [self addChild:baseImage];
        [SparrowHelper centerPivot:self]; 
    }
    return self;
    
}


@end
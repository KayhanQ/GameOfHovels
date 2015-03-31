//
//  Castle.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 26/03/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Castle.h"
#import "Tile.h"
#import "SparrowHelper.h"


@implementation Castle
{
    
}


-(id)initWithTile:(Tile *)tile
{
    if (self=[super initWithStructureType:CASTLE]) {
        //custom code here
        
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"castle.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.08;
        [self addChild:baseImage];
        
        [SparrowHelper centerPivot:self];
        
        self.pivotY = self.pivotY+15;
    }
    return self;
    
}


@end
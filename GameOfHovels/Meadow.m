//
//  Meadow.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Meadow.h"
#import "SparrowHelper.h"
#import "Tile.h"


@implementation Meadow {
    
}

-(id)initWithTile:(Tile *)tile
{
    
    if (self=[super initWithStructureType:MEADOW]) {
        //custom code here
        
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"meadow.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.18;
        
        [self addChild:baseImage];

        [SparrowHelper centerPivot:self];

        
    }
    return self;
    
}


@end
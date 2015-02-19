//
//  Hovel.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Hovel.h"
#import "Tile.h"
#import "SparrowHelper.h"

@implementation Hovel
{
    
}


-(id)initWithTile:(Tile *)tile
{
    if (self=[super initWithStructureType:HOVEL]) {
        //custom code here
        
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"hovel.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.22;
        [self addChild:baseImage];
        
        [SparrowHelper centerPivot:self];

    }
    return self;
    
}


@end
//
//  Town.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Town.h"
#import "Tile.h"
#import "SparrowHelper.h"


@implementation Town
{
    
}


-(id)initWithTile:(Tile *)tile
{
    if (self=[super initWithStructureType:TOWN]) {
        //custom code here
        
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"town.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.22;
        [self addChild:baseImage];
        

        [SparrowHelper centerPivot:self];
        
        self.pivotY = self.pivotY+10;

    }
    return self;
    
}


@end
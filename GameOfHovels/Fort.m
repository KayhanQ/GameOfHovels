//
//  Fort.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Fort.h"
#import "Tile.h"
#import "SparrowHelper.h"


@implementation Fort
{
    
}


-(id)initWithTile:(Tile *)tile
{
    if (self=[super initWithStructureType:FORT]) {
        //custom code here
        
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"fort.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.22;
        [self addChild:baseImage];
        
        [SparrowHelper centerPivot:self];
        
        self.pivotY = self.pivotY+15;
    }
    return self;
    
}


@end
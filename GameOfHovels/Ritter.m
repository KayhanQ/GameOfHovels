//
//  Ritter.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 16/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Ritter.h"
#import "Tile.h"
#import "SparrowHelper.h"

@implementation Ritter {
    
}



-(id)initWithTile:(Tile *)tile {
    
    if (self=[super initWithUnitType:RITTER]) {
        //custom code here
        

        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"archer1.png"];
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
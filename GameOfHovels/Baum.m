//
//  Baum.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 12/02/2015.
//
//

#import "Baum.h"
#import "SparrowHelper.h"


@implementation Baum {
    
}

@synthesize newlyGrown = _newlyGrown;

-(id)initWithTile:(Tile *)tile
{
    
    if (self=[super initWithStructureType:BAUM]) {
        //custom code here
        
        //We have to check if a tree has just grown this turn
        _newlyGrown = true;
        
        SPTexture* baseTexture = [SPTexture textureWithContentsOfFile:@"baum.png"];
        SPImage* baseImage = [SPImage imageWithTexture:baseTexture];
        baseImage.scale = 0.3;
        [self addChild:baseImage];
        
        
        [SparrowHelper centerPivot:self];


    }
    return self;
    
}


@end
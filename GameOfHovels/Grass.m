//
//  Grass.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "Grass.h"
#import "GamePlayer.h"
#import "Tile.h"
#import "SparrowHelper.h"
#import "Media.h"

@implementation Grass {
    
}

-(id)initWithTile:(Tile *)tile
{
    
    if (self=[super initWithStructureType:GRASS]) {
        //custom code here
    
        enum PlayerColor pColor = tile.pColor;
        
        SPTexture* tileTexture;
        switch (pColor) {
            case RED:
            {
                tileTexture = [Media atlasTexture:@"tileLava_tile.png"];
                break;
            }
            case BLUE:
            {
                tileTexture = [Media atlasTexture:@"tileMagic_tile.png"];
                break;
            }
            case GREY:
            {
                tileTexture = [Media atlasTexture:@"tileStone_tile.png"];
                break;
            }
            case ORANGE:
            {
                tileTexture = [Media atlasTexture:@"tileDirt_tile.png"];
                break;
            }
            default:
            {
                tileTexture = [Media atlasTexture:@"tileGrass_tile.png"];
                break;
            }
        }
        
        
        SPImage* image = [SPImage imageWithTexture:tileTexture];
        [self addChild:image];

        
        [SparrowHelper centerPivot:self];
        
        
    }
    return self;
    
}


@end
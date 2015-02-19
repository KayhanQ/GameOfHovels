//
//  ActionMenu.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import "BasicSprite.h"
@class Tile;

@interface ActionMenu : BasicSprite {
    
    
    
}

@property (nonatomic) Tile* tile;


-(id)initWithTile: (Tile*)tile;




@end
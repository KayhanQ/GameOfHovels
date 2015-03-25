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
    
    enum ActionType {AWAITINGCOMMAND = 0, UPGRADEVILLAGE, BUYUNIT, BUILDMEADOW, BUILDROAD, MOVEUNIT, UPGRADEUNIT};

    
}

@property (nonatomic) Tile* tile;


-(id)initWithTile: (Tile*)tile;




@end
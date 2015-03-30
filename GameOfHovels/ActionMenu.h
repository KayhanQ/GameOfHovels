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
    
    enum ActionType {BUYPEASANT = 1, BUYINFANTRY, BUYSOLDIER, BUYRITTER, BUYCANNON, AWAITINGCOMMAND, UPGRADEVILLAGE,  BUILDMEADOW, BUILDROAD, MOVEUNIT, UPGRADEUNIT};

    
}

@property (nonatomic) Tile* tile;
@property (nonatomic) SPSprite* buttonSprite;;


-(id)initWithTile: (Tile*)tile;




@end
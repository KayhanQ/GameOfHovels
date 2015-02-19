//
//  Map.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import "BasicSprite.h"

@class Tile;
@class GamePlayer;

@interface Map : BasicSprite {
    
    
}

- (id)initWithRandomMap:(NSMutableArray*)players;
- (void)treeGrowthPhase;

- (void)upgradeVillageWithTile:(Tile*)tile;

- (void)showPlayersTeritory;


@end

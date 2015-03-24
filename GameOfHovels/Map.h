//
//  Map.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import "BasicSprite.h"

#import "Unit.h"
#import "Village.h"

@class Tile;
@class GamePlayer;
@class Hud;
@class MessageLayer;
@class GameEngine;

@interface Map : BasicSprite {

    enum MovesType {TOOWNTILE = 0, TOOWNUNIT, TOOWNVILLAGE, TOBAUM, TOMEADOW, TONEUTRALTILE, TOENEMYTILE, MERGEVILLAGES};

}

@property GameEngine* gameEngine;
@property (nonatomic) MessageLayer* messageLayer;
@property (nonatomic) SPSprite* tilesSprite;
@property (nonatomic, readonly) Hud* hud;


- (id)initWithRandomMap:(Hud*)hud;
- (void)beginTurnPhases;

- (void)treeGrowthPhase;
- (void)endTurnUpdates;

- (void)upgradeVillageWithTile:(Tile*)tile villageType:(enum VillageType)vType;
- (void)upgradeUnitWithTile:(Tile *)tile unitType:(enum UnitType)uType;

- (void)showPlayersTeritory;

- (void)moveUnitWithTile:(Tile*)unitTile tile:(Tile*)destTile;
- (void)takeOverTile:(Tile*)unitTile tile:(Tile*)destTile;

- (void)buyUnitFromTile:(Tile*)villageTile tile:(Tile*)destTile;

- (void)chopTree:(Tile*)tile;
- (void)buildMeadow:(Tile*)tile;
- (void)buildRoad:(Tile*)tile;

@end

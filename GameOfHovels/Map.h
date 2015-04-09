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

    enum MovesType {TOOWNTILE = 0, TOOWNUNIT, TOOWNVILLAGE, TOBAUM, TOMEADOW, TOTOMBSTONE, TOOWNTOWER, TONEUTRALTILE, TOENEMYTILE, MERGEVILLAGES, TOSEA};

}

@property GameEngine* gameEngine;
@property (nonatomic) MessageLayer* messageLayer;
@property (nonatomic) SPSprite* tilesSprite;
@property (nonatomic) Hud* hud;


- (id)initWithRandomMap;
- (id)initWithBasicMap;

- (void)assignPlayerInfoForLoadGame;

- (void)beginTurnPhases;
- (void)buildPhase;




-(BOOL)isMyTurn;

- (void)treeGrowthPhase;
- (void)endTurnUpdates;

- (void)upgradeVillageWithTile:(Tile*)tile villageType:(enum VillageType)vType;
- (void)upgradeUnitWithTile:(Tile *)tile unitType:(enum UnitType)uType;
-(Tile*)getVillageTile:(Village*)v;

- (NSMutableArray*)getTilesforVillage:(Village*)v;
- (NSMutableArray*)getTilesForEnemyUnitsProtectingTile:(Tile*)tile;
- (NSMutableArray*)getTilesWithMyVillages;




- (void)showPlayersTeritory;

- (void)moveUnitWithTile:(Tile*)unitTile tile:(Tile*)destTile;
- (void)takeOverTile:(Tile*)unitTile tile:(Tile*)destTile;

- (void)buyUnitFromTile:(Tile*)villageTile tile:(Tile*)destTile unitType:(enum UnitType)uType;
- (void)shootCannonFromTile:(Tile*)unitTile tile:(Tile*)destTile;
- (void)buildMeadow:(Tile*)tile;
- (void)buildMarket:(Tile*)tile;
- (void)buildRoad:(Tile*)tile;
- (void)buildTowerFromTile:(Tile*)villageTile tile:(Tile*)destTile;

@end

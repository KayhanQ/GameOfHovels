//
//  Tile.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import "BasicSprite.h"
#import "Village.h"
#import "Structure.h"
#import "GamePlayer.h"
#import "Unit.h"

@class Unit;

@interface Tile : BasicSprite {
    enum TileNeighbours {TopRight = 0, Right, BottomRight, BottomLeft, Left, TopLeft};

}

@property (nonatomic, readonly) SPImage* baseImage;
@property (nonatomic) Unit* unit;
@property (nonatomic) Village* village;
@property (nonatomic) enum PlayerColor pColor;

- (id)initWithPosition: (SPPoint*)position structure: (enum StructureType)sType;
- (void)setNeighbour:(enum TileNeighbours)tileNeighbour tile: (Tile*)tile;
- (Tile*)getNeighbour:(enum TileNeighbours)tileNeighbour;
- (NSMutableArray*)getNeighbours;

- (void)setPColor:(enum PlayerColor)pColor;

- (void)addStructure:(enum StructureType)sType;

- (void)removeStructure;

- (BOOL)neighboursContainTile:(Tile*) tile;
- (enum StructureType)getStructureType;
- (BOOL)isTraversableForUnitType: (int)unitType;
- (void)addVillage:(enum VillageType) vType;
- (void)upgradeVillage;
- (BOOL)hasVillage;
- (BOOL)isVillage;

- (void)addUnitWithType:(enum UnitType)uType;
- (void)addUnit:(Unit*)unit;
- (void)removeUnit;
- (BOOL)hasUnit;
- (void)upgradeUnit:(enum UnitType)uType;

- (void)selectTile;
- (void)deselectTile;
- (BOOL)canBeSelected;
- (BOOL)canHaveTree;
- (BOOL)canHaveUnit;

- (Structure*)getStructure;


@end
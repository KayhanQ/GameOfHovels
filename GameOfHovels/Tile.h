//
//  Tile.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import "Unit.h"
#import "BasicSprite.h"
#import "Village.h"
#import "Structure.h"

@class Unit;

@interface Tile : BasicSprite {
    
 
    enum TileNeighbours {TopRight = 0, Right, BottomRight, BottomLeft, Left, TopLeft};

}

@property (nonatomic, readonly) SPImage* baseImage;
@property (nonatomic) Unit* unit;
@property (nonatomic) int color;
@property (nonatomic) BOOL isVillage;
@property (nonatomic) Village* village;

- (id)initWithPosition: (SPPoint*)position structure: (enum StructureType)sType;
- (void)setNeighbour:(int)tileNeighbour tile: (Tile*)tile;
- (Tile*)getNeighbour:(int)tileNeighbour;
- (NSMutableArray*)getNeighbours;

- (void)addStructure:(enum StructureType)sType;

- (void)removeStructure;

- (BOOL)neighboursContainTile:(Tile*) tile;
- (enum StructureType)getStructureType;
- (BOOL)isTraversableForUnitType: (int)unitType;
- (void)addVillage:(enum VillageType) vType;
- (void)upgradeVillage;


- (void)selectTile;
- (void)deselectTile;
- (BOOL)canBeSelected;
- (BOOL)canHaveTree;
- (BOOL)canHaveUnit;

- (Structure*)getStructure;


@end
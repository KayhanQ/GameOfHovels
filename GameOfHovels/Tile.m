//
//  Tile.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Tile.h"
#import "TileTouchedEvent.h"

#import "Structure.h"
#import "Grass.h"
#import "Baum.h"
#import "Meadow.h"
#import "Road.h"
#import "Tombstone.h"

#import "Hovel.h"
#import "Town.h"
#import "Fort.h"

#import "Peasant.h"
#import "Soldier.h"
#import "Infantry.h"
#import "Ritter.h"
#import "Cannon.h"

#import "Media.h"
#import "GamePlayer.h"

#import "SparrowHelper.h"


@implementation Tile {
    SPSprite* _structuresSprite;
    SPSprite* _villageSprite;
    SPSprite* _unitSprite;

    Tile* topRightNeighbour;
    Tile* rightNeighbour;
    Tile* bottomRightNeighbour;

    SPImage* _tileLayer;
    SPImage* _selectionLayer;
    
    NSMutableArray* _neighboursArray;
    NSTimer* _timer;
}

@synthesize baseImage = _baseImage;
@synthesize unit = _unit;
@synthesize village = _village;
@synthesize pColor = _pColor;
@synthesize visitedBySearch = _visitedBySearch;

-(id)initWithPosition:(SPPoint *)position structure:(enum StructureType)sType
{
    if (self=[super init]) {
        //custom code here
        
        _neighboursArray = [[NSMutableArray alloc] initWithCapacity:6];
        
        _unit = nil;
        _village = nil;
        _pColor = NOCOLOR;
        _visitedBySearch = false;
        
        _structuresSprite = [SPSprite sprite];
        _structuresSprite.x = self.width/2;
        _structuresSprite.y = self.height/2;
        [self addChild:_structuresSprite];
        
        //Tile needs some image to bw touched so we give it an 'empty' Tile
        //Right now this is a grass but eventually it will be white
        SPTexture* tileTexture = [Media atlasTexture:@"tileGrass_tile.png"];
        _selectionLayer = [SPImage imageWithTexture:tileTexture];
        [SparrowHelper centerPivot:_selectionLayer];
        _selectionLayer.alpha = 0.2;
        [self addChild:_selectionLayer];
        
        
        [self addStructure:sType];
        
        _villageSprite = [SPSprite sprite];
        [self addChild:_villageSprite];
        
        _unitSprite = [SPSprite sprite];
        [self addChild:_unitSprite];
        
        [SparrowHelper centerPivot:self];
        self.x = position.x;
        self.y = position.y;
        
        [self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    }
    return self;
}

- (void)addUnitWithType:(enum UnitType)uType
{
    Unit* newUnit;
    
    switch (uType) {
        case PEASANT:
        {
            newUnit = [[Peasant alloc] initWithTile:self];
            break;
        }
        case INFANTRY:
        {
            newUnit = [[Infantry alloc] initWithTile:self];
            break;
        }
        case SOLDIER:
        {
            newUnit = [[Soldier alloc] initWithTile:self];
            break;
        }
        case RITTER:
        {
            newUnit = [[Ritter alloc] initWithTile:self];
            break;
        }
        default:
            break;
    }
    
    _unit = newUnit;
    [_unitSprite addChild:_unit];
}

- (void)addUnit:(Unit*)unit
{
    [_unitSprite removeAllChildren];
    _unit = unit;
    [_unitSprite addChild:_unit];
}

- (void)removeUnit
{
    [_unitSprite removeAllChildren];
    _unit = nil;
}


- (Unit*)getUnit
{
    return _unit;
}

- (enum UnitType)getUnitType
{
    Unit* u = [self getUnit];
    return u.uType;
}


//upgrades to whatever uType is
- (void)upgradeUnit:(enum UnitType)uType
{
    Unit* newUnit;
    
    switch (uType) {
        case INFANTRY:
        {
            newUnit = [[Infantry alloc] initWithTile:self];
            break;
        }
        case SOLDIER:
        {
            newUnit = [[Soldier alloc] initWithTile:self];
            break;
        }
        case RITTER:
        {
            newUnit = [[Ritter alloc] initWithTile:self];
            break;
        }
        case CANNON:
        {
            newUnit = [[Cannon alloc] initWithTile:self];
            break;
        }
        default:
            break;
    }
    
    [_unitSprite removeAllChildren];
    [newUnit transferPropertiesFrom:_unit];
    _unit = newUnit;
    [_unitSprite addChild:_unit];
}

//adds a physical village to the tile
-(void)addVillage:(enum VillageType) vType
{
    Hovel* h = [[Hovel alloc] initWithTile:self];
    [_villageSprite addChild:h];
    _village = h;
}

- (void)removeVillage
{
    [_villageSprite removeAllChildren];
    _village = nil;
}

- (void)upgradeVillage:(enum VillageType) vType
{
    Village* newVillage;
    switch (vType) {
        case TOWN:
        {
            newVillage = [[Town alloc] initWithTile:self];
            break;
        }
        case FORT:
        {
            newVillage = [[Fort alloc] initWithTile:self];
            break;
        }
        default:
        {
            return;
        }
    }
    [_villageSprite removeAllChildren];
    [_villageSprite addChild: newVillage];
    newVillage.player = _village.player;
    newVillage.woodPile = _village.woodPile;
    newVillage.goldPile = _village.goldPile;
    _village = newVillage;
}

- (void)mergeVillageBySwallowing:(Village*)v
{
    _village.woodPile += v.woodPile;
    _village.goldPile += v.goldPile;
    [self upgradeVillage:_village.vType + v.vType];
}

-(void)addStructure:(enum StructureType)sType
{
    switch (sType) {
        case GRASS: {
            Grass* g = [[Grass alloc] initWithTile:self];
            [_structuresSprite addChild:g];
            break;
        }
        case BAUM: {
            Baum* b = [[Baum alloc] initWithTile:self];
            [_structuresSprite addChild:b];
            break;
        }
        case MEADOW: {
            Meadow* m = [[Meadow alloc] initWithTile:self];
            [_structuresSprite addChild:m];
            break;
        }
        case ROAD: {
            Road* r = [[Road alloc] initWithTile:self];
            [_structuresSprite addChild:r atIndex:1];
            break;
        }
        case TOMBSTONE: {
            [self removeAllStructures];
            Tombstone* r = [[Tombstone alloc] initWithTile:self];
            [_structuresSprite addChild:r];
            break;
        }
        default:
            break;
    }
}

- (void)removeStructure
{
    //safety against removing base structure, really this should never happen
    if (_structuresSprite.numChildren==1) return;
    Structure* s = [self getStructure];
    [s removeFromParent];
}

- (void)removeAllStructures
{
    for (Structure* s in _structuresSprite) {
        if (s.sType == GRASS) continue;
        else [s removeFromParent];
    }
}

- (Structure*)getStructure
{
    return (Structure*)[_structuresSprite childAtIndex:_structuresSprite.numChildren-1];
}

- (enum StructureType)getStructureType
{
    Structure* s = [self getStructure];
    return s.sType;
}

- (void)makeNeutral
{
    [self setPColor:NOCOLOR];
    [self removeVillage];
    if ([self hasUnit]) {
        [self removeUnit];
        [self addStructure:TOMBSTONE];
    }
}
//cancels timer
- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)showActionMenu:(NSTimer*)timer
{
    TileTouchedEvent *event = [[TileTouchedEvent alloc] initWithType:EVENT_TYPE_SHOW_ACTION_MENU tile:self];
    [self dispatchEvent:event];
}

- (void)endTurnUpdates
{
    if ([self hasUnit]) [_unit endTurnUpdates];

}

//------------------------------
//  NEIGHBOUR FUNCTIONS
//------------------------------

- (void)setNeighbour:(enum TileNeighbours)tileNeighbour tile: (Tile*)tile
{
    [_neighboursArray insertObject:tile atIndex: tileNeighbour];
}

- (Tile*)getNeighbour:(enum TileNeighbours)tileNeighbour
{
    Tile* t = [_neighboursArray objectAtIndex:tileNeighbour];
    return t;
}

- (NSMutableArray*)getNeighbours
{
    return _neighboursArray;
}

- (NSMutableArray*)getNeighboursOfSameRegion
{
    NSMutableArray* nTiles = [NSMutableArray array];
    for (Tile* nT in _neighboursArray) {
        if (_village.player == nT.village.player) [nTiles addObject:nT];
    }
    return nTiles;
}

- (BOOL)neighboursContainTile:(Tile*)tile
{
    for (Tile* nTile in _neighboursArray) {
        if (tile == nTile) return true;
    }
    return false;
}

-(BOOL)isTraversableForUnitType: (int)unitType
{
    enum StructureType sType = self.getStructureType;
    
    switch (sType) {
        case GRASS:
            return true;
        case BAUM:
        {
            if (unitType == RITTER) return false;
            else return true;
        }
        default:
            break;
    }
    return true;
    
}

- (BOOL)hasVillage
{
    return _village != nil;
}

- (BOOL)isVillage
{
    return _villageSprite.numChildren > 0;
}

- (BOOL)hasUnit
{
    return _unit != nil;
}

- (BOOL)canHaveUnit
{
    if (![self hasUnit] && ![self isVillage]) {
        enum StructureType sType = [self getStructureType];
        if (sType == GRASS || sType == MEADOW || sType == ROAD) return true;
    }
    return false;
}

- (BOOL)canHaveTree
{
    if (![self hasUnit] && ![self isVillage] && [self getStructureType] == GRASS) {
        return true;
    }
    return false;
}

- (BOOL)hasRoad
{
    for (Structure* s in _structuresSprite) {
        if (s.sType == ROAD) return true;
    }
    return false;
}

- (BOOL)hasTombstone
{
    for (Structure* s in _structuresSprite) {
        if (s.sType == TOMBSTONE) return true;
    }
    return false;
}

- (BOOL)canBeSelected
{
    if ([self hasUnit] && _unit.movable) return true;
    if ([self isVillage]) return true;
    return false;
}

- (BOOL)isNeutral
{
    return _village == nil;
}

- (void)setPColor:(enum PlayerColor)pColor
{
    _pColor = pColor;
    [_structuresSprite removeChildAtIndex:0];
    Grass* g = [[Grass alloc] initWithTile:self];
    [_structuresSprite addChild:g atIndex:0];
}

- (void)selectTile
{
    _selectionLayer.alpha = 0.5;
}

- (void)deselectTile
{
    _selectionLayer.alpha = 0.2;
}

- (void)onTouch:(SPTouchEvent*)event
{
    SPTouch *touchBegan = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] anyObject];
    if (touchBegan) {
        if ([self hasUnit] || [self isVillage]) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                      target:self
                                                    selector:@selector(showActionMenu:)
                                                    userInfo:nil
                                                     repeats:NO];
        }
    }
    
    SPTouch *touchEnded = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touchEnded)
    {
        [self invalidateTimer];
        
        TileTouchedEvent *event = [[TileTouchedEvent alloc] initWithType:EVENT_TYPE_TILE_TOUCHED tile:self];
        [self dispatchEvent:event];
    }
    
    SPTouch *touchCancelled = [[event touchesWithTarget:self andPhase:SPTouchPhaseCancelled] anyObject];
    if (touchCancelled)
    {
        [self invalidateTimer];
    }
}

@end
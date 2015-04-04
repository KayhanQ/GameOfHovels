//
//  Map.m
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 10/02/2015.
//
//

#import <Foundation/Foundation.h>
#import "Map.h"
#import "Tile.h"
#import "Peasant.h"
#import "Infantry.h"
#import "Soldier.h"
#import "Ritter.h"
#import "Baum.h"
#import "Tower.h"

#import "Hovel.h"
#import "GamePlayer.h"
#import "Hud.h"
#import "Media.h"
#import "MessageLayer.h"
#import "GameEngine.h"
#import "SparrowHelper.h"
#import "GlobalFlags.h"

@implementation Map {
    MessageLayer* _messageLayer;
    SPJuggler* _gameJuggler;
    float _gridWidth;
    float _gridHeight;
    float _tileWidth;
    float _tileHeight;
    float _offsetHeight;

}

@synthesize tilesSprite = _tilesSprite;
@synthesize messageLayer = _messageLayer;
@synthesize hud = _hud;
@synthesize gameEngine = _gameEngine;


- (id)initWithBasicMap
{
    if (self=[super init]) {
        [self setup];
    }
    return self;
}

- (id)initWithRandomMap
{
    if (self=[super init]) {
        [self setup];
        if ([GlobalFlags isGameWithRandomMap]) {
            [self assignTilesToPlayers];
            [self assignVillagesToRegions];
            [self addTrees];
            [self addMeadows];
        }
    }
    return self;
}

- (void)setup
{
    _messageLayer = [MessageLayer sharedMessageLayer];
    _gameJuggler = [SparrowHelper sharedSparrowHelper].gameJuggler;
    
    _gridWidth = 20;
    _gridHeight = 20;
    _tileWidth = 54;
    _tileHeight = 57;
    _offsetHeight = 40;
    
    
    _tilesSprite = [SPSprite sprite];
    [self addChild:_tilesSprite];
    
    [self makeBasicMap];
    
    [self setNeighbours];
    [self refreshTeritory];
}

- (void)makeBasicMap
{
    for (int j  = 0 ; j<_gridWidth; j++) {
        for (int i  = 0 ; i<_gridHeight; i++) {
            int xOffset = j%2 * _tileWidth/2;
            SPPoint *p = [SPPoint pointWithX:i*_tileWidth+xOffset y:j*_offsetHeight];
            enum StructureType s;
            if (j == 0 || j == _gridWidth-1 || i == 0 || i == _gridHeight-1) s = SEA;
            else s = GRASS;
            Tile *t = [[Tile alloc] initWithPosition:p structure:s];
            [_tilesSprite addChild:t];
        }
    }
    for (Tile* t in _tilesSprite) {
        if ([t getStructureType] == SEA) t.touchable = false;
    }
}

- (void)assignTilesToPlayers
{
    NSMutableArray* colors = [NSMutableArray array];
    [colors addObject:[NSNumber numberWithInt:NOCOLOR]];
    for (GamePlayer* p in _messageLayer.players) {
        [colors addObject:[NSNumber numberWithInt:p.pColor]];
    }
    
    for (Tile* t in _tilesSprite) {
        if ([t getStructureType] == SEA) continue;
        enum PlayerColor color = [[colors objectAtIndex:arc4random() % colors.count] intValue];
        [t setPColor:color];
    }
    
    for (Tile* t in _tilesSprite) {
        if ([t getStructureType] == SEA) continue;
        if ([self getConnectedTilesByColor:t].count<=3) [t makeNeutral];
    }
}

- (void)assignVillagesToRegions
{
    for (Tile* t in _tilesSprite) {
        if ([t getStructureType] == SEA) continue;
        if (t.pColor == NOCOLOR) continue;
        if ([t hasVillage]) continue;
        
        enum PlayerColor tColor = t.pColor;
        GamePlayer* p = _messageLayer.players[tColor-1];
        NSMutableArray* connectedTiles = [self getConnectedTilesByColor:t];
        Tile* vTile = [connectedTiles objectAtIndex:arc4random() % connectedTiles.count];
        [vTile addVillage:HOVEL];
        vTile.village.player = p;
        vTile.village.goldPile = 11;
        vTile.village.woodPile = 100;
        for (Tile* nTile in connectedTiles) nTile.village = vTile.village;
    }
}

-(void)addTrees
{
    for (int j  = 1 ; j<80; j++) {
        int index = arc4random() % [_tilesSprite numChildren];
        Tile* t = (Tile*)[_tilesSprite childAtIndex:index];
        if (t.getStructureType == GRASS && ![t hasUnit] && ![t isVillage]) {
            [t addStructure:BAUM];
        }
    }
}

-(void)addMeadows
{
    for (int j  = 1 ; j<40; j++) {
        int index = arc4random() % [_tilesSprite numChildren];
        Tile* t = (Tile*)[_tilesSprite childAtIndex:index];
        if (t.getStructureType == GRASS && ![t hasUnit] && ![t isVillage]) {
            [t addStructure:MEADOW];
        }
    }
}

//we don't transfer supplies when you attack a village with a Cannon.
- (void)shootCannonFromTile:(Tile*)unitTile tile:(Tile*)destTile
{
    if ([self isMyTurn]) {
        if (destTile.village == unitTile.village) return;
        if ([self distanceFromTile:unitTile toTile:destTile] > 2) return;
        if (unitTile.village.woodPile <= 1) return;
        unitTile.village.woodPile--;
    }
    
    NSMutableArray* nTiles = [destTile getNeighboursOfSameRegion];
    Village* enemyPlayersVillage = destTile.village;
    BOOL areAttackingVillage = [destTile isVillage];
    
    [destTile attackWithCannon];
    
    if (areAttackingVillage) {
        destTile.village = enemyPlayersVillage;
        // the village was destroyed!
        if (![destTile isVillage]) {
            [self takeOverEnemyVillageTileWithNeighbours:nTiles enemyVillage:enemyPlayersVillage];
        }
    }
}

//tells you if the distance is 1 or 2 hex
- (int)distanceFromTile:(Tile*)t1 toTile:(Tile*)t2
{
    for (Tile* n1 in [t1 getNeighbours]) {
        if (n1 == t2) return 1;
        for (Tile* n2 in [n1 getNeighbours]) {
            if (n1 == n2) continue;
            if (n2 == t2) return 2;
        }
    }
    
    return 999;
}

- (void)upgradeVillageWithTile:(Tile*)tile villageType:(enum VillageType)vType
{
    //get the tiles of the old village and set the village to the new one after upgrading
    NSMutableArray* tiles = [self getTilesforVillage:tile.village];
    [tile upgradeVillageTo: vType];
        
    for (Tile* t in tiles) t.village = tile.village;
    
    if ([self isMyTurn]) {
        tile.village.woodPile -= tile.village.cost;
        [self updateHud:tile];
        [_messageLayer sendMoveWithType:UPGRADEVILLAGE tile:tile destTile:nil];
    }
}

- (void)upgradeUnitWithTile:(Tile *)tile unitType:(enum UnitType)uType
{
    //Subtract Gold
    if ([self isMyTurn]) {
        tile.village.goldPile -= tile.unit.upgradeCost;
    }
    [tile upgradeUnit:uType];
}


- (void)refreshTeritory
{
    //tiles have the player colour. Grass is neutral.
    for (Tile* t in _tilesSprite) {
        if ([t hasVillage]) {
            [t setPColor:t.village.player.pColor];
        }
    }
}



- (void)buyUnitFromTile:(Tile*)villageTile tile:(Tile*)destTile unitType:(enum UnitType)uType
{
    BOOL actionPossible = true;
    if ([self isMyTurn]) {
        if (villageTile.village != destTile.village) actionPossible = false;
        if (![destTile canHaveUnit]) actionPossible = false;
        if (uType == CANNON) {
            if (![[villageTile getNeighboursOfSameRegion] containsObject:destTile]) actionPossible = false;
        }
    }
    
    if (actionPossible == false) return;
    
    [destTile addUnitWithType:uType];
    
    if ([self isMyTurn]) {
        villageTile.village.goldPile -= destTile.unit.buyCostGold;
        villageTile.village.goldPile -= destTile.unit.buyCostWood;
        [self updateHud:villageTile];
        //[_messageLayer sendMoveWithType:BUYUNIT tile:villageTile destTile:destTile];
    }
}

- (NSMutableArray*)getMoveTypesForMove:(Tile*)unitTile tile:(Tile*)destTile
{
    NSMutableArray* moveTypes = [NSMutableArray array];
    
    if (destTile.village == unitTile.village) {
        [moveTypes addObject: [NSNumber numberWithInt:TOOWNTILE]];
        if ([destTile hasTower]) [moveTypes addObject: [NSNumber numberWithInt:TOOWNTOWER]];
        if ([destTile isVillage]) [moveTypes addObject: [NSNumber numberWithInt:TOOWNVILLAGE]];
    }
    else {
        if ([destTile hasVillage]) [moveTypes addObject: [NSNumber numberWithInt:TOENEMYTILE]];
        else [moveTypes addObject: [NSNumber numberWithInt:TONEUTRALTILE]];
    }
    if (destTile.village.player == unitTile.village.player && [destTile hasUnit]) [moveTypes addObject: [NSNumber numberWithInt:TOOWNUNIT]];
    if ([self hasVillageMergingPotential:unitTile tile:destTile]) [moveTypes addObject: [NSNumber numberWithInt:MERGEVILLAGES]];
    if ([destTile getStructureType] == BAUM ) [moveTypes addObject: [NSNumber numberWithInt:TOBAUM]];
    if ([destTile getStructureType] == MEADOW ) [moveTypes addObject: [NSNumber numberWithInt:TOMEADOW]];
    if ([destTile getStructureType] == TOMBSTONE ) [moveTypes addObject: [NSNumber numberWithInt:TOTOMBSTONE]];
    if ([destTile getStructureType] == SEA ) [moveTypes addObject: [NSNumber numberWithInt:TOSEA]];

    return moveTypes;
}

- (BOOL)isMovePossible:(Tile*)unitTile tile:(Tile*)destTile moveTypes:(NSMutableArray*)moveTypes
{
    Unit* unit = unitTile.unit;
    
    //Basic checks for game logic
    if (![self isMyTurn]) return false;
    if (!unit.movable) return false;
    if (![unitTile neighboursContainTile:destTile]) return false;
    if (unit.distTravelled == unit.stamina) return false;

    for (NSNumber* n in moveTypes) {
        enum MovesType mType = [n intValue];
        switch (mType) {
            case TOOWNVILLAGE:
            {
                return false;
                break;
            }
            case TOOWNUNIT:
            {
                if (unit.uType + destTile.unit.uType > 5) return false;
                break;
            }
            case TOENEMYTILE:
            {
                
                if (![unit canMoveToEnemyTile:destTile]) return false;
                for (Tile* eTile in [self getTilesForEnemyUnitsProtectingTile:destTile]) {
                    if (eTile.unit.strength >= unit.strength) return false;
                }
                for (Tile* eTile in [self getTilesForVillagesProtectingTile:destTile]) {
                    if (eTile.village.strength >= unit.strength) return false;
                }
                for (Tile* eTile in [self getTilesForTowersProtectingTile:destTile]) {
                    Tower* tower = (Tower*)[eTile getStructure];
                    if (tower.strength >= unit.strength) return false;
                }
                if ([destTile hasTower]) {
                    if (unit.strength <= 2) return false;
                }
                if ([destTile isVillage])
                    if (![destTile.village canBeConqueredByUnit:unit]) return false;
                break;
            }
            case TOBAUM:
            {
                if (![unit canChopBaum]) return false;
                break;
            }
            case TOTOMBSTONE:
            {
                if (![unit canClearTombstone]) return false;
                break;
            }
            case TOOWNTOWER:
            {
                return false;
                break;
            }
            case TOSEA:
            {
                return false;
                break;
            }
            default:
                break;
        }
    }
    
    return true;
}

//completes the move to new tile
- (void)moveUnitWithTile:(Tile*)unitTile tile:(Tile*)destTile
{
    Unit* unit = unitTile.unit;
    NSMutableArray*moveTypes = [self getMoveTypesForMove:unitTile tile:destTile];
    
    if ([self isMyTurn] && ![self isMovePossible:unitTile tile:destTile moveTypes:moveTypes]) {
        NSLog(@"move impossible");
        [Media playSound:@"sound.caf"];
        return;
    }

    //We now have the assurance that simply making the move will not violate any rules.
    BOOL mergingUnits = false;

    for (NSNumber* n in moveTypes) {
        enum MovesType mType = [n intValue];
        switch (mType) {
            case TOBAUM:
            {
                [self chopBaum:destTile];
                break;
            }
            case TOMEADOW:
            {
                if ([unit tramplesMeadow]) {
                    if (![destTile hasRoad]) [destTile removeStructure];
                }
                break;
            }
            case TOTOMBSTONE:
            {
                [destTile removeStructure];
                break;
            }
            case TONEUTRALTILE:
            {
                [self takeOverTile:unitTile tile:destTile];
                break;
            }
            case TOENEMYTILE:
            {
                [self takeOverTile:unitTile tile:destTile];
                break;
            }
            case TOOWNUNIT:
            {
                [self upgradeUnitWithTile:destTile unitType: unit.uType + destTile.unit.uType];
                mergingUnits = true;
                break;
            }
            case MERGEVILLAGES:
            {
                [self mergeVillages:unitTile tile:destTile];
                break;
            }
            default:
                break;
        }
        
    }
    
    unit.distTravelled++;
    //depending on whether we are merging units or not we take different action
    if (mergingUnits) {
        [destTile.unit transferPropertiesFrom:unitTile.unit];
        [unitTile removeUnit];
        destTile.unit.distTravelled = destTile.unit.distTravelled + unit.distTravelled;
    }
    else {
        //the last thing we do is actually move the units on the tile
        [unitTile removeUnit];
        [destTile addUnit:unit];
    }
    
    //need to refresh the colour
    [self refreshTeritory];
    
    if ([self isMyTurn]) {
        [_messageLayer sendMoveWithType:MOVEUNIT tile:unitTile destTile:destTile];
    }
}

- (void)mergeVillages:(Tile*)unitTile tile:(Tile*)destTile
{
    NSMutableArray* mergeTiles = [self getTilesToMergeWith:unitTile tile:destTile];
    for (Tile* mTile in mergeTiles) {
        Village* uVillage = unitTile.village;
        Village* mVillage = mTile.village;

        Tile* unitVillageTile = [self getVillageTile:uVillage];
        Tile* mVillageTile = [self getVillageTile:mVillage];

        
        Village* newUVillage;
        if ([uVillage isHigherThan:mVillage]) {
            [unitVillageTile mergeVillageBySwallowing:mVillage];
            [mVillageTile removeVillage];
            newUVillage = unitVillageTile.village;
            mVillageTile.village = newUVillage;
        }
        else {
            [mVillageTile mergeVillageBySwallowing:uVillage];
            [unitVillageTile removeVillage];
            newUVillage = mVillageTile.village;
            unitVillageTile.village = newUVillage;
        }
        
        for (Tile* t in [self getTilesforVillage:uVillage]) {
            t.village = newUVillage;
        }
        for (Tile* t in [self getTilesforVillage:mVillage]) {
            t.village = newUVillage;
        }
    }
}

- (BOOL)hasVillageMergingPotential:(Tile*)unitTile tile:(Tile*)destTile
{
    Village* uVillage = unitTile.village;
    for (Tile* nTile in [destTile getNeighbours]) {
        if (nTile.village.player != uVillage.player) continue;
        if (nTile.village != uVillage) return true;
    }
    return false;
}

- (NSMutableArray*)getTilesToMergeWith:(Tile*)unitTile tile:(Tile*)destTile
{
    NSMutableArray* mergeTiles = [NSMutableArray array];
    Village* uVillage = unitTile.village;
    for (Tile* nTile in [destTile getNeighbours]) {
        if (nTile.village.player != uVillage.player) continue;
        BOOL tileForVillageHasBeenAdded = false;
        for (Tile* addedTile in mergeTiles) {
            if (addedTile.village == nTile.village) tileForVillageHasBeenAdded = true;
        }
        if (nTile.village != uVillage && !tileForVillageHasBeenAdded) [mergeTiles addObject:nTile];
    }
    return mergeTiles;
}

//This method is very precise. Especially the timing of switching the villages
- (void)takeOverTile:(Tile*)unitTile tile:(Tile*)destTile
{
    BOOL takingOverEnemyTile = [destTile hasVillage];
    BOOL takingOverEnemyVillage = [destTile isVillage];
    
    NSMutableArray* nTiles = [destTile getNeighboursOfSameRegion];
    Village* enemyPlayersVillage = destTile.village;
    
    //if we are taking over a village we have to transfer the supplies and remove it
    if (takingOverEnemyVillage) {
        [unitTile.village transferSuppliesFrom:enemyPlayersVillage];
        [destTile removeVillage];
    }
    if ([destTile hasUnit]) {
        [destTile removeUnit];
    }
    
    //IMPORTANT
    destTile.village = unitTile.village;

    //We are taking over an enemyTile
    if (takingOverEnemyTile) {
        if ([destTile hasUnit]) [destTile removeUnit];
        if ([destTile hasTower]) [destTile removeStructure];
        if ([self tileWithNeighboursSplitsRegion:nTiles]) {
            NSLog(@"TILE SPLITS REGION");
            NSMutableArray* regions = [self getSplitRegions:nTiles];
            NSLog(@"Regions count: %d",regions.count);
            for (NSMutableArray* region in regions) {
                NSLog(@"Tiles count: %d",region.count);
                if ([self regionHasVillage:region]) continue;
                [self convertRegionAfterTileTakenFrom:enemyPlayersVillage region:region];
            }
        }
        else {
            //if we didn't split the region but we did take over a village Tile
            if (takingOverEnemyVillage) {
                [self takeOverEnemyVillageTileWithNeighbours:nTiles enemyVillage:enemyPlayersVillage];
            }
        }
    }
}

- (void)takeOverEnemyVillageTileWithNeighbours:(NSMutableArray*)nTiles enemyVillage:(Village*)eVillage
{
    for (Tile* nT in nTiles) {
        NSMutableArray* region = [self getConnectedTiles:nT];
        [self convertRegionAfterTileTakenFrom:eVillage region:region];
        break;
    }
}

- (void)convertRegionAfterTileTakenFrom:(Village*)enemyPlayersVillage region:(NSMutableArray*)region
{
    if (region.count >= 4) {
        //make new hovel on a random Tile
        Tile* hovelTile = [region objectAtIndex: arc4random() % region.count];
        [hovelTile removeUnit];
        [hovelTile removeAllStructures];
        [hovelTile addVillage:HOVEL];
        hovelTile.village.player = enemyPlayersVillage.player;
        for (Tile* rT in region) rT.village = hovelTile.village;
    }
    else {
        [self makeRegionNeutral:region];
    }
}



//makes a region neutral by removing units and village pointers and towers
- (void)makeRegionNeutral:(NSMutableArray*)region
{
    for (Tile* t in region) [t makeNeutral];
}

- (void)chopBaum:(Tile*)tile
{
    [tile removeStructure];
    if ([self isMyTurn]) {
        tile.village.woodPile++;
        [self updateHud: tile];
    }
}

- (void)buildMeadow:(Tile*)tile
{
    Unit* u = tile.unit;
    if (u.workState == NOWORKSTATE) {
        [u setWorkState:BUILDINGMEADOW];
    }
    else if (u.workState == BUILDINGMEADOW) {
        if (u.workstateCompleted) {
            [tile addStructure:MEADOW];
            [u setWorkState:NOWORKSTATE];
        }
    }
}

- (void)buildRoad:(Tile *)tile
{
    Unit* u = tile.unit;
    if (u.workState == NOWORKSTATE) {
        [u setWorkState:BUILDINGROAD];
    }
    else if (u.workState == BUILDINGROAD) {
        if (u.workstateCompleted) {
            [tile addStructure:ROAD];
            [u setWorkState:NOWORKSTATE];
        }
    }
}

- (void)buildTowerFromTile:(Tile*)villageTile tile:(Tile*)destTile
{
    if ([self isMyTurn]) {
        if (villageTile.village != destTile.village) return;
        if (![destTile canHaveTower]) return;
    }
    
    [destTile addStructure:TOWER];
    
    if ([self isMyTurn]) {
        Tower* tower = (Tower*)[destTile getStructure];
        villageTile.village.woodPile -= tower.buyCostWood;
    }
}

- (void)updateHud:(Tile*)tile
{
    [_hud update:tile];
}

//call your phases
- (void)beginTurnPhases
{
    [self treeGrowthPhase];
    [self tombstonePhase];
    [self incomePhase];
    [self paymentPhase];
    [self buildPhase];
    
    
}
- (void)treeGrowthPhase
{
    NSLog(@"Tree Growth Phase");
    for (Tile* tile in _tilesSprite) {
        Structure* s = [tile getStructure];
        if (s.sType == BAUM) {
            Baum* b = (Baum*)s;
            //only grow near a tree if it not newly grown.
            if (!b.newlyGrown) {
                for (Tile* nTile in [tile getNeighbours]) {
                    if ([nTile canHaveTree]) {
                        int num = arc4random() % 10;
                        if (num==0) [nTile addStructure:BAUM];
                    }
                }
            }
        }
    }
}

//Any tombstones on tiles owned by the player are replaced by trees
- (void)tombstonePhase
{
    for (Tile* vTile in [self getTilesWithMyVillages]) {
        for (Tile* t in [self getTilesforVillage:vTile.village]) {
            if ([t hasTombstone]) {
                [t removeStructure];
                [t addStructure:BAUM];
            }
        }
    }
}



- (void)incomePhase
{
    for (Tile* vTile in [self getTilesWithMyVillages]) {
        for (Tile* t in [self getTilesforVillage:vTile.village]) {
            switch([t getStructureType]){
                case MEADOW:
                {
                    vTile.village.goldPile += 2;
                    break;
                }
                default:
                {
                    vTile.village.goldPile += 1;
                    break;
                }
                    
            }
        }
        [self updateHud:vTile];
    }
}

// also known as upkeep phase
// Money is subtracted from each village’s treasury based on the villagers that it supports. If a village
// has insufficient funds to pay the villagers it supports, all villagers supported by that village perish and
// are replaced by tombstones.
- (void)paymentPhase
{
    for (Tile* vTile in [self getTilesWithMyVillages]) {
        for (Tile* t in [self getTilesforVillage:vTile.village]) {
            if([t hasUnit]) {
                vTile.village.goldPile -= t.unit.upkeepCost;
            }
        }
        vTile.village.goldPile -= vTile.village.upkeepCost;
        
        if (vTile.village.goldPile < 0) {
            vTile.village.goldPile = 0;
            [self killAllVillagers: vTile];
            break;
        }
        [self updateHud:vTile];
    }
}

- (void)killAllVillagers:(Tile*)villageTile;
{
    for (Tile* t in [self getTilesforVillage:villageTile.village]){
        if([t hasUnit]){
            [t removeUnit];
            [t addStructure:TOMBSTONE];
        }
    }
}

- (void)buildPhase
{
    for (Tile* vTile in [self getTilesWithMyVillages]) {
        for (Tile* t in [self getTilesforVillage:vTile.village]) {
            if ([t hasUnit]) {
                if (t.unit.workstateCompleted) {
                    switch (t.unit.workState) {
                        case BUILDINGMEADOW:
                        {
                            [self buildMeadow:t];
                            break;
                        }
                        case BUILDINGROAD:
                        {
                            [self buildRoad:t];
                            break;
                        }
                        default:
                            break;
                    }
                }
            }
        }
    }
}

- (void)endTurnUpdates
{
    //update the trees
    for (Tile* tile in _tilesSprite) {
        Structure* s = [tile getStructure];
        if (s.sType == BAUM) {
            Baum* b = (Baum*)s;
            b.newlyGrown = false;
        }
    }
    
    //We go through ever single tile we own and do all updates
    for (Tile* vTile in [self getTilesWithMyVillages]) {
        for (Tile* t in [self getTilesforVillage:vTile.village]) {
            [t endTurnUpdates];
        }
    }
}


//--------------------------
//  Helper Functions
//--------------------------

- (void)setNeighbours
{
    for (int j  = 1 ; j<_gridWidth - 1; j++) {
        for (int i  = 1 ; i<_gridHeight - 1; i++) {
            int tIndex = i + j*_gridWidth;
            
            Tile* t = (Tile*)[_tilesSprite childAtIndex:tIndex];
            for (int k = 0; k<6; k++) {
                int nIndex = 0;
                if (k == 0) nIndex = tIndex - _gridWidth;
                else if (k == 1) nIndex = tIndex + 1;
                else if (k == 2) nIndex = tIndex + _gridWidth;
                else if (k == 3) nIndex = tIndex + _gridWidth-1;
                else if (k == 4) nIndex = tIndex - 1;
                else if (k == 5) nIndex = tIndex - _gridWidth - 1;
                
                if (j%2 == 1 && k!=1 && k!=4) nIndex++;
                
                [t setNeighbour:k tile:(Tile*)[_tilesSprite childAtIndex:nIndex]];
            }
        }
    }
}

//How is current player represented
- (NSMutableArray*)getTilesWithMyVillages
{
    NSMutableArray* tiles = [NSMutableArray array];
    for (Tile* t in _tilesSprite) {
        if ([t isVillage] && t.village.player == [_messageLayer getCurrentPlayer]) {
            [tiles addObject:t];
        }
    }
    return tiles;
}

- (NSMutableArray*)getTilesforVillage:(Village*)v
{
    NSMutableArray* tiles = [NSMutableArray array];
    for (Tile*t in _tilesSprite) {
        if (t.village == v) [tiles addObject:t];
    }
    return tiles;
}

- (Tile*)getVillageTile:(Village*)v
{
    for (Tile* t in [self getTilesforVillage:v]) {
        if ([t isVillage]) return t;
    }
    return nil;
}

//Right now we just check 1 hex distance, we will have to change this for cannons!
- (NSMutableArray*)getTilesForEnemyUnitsProtectingTile:(Tile*)tile
{
    NSMutableArray* eUnitTiles = [NSMutableArray array];
    GamePlayer* ePlayer = tile.village.player;
    for (Tile* nTile in [tile getNeighbours]) {
        if (nTile.village.player == ePlayer) {
            if ([nTile hasUnit]) {
                [eUnitTiles addObject:nTile];
            }
        }
    }
    return eUnitTiles;
}

//returns the enemy Villages that protect a tile
- (NSMutableArray*)getTilesForVillagesProtectingTile:(Tile*)tile
{
    NSMutableArray* vUnitTiles = [NSMutableArray array];
    GamePlayer* ePlayer = tile.village.player;
    for (Tile* nTile in [tile getNeighbours]) {
        if (nTile.village.player == ePlayer) {
            if ([nTile isVillage]) {
                if ([nTile.village protectsRegion]) [vUnitTiles addObject:nTile];
            }
        }
    }
    return vUnitTiles;
}

//returns the enemy Towers that protect a tile, 1 hex
- (NSMutableArray*)getTilesForTowersProtectingTile:(Tile*)tile
{
    NSMutableArray* towerTiles = [NSMutableArray array];
    GamePlayer* ePlayer = tile.village.player;
    for (Tile* nTile in [tile getNeighbours]) {
        if (nTile.village.player == ePlayer) {
            if ([nTile hasTower]) {
                [towerTiles addObject:nTile];
            }
        }
    }
    return towerTiles;
}

//We have already set the village of the tile we are splitting on as the new village
//so we have to send in his neighbours instead of him
- (BOOL)tileWithNeighboursSplitsRegion:(NSMutableArray*)nTiles
{
    for (Tile* nT1 in nTiles) {
        for (Tile* nT2 in nTiles) {
            if (nT1 == nT2) continue;
            if (![self areConnectedByRegion:nT1 t2:nT2]) return true;
        }
    }
    return false;
}

- (BOOL)areConnectedByRegion:(Tile*)t1 t2:(Tile*)t2
{
    NSMutableArray* searchTiles = [NSMutableArray array];
    [searchTiles addObject:t1];
    
    for (int i = 0; i < searchTiles.count; i++) {
        Tile* sTile = [searchTiles objectAtIndex:i];
        sTile.visitedBySearch = true;
        for (Tile* nTile in [sTile getNeighboursOfSameRegion]) {
            if (nTile.visitedBySearch) continue;
            if (nTile == t2) {
                [self resetVisitedBySearchFlags];
                return true;
            }
            [searchTiles addObject:nTile];
        }
    }
    [self resetVisitedBySearchFlags];
    return false;
}

- (NSMutableArray*)getSplitRegions:(NSMutableArray*)nTiles
{
    NSMutableArray* disconnectedNeighbours = [NSMutableArray array];
    
    for (Tile* nT1 in nTiles) {
        for (Tile* nT2 in nTiles) {
            if (nT1 == nT2) continue;
            if (![self areConnectedByRegion:nT1 t2:nT2]) {
                if (![disconnectedNeighbours containsObject:nT1]) [disconnectedNeighbours addObject:nT1];
                if (![disconnectedNeighbours containsObject:nT2]) [disconnectedNeighbours addObject:nT2];
            }
        }
    }
    
    //remove any tiles that are connected to each other
    for (int i = 0; i < disconnectedNeighbours.count; i++) {
        Tile* t1 = [disconnectedNeighbours objectAtIndex:i];
        for (int j = 0; j < disconnectedNeighbours.count; j++) {
            Tile* t2 = [disconnectedNeighbours objectAtIndex:j];
            if (t1 == t2) continue;
            if ([self areConnectedByRegion:t1 t2:t2]) {
                [disconnectedNeighbours removeObject:t2];
                continue;
            }
        }
    }
    
    NSMutableArray* regions = [NSMutableArray array];
    for (Tile* dN in disconnectedNeighbours) {
        [regions addObject:[self getConnectedTiles:dN]];
    }
    
    return regions;
}

//returns list of all connected tiles in same region by Villages
- (NSMutableArray*)getConnectedTiles:(Tile*)tile
{
    NSMutableArray* searchTiles = [NSMutableArray array];
    [searchTiles addObject:tile];
    
    for (int i = 0; i < searchTiles.count; i++) {
        Tile* sTile = [searchTiles objectAtIndex:i];
        sTile.visitedBySearch = true;
        for (Tile* nTile in [sTile getNeighboursOfSameRegion]) {
            if (nTile.visitedBySearch) continue;
            nTile.visitedBySearch = true;
            [searchTiles addObject:nTile];
        }
    }
    [self resetVisitedBySearchFlags];
    return searchTiles;
}

//returns list of all connected tiles in same region by their color
- (NSMutableArray*)getConnectedTilesByColor:(Tile*)tile
{
    NSMutableArray* searchTiles = [NSMutableArray array];
    [searchTiles addObject:tile];
    
    for (int i = 0; i < searchTiles.count; i++) {
        Tile* sTile = [searchTiles objectAtIndex:i];
        sTile.visitedBySearch = true;
        for (Tile* nTile in [sTile getNeighboursOfSameColor]) {
            if (nTile.visitedBySearch) continue;
            nTile.visitedBySearch = true;
            [searchTiles addObject:nTile];
        }
    }
    [self resetVisitedBySearchFlags];
    return searchTiles;
}


- (BOOL)regionHasVillage:(NSMutableArray*)region
{
    for (Tile* t in region) {
        if ([t isVillage]) return true;
    }
    return false;
}


- (void)resetVisitedBySearchFlags
{
    for (Tile* t in _tilesSprite)
    {
        t.visitedBySearch = false;
    }
}

- (BOOL)isMyTurn
{
    return _gameEngine.currentPlayer == _gameEngine.mePlayer;
}

@end
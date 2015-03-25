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
#import "Unit.h"
#import "Peasant.h"
#import "Infantry.h"
#import "Soldier.h"
#import "Ritter.h"
#import "Baum.h"
#import "Hovel.h"
#import "GamePlayer.h"
#import "Hud.h"
#import "Media.h"
#import "MessageLayer.h"
#import "GameEngine.h"
#import "DKStack.h"
#import "DKQueue.h"

@implementation Map {
    MessageLayer* _messageLayer;
    
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


-(id)initWithRandomMap:(Hud *)hud
{
    if (self=[super init]) {
		
		_messageLayer = [MessageLayer sharedMessageLayer];
        
        //currently we are not using the array players and game Engine is updating us with the current player
        
        _gridWidth = 20;
        _gridHeight = 20;
        _tileWidth = 54;
        _tileHeight = 57;
        _offsetHeight = 40;

        _hud = hud;

        
        _tilesSprite = [SPSprite sprite];
        [self addChild:_tilesSprite];
        
        [self makeBasicMap];
        
        [self createRandomMap: _messageLayer.players];
        
        [self setNeighbours];
        
        [self initializePlayerLocations];
        
        //[self makePlayer1Tiles: _messageLayer.players[0]];
        //[self makePlayer2Tiles: _messageLayer.players[1]];

        [self addTrees];
        [self addMeadows];
   //     [self makeTreesAndMeadows];
		
        [self showPlayersTeritory];
        
    }
    return self;
}

- (void)makeBasicMap
{
    for (int j  = 0 ; j<_gridWidth; j++) {
        for (int i  = 0 ; i<_gridHeight; i++) {
            int xOffset = j%2 * _tileWidth/2;
            SPPoint *p = [SPPoint pointWithX:i*_tileWidth+xOffset y:j*_offsetHeight];
            
            
            //if( ((j > 0) && (j < _gridWidth-1)) && ((i > 0) && (i <_gridHeight-1)) ){
                Tile* t = [[Tile alloc] initWithPosition:p structure:GRASS];
                [_tilesSprite addChild:t];
            //}
            
          
            /* SEA TILES
            else{
                Tile *r = [[Tile alloc] initWithPosition:p structure:ROAD]; // Currently doesn't work
                [_tilesSprite addChild:r];

                
                
                //[r setVisited:YES];
            }
            */
            
            /*
             'NSRangeException', reason: '*** -[__NSArrayM objectAtIndex:]: index 4294967295 beyond bounds for empty array
             */
        

        }
    }
}

- (void)createRandomMap:(NSMutableArray*)players
{
    
    for (Tile* t in _tilesSprite) {
        
        int randomColor = arc4random_uniform([players count] + 1);
        
        if(t.getStructureType != ROAD){
            switch (randomColor) {
                case 0:
                {
                    //NSLog(@"Neutral Tile assigned a colour");
                    [t setPColor:NOCOLOR]; //set it to player1s color
                    [t setVisited:YES];
                    break;
                }
                case 1:
                {
                    //NSLog(@"Player1 Tile assigned a colour");
                    [t setPColor: BLUE];
                    break;
                }
                case 2:
                {
                    // NSLog(@"Player2 Tile assigned a colour");
                    [t setPColor: RED];
                    break;
                    
                }
                    
                    //can accomodate more players if Needed
                default:
                    NSLog(@"More players than we can account for");
                    break;
            }
        }
    }
}


- (void)initializePlayerLocations //going to do a basic dfs on each of the tiles.
{ // I NEED BREADTH FIRST SEARCH. A DOY!
    /*
     1  procedure BFS(G,v) is
     2      let Q be a queue
     3      Q.push(v)
     4      label v as discovered
     5      while Q is not empty
     6         v ← Q.pop()
     7         for all edges from v to w in G.adjacentEdges(v) do
     8             if w is not labeled as discovered
     9                 Q.push(w)
     10                label w as discovered
     */
    
    
    Tile* currentTile;
    DKQueue* queue = [[DKQueue alloc] init];
    int currentColor;// =0;
    NSMutableArray* connectedTiles = [[NSMutableArray alloc] init];
    NSMutableArray* tileNeighbours= [[NSMutableArray alloc] init];
    
    
    for (__strong Tile* t in _tilesSprite) {
    
        currentTile = t;
        currentColor = [currentTile getPColor];
        
        //[queue enqueue:t];
        [queue enqueue:currentTile];
        
        [currentTile setVisited: YES];
        [connectedTiles addObject:currentTile];
        
        while(![queue isEmpty]){
            
            currentTile = [queue dequeue];
           
            //[connectedTiles addObject:currentTile ];
            
            
            tileNeighbours = [currentTile getNeighbours];
            
            for(Tile *neighbour in tileNeighbours){
                
                if([neighbour getVisited] != YES && [neighbour pColor] == currentColor ){
                    
                    //[connectedTiles addObject:currentTile ];
                    
                    [queue enqueue: neighbour];
                    [neighbour setVisited:YES];
                    [connectedTiles addObject:neighbour];
                    
                    
                }
                
            }
            
            
            
        }
        
        //adding hovels goes here I think.
       
       
        for(Tile* tile in connectedTiles){
            // [tile setPColor:NOCOLOR];
            //[tile setPColor: currentColor];
            [tile setConnectedArray:connectedTiles];
            
            //[tile setVisited: YES]
        }
        
        
        [currentTile setConnected:[connectedTiles count]];
        
        if([connectedTiles count] < 3){
            
            for(Tile* tile in connectedTiles){
                       // [tile setPColor:NOCOLOR];
                //[tile setVisited: YES]
            }
            
            //   [connectedTiles removeAllObjects];
            
        }
        
        else {
            for(Tile* tile in connectedTiles){
                // [tile setPColor:NOCOLOR];
                [tile setPColor: currentColor];
                [tile setConnectedArray:connectedTiles];
                
                //[tile setVisited: YES]
            }

            
            
            //for(Tile* tile in connectedTiles){
            
            //  [tile setPColor: currentColor];
            
            //[tile setVisited: YES];
            
            //}
            
            /*
             
             if(currentColor != NOCOLOR){ //problem is it does this for all. Get out of the loop.
             
             Tile* s = [connectedTiles objectAtIndex:(arc4random_uniform([connectedTiles count]))];
             [s addVillage:HOVEL];
             
             Tile* villageTile = s;
             
             
             s.village.player = _messageLayer.players[currentColor-1]; //get player from colour
             [s setPColor: currentColor];
             
             s.village = villageTile.village;
             [s setPColor: villageTile.village.player.pColor];
             
             
             
             }
             */
            
        }
        [connectedTiles removeAllObjects];

        
        
    }
    
    
    
    
}




- (void)makeTreesAndMeadows //What the hell is this???
{
	NSInteger treesData[80] = {1, 2, 19, 26, 33, 35, 37, 50, 51, 57, 63, 72, 74, 78, 83, 84, 92, 99, 105, 110, 116, 119, 120, 142, 143, 146, 148, 149, 164, 186, 191, 193, 196, 201, 207, 208, 211, 213, 216, 222, 225, 228, 234, 238, 240, 252, 257, 265, 274, 280, 281, 283, 289, 294, 298, 322, 326, 333, 334, 335, 336, 338, 340, 348, 350, 358, 359, 366, 375, 377, 380, 383, 394, 395, 396};
	NSInteger meadowsData[40] = {8, 14, 25, 36, 65, 69, 79, 96, 103, 109, 144, 145, 155, 176, 182, 192, 195, 206, 219, 220, 229, 248, 271, 287, 304, 324, 325, 327, 361, 363, 371, 393, 397};
	
	for (Tile* t in _tilesSprite) {
	int tileIndex = [_tilesSprite childIndex: t];
		for (int i = 0; i<80; i++) {
			if (tileIndex == treesData[i]) {
				if (t.getStructureType == GRASS && t.unit==nil && !t.isVillage) {
					[t addStructure:BAUM];
				}
			}
		}
		for (int i = 0; i<40; i++) {
			if (tileIndex == meadowsData[i]) {
				if (t.getStructureType == GRASS && t.unit==nil && !t.isVillage) {
					[t addStructure:MEADOW];
				}
			}
		}
	}
}

- (void)makePlayer1Tiles:(GamePlayer*)player1
{
    Tile* villageTile;
    int i = 0;
    int j = 0;
    
    for (Tile* t in _tilesSprite) {
        if (j == 10 && i == 10) {
            [t addVillage:HOVEL];
            villageTile = t;
            t.village.player = player1;
        }
        
        if (j>9 && j<13) {
            if (i<15 && i>9) {
                t.village = villageTile.village;
                [t setPColor: villageTile.village.player.pColor];
                if (j == 12 && i == 10) {
                    [t addUnitWithType:PEASANT];
                }
            }
        }

        i++;
        if (i == _gridWidth) {
            i=0;
            j++;
        }
    }
    
    i=0;
    j=0;
    for (Tile* t in _tilesSprite) {
        if (j == 10 && i == 6) {
            [t addVillage:HOVEL];
            villageTile = t;
            t.village.player = player1;
        }
        
        if (j>9 && j<13) {
            if (i<8 && i>6) {
                t.village = villageTile.village;
                [t setPColor: villageTile.village.player.pColor];
            }
        }
        
        i++;
        if (i == _gridWidth) {
            i=0;
            j++;
        }
    }
    
}

- (void)makePlayer2Tiles:(GamePlayer*)player2
{
    Tile* villageTile;
    int i = 0;
    int j = 0;
    
    for (Tile* t in _tilesSprite) {
        
        if (j == 4 && i == 5) {
            [t addVillage:HOVEL];
            villageTile = t;
            t.village.player = player2;
        }
        
        if (j>3 && j<7) {
            if (i<10 && i>4) {
                t.village = villageTile.village;
                [t setPColor:villageTile.village.player.pColor];
                if (j == 12 && i == 10) {
                    [t addUnitWithType:PEASANT];
                }
            }
        }
        i++;
        if (i == _gridWidth) {
            i=0;
            j++;
        }
    }
}

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

-(void)addTrees
{
    float treePercentage = 0.2f;
    int numTrees = treePercentage*(_gridWidth * _gridHeight);
    
    for (int j  = 1 ; j<numTrees; j++) {
        int index = arc4random() % [_tilesSprite numChildren];
        Tile* t = (Tile*)[_tilesSprite childAtIndex:index];
        if (t.getStructureType == GRASS && t.unit==nil && !t.isVillage) {
            [t addStructure:BAUM];
        }
    }
}

-(void)addMeadows
{
    
    float meadowPercentage = 0.1f;
    int numMeadows = meadowPercentage*(_gridWidth * _gridHeight);
    
    for (int j  = 1 ; j<numMeadows; j++) {
        int index = arc4random() % [_tilesSprite numChildren];
        Tile* t = (Tile*)[_tilesSprite childAtIndex:index];
        if (t.getStructureType == GRASS && t.unit==nil && !t.isVillage) {
            [t addStructure:MEADOW];
        }
    }
}



- (void)upgradeVillageWithTile:(Tile*)tile
{
    BOOL actionPossible = true;
    
    Village* tileVillage = tile.village;
    
    if ([self isMyTurn]) {
        if (tileVillage.woodPile<8) actionPossible = false;
    }
    
    if (actionPossible == false) {
        return;
    }
    
    //get the tiles of the old village and set the village to the new one after upgrading
    NSMutableArray* tiles = [self getTilesforVillage:tile];
    [tile upgradeVillage];
    for (Tile* t in tiles) {
        t.village = tileVillage;
    }
    
    if ([self isMyTurn]) {
        tileVillage.woodPile -= 8;
        [self updateHud:tile];
        [_messageLayer sendMoveWithType:UPGRADEVILLAGE tile:tile destTile:nil];
    }
}

- (void)upgradeUnitWithTile:(Tile *)tile
{
    [tile upgradeUnit:SOLDIER];
}


- (void)showPlayersTeritory
{
    //tiles have the player colour. Grass is neutral.
    
    //use sharedMessage LAyer to access certain things
    
    //throw it 
    
    for (Tile* t in _tilesSprite) {
        if ([t hasVillage]) {
            [t setPColor:t.village.player.pColor];
        }
    }
}



- (void)buyUnitFromTile:(Tile*)villageTile tile:(Tile*)destTile
{
    BOOL actionPossible = true;
    if ([self isMyTurn]) {
        if (villageTile.village != destTile.village) actionPossible = false;
        if (![destTile canHaveUnit]) actionPossible = false;
    }
    
    if (actionPossible == false) return;
    
    [destTile addUnitWithType:PEASANT];
    
    if ([self isMyTurn]) {
        villageTile.village.goldPile-=10;
        [self updateHud:villageTile];
        [_messageLayer sendMoveWithType:BUYUNIT tile:villageTile destTile:destTile];
    }
}

//completes the move to new tile
- (void)moveUnitWithTile:(Tile*)unitTile tile:(Tile*)destTile
{
    Unit* unit = unitTile.unit;
    
    BOOL movePossible = true;
    if ([self isMyTurn]) {
        if (!unit.movable) {
            movePossible = false;
        }
        if ([unitTile neighboursContainTile:destTile] == false) {
            movePossible = false;
        }
        if (destTile.getStructureType == BAUM && unit.uType == RITTER) movePossible = false;
        if (destTile.isVillage) movePossible = false;
        if (unit.distTravelled == unit.stamina) {
            movePossible = false;
        }
        
        if (unitTile.village != destTile.village) {
            [self takeOverTile:unitTile tile:destTile];
            //movePossible = false;
        }
    }
    
    if (!movePossible) {
        NSLog(@"move impossible");
        [Media playSound:@"sound.caf"];
        return;
    }
    
    //if the move is possible we continue here
    
    if (destTile.getStructureType == BAUM) {
        [self chopTree:destTile];
    }

    
    //the last thing we do is actually move the units on the tile
    [unitTile removeUnit];
    [destTile addUnit:unit];
    unit.distTravelled++;
    
    //need to refresh the colour, where should this actually be done?
    [self showPlayersTeritory];
    
    if ([self isMyTurn]) {
        [_messageLayer sendMoveWithType:MOVEUNIT tile:unitTile destTile:destTile];
    }
}

- (void)takeOverTile:(Tile*)unitTile tile:(Tile*)destTile
{
    destTile.village = unitTile.village;
    
}

- (void)chopTree:(Tile*)tile
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

- (void)updateHud:(Tile*)tile
{
    [_hud update:tile];
}

- (void)createRandomMap
{
    
}

//call your phases
- (void)beginTurnPhases
{
    [self treeGrowthPhase];
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

- (void)tombstonePhase
{
    
}

- (void)incomePhase
{
    
}

//also known as upkeep phase
- (void)paymentPhase
{
    
}

- (void)buildPhase
{
    for (Tile* vTile in [self getTilesWithMyVillages]) {
        for (Tile* t in [self getTilesforVillage:vTile]) {
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
        for (Tile* t in [self getTilesforVillage:vTile]) {
            if ([t hasUnit]) {
                [t.unit incrementWorkstate];
            }
        }
    }
}


//--------------------------
//  Helper Functions
//--------------------------

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

- (NSMutableArray*)getTilesforVillage:(Tile*)tile
{
    NSMutableArray* tiles = [NSMutableArray array];
    Village* v = tile.village;
    
    for (Tile*t in _tilesSprite) {
        if (t.village == v) [tiles addObject:t];
    }
    
    return tiles;
}


- (BOOL)isMyTurn
{
    return _gameEngine.currentPlayer == _gameEngine.mePlayer;
}



@end
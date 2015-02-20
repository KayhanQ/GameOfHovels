//
//  GameEngine.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "GameEngine.h"
#import "Tile.h"
#import "Map.h"
#import "TileTouchedEvent.h"
#import "ActionMenu.h"
#import "UnitEventMoveIntent.h"
#import "Ritter.h"
#import "Baum.h"
#import "GamePlayer.h"
#import "Hud.h"
#import "Media.h"
#import "GHEvent.h"



@implementation GameEngine
{
    Map* _map;
    
    ActionMenu* _actionMenu;
    SPSprite* _contents;
    Hud* _hud;
    SPSprite* _popupMenuSprite;
    
    Tile* _selectedTile;
    BOOL _unitActionIntent;
    
    GamePlayer* _currentPlayer;
    
    
    NSMutableArray* _players;
    SPJuggler* _animationJuggler;
}

- (id)init
{
    if ((self = [super init]))
    {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    // release any resources here
    [Media releaseAtlas];
    [Media releaseSound];
}

- (void)setup
{
    //init Players
    //this will actually happen outside Game Engine
    GamePlayer* player1 = [[GamePlayer alloc] initWithString:@"player1" color:0xfa3211];
    _players = [NSMutableArray array];
    [_players addObject:player1];
    
    _currentPlayer = player1;
    
    _contents = [SPSprite sprite];
    [self addChild:_contents];
    
    _world = [SPSprite sprite];
    [_contents addChild:_world];
    
    _hud = [[Hud alloc] initWithPlayer:_currentPlayer];
    [_contents addChild:_hud];
    
    
    SPQuad* q = [SPQuad quadWithWidth:Sparrow.stage.width*4 height:Sparrow.stage.height*4];
    q.x = -q.width/2;
    q.y = -q.height/2;
    q.color = 0xffffff;
    [_world addChild:q];
    
    
    _map = [[Map alloc] initWithRandomMap:_players hud:_hud];
    [_world addChild:_map];
    
    _popupMenuSprite = [SPSprite sprite];
    [_world addChild:_popupMenuSprite];
    
    


    
    
    
    
    //event Listeners
    [self addEventListener:@selector(tileTouched:) atObject:self forType:EVENT_TYPE_TILE_TOUCHED];
    [self addEventListener:@selector(villageUpgradeIntent:) atObject:self forType:EVENT_TYPE_VILLAGE_UPGRADE_INTENT];
    [self addEventListener:@selector(upgradeUnit:) atObject:self forType:EVENT_TYPE_UPGRADE_UNIT];
    [self addEventListener:@selector(upgradeVillage:) atObject:self forType:EVENT_TYPE_UPGRADE_VILLAGE];
    [self addEventListener:@selector(endTurn:) atObject:self forType:EVENT_TYPE_TURN_ENDED];

    
    //reimplement scrolling
    [_world addEventListener:@selector(onMapTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    [self addEventListener:@selector(onEnterFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    
    _animationJuggler = [SPJuggler juggler];
    [self addEventListener:@selector(animateJugglers:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    
    _unitActionIntent = false;
    _touching = NO;
    _lastScrollDist = 0;
    _scrollVector = [SPPoint pointWithX:0 y:0];
    
    

    [SPAudioEngine start];  // starts up the sound engine
    [Media initAtlas];      // loads your texture atlas -> see Media.h/Media.m
    [Media initSound];      // loads all your sounds    -> see Media.h/Media.m
    [self addEventListener:@selector(onResize:) atObject:self forType:SP_EVENT_TYPE_RESIZE];
    
    [self beginTurnWithPlayer:_currentPlayer];
    
    
}


- (void)beginTurnWithPlayer:(GamePlayer*)player;
{
    _currentPlayer = player;
    [_map updateHud];
    _map.currentPlayer = _currentPlayer;
    [_map treeGrowthPhase];
    
    //player can now make inputs again
    _map.touchable = true;
    
}

- (void)endTurn:(GHEvent*)event
{
    _map.touchable = false;
    
    [_map endTurnUpdates];
    
    //relay turn has ended
    //Begin Turn will get called again
    //Now we just simulate it by giving our player another turn
    [self beginTurnWithPlayer:_currentPlayer];
}

- (void)upgradeUnit:(TileTouchedEvent*) event
{
    NSLog(@"unit upgraded");
}

- (void)upgradeVillage:(TileTouchedEvent*) event
{
    NSLog(@"Upgrade Village");
    Tile* tile = event.tile;
    [_map upgradeVillageWithTile:tile];
}

//upgrade from hovel to town etc.
- (void)villageUpgradeIntent:(TileTouchedEvent*) event
{
    /*
    [_actionMenu removeFromParent];
    NSLog(@"village upgrade intent");
    Tile* tile = event.tile;
    [_map upgradeVillageWithTile:tile];
     */
}


- (void)tileTouched:(TileTouchedEvent*) event
{
    Tile* tile = event.tile;
    
    
    if (_selectedTile == nil && [tile canBeSelected]) {
        [self selectTile:tile];
    }
    else {
        Tile* destTile = tile;
        Unit* unit = _selectedTile.unit;

        //perform Unit actions
        if (unit != nil) {
            NSLog(@"Perform Unit action");
            if (tile == _selectedTile) {
                [self buildMeadow:tile];
            }
            else {
                [self moveUnitWithTile:_selectedTile tile:destTile];
            }
        }
        else if (_selectedTile.isVillage) {
            [_map buyUnitFromTile:_selectedTile tile:destTile];
        }
        
        [self deselectTile:_selectedTile];
    }
    
    
}



- (void)selectTile:(Tile*)tile
{
    _selectedTile = tile;
    [tile selectTile];
}

- (void)deselectTile:(Tile*)tile
{
    _selectedTile = nil;
    [tile deselectTile];
}

- (void)buildMeadow:(Tile*)tile
{
    [tile addStructure:MEADOW];
    [self deselectTile:tile];
    NSLog(@"build Meadow");
    
}

//comletes the move to new tile
- (void)moveUnitWithTile:(Tile*)unitTile tile:(Tile*)destTile
{
    
    Unit* unit = unitTile.unit;
    
    BOOL movePossible = true;
    if (unit.movesCompleted) {
        movePossible = false;
    }
    if ([unitTile neighboursContainTile:destTile] == false) {
        movePossible = false;
    }
    //if (destTile.getStructureType == BAUM && u.uType == RITTER) movePossible = false;
    if (destTile.isVillage) movePossible = false;
    if (unit.distTravelled == unit.stamina) {
        movePossible = false;
    }
    if (!movePossible) {
        NSLog(@"move impossible");
        [Media playSound:@"sound.caf"];
        return;
    }
    
    //if the move is possible we continue here
    
    if (destTile.getStructureType == BAUM) {
        [_map chopTree:destTile];
    }
    if (unitTile.village != destTile.village) {
        [self takeOverTile:unitTile tile:destTile];
    }
    
    //the last thing we do is update the coordinates and reset the selected unit's Tile
    unit.x = destTile.x;
    unit.y = destTile.y;
    unitTile.unit = nil;
    destTile.unit = unit;
    
    unit.distTravelled++;
    
    //need to refresh the colour, where should this actually be done?
    [_map showPlayersTeritory];
}

- (void)takeOverTile:(Tile*)unitTile tile:(Tile*)destTile
{
    destTile.village = unitTile.village;
    
}


- (void)onResize:(SPResizeEvent *)event
{
    NSLog(@"new size: %.0fx%.0f (%@)", event.width, event.height,
          event.isPortrait ? @"portrait" : @"landscape");
}


- (void)animateJugglers:(SPEnterFrameEvent *)event
{
    double passedTime = event.passedTime;
    [_animationJuggler advanceTime:passedTime];
}

@end
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
#import "Ritter.h"
#import "Baum.h"
#import "GamePlayer.h"
#import "Hud.h"
#import "Media.h"
#import "GHEvent.h"
#import "ActionMenuEvent.h"
#import "MessageLayer.h"
#import "SparrowHelper.h"
#import "GlobalFlags.h"
#import "CurrentPlayerAction.h"


@implementation GameEngine
{
    Map* _map;
    
    ActionMenu* _actionMenu;
    SPSprite* _contents;
    Hud* _hud;
    MessageLayer* _messageLayer;
    
    SPSprite* _popupMenuSprite;
    
    NSMutableArray* _players;
    SPJuggler* _gameJuggler;
    
    CurrentPlayerAction* _currentPlayerAction;
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
    
    _touching = NO;
    _lastScrollDist = 0;
    _scrollVector = [SPPoint pointWithX:0 y:0];
    
    _currentPlayerAction = [[CurrentPlayerAction alloc] init];
    
    //if you want access ot the global game juggler here is how
    _gameJuggler = [SparrowHelper sharedSparrowHelper].gameJuggler;
    //game engine handles animating it and pausing etc
    [self addEventListener:@selector(animateJugglers:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    
    
    [SPAudioEngine start];  // starts up the sound engine
    [Media initAtlas];      // loads your texture atlas -> see Media.h/Media.m
    [Media initSound];      // loads all your sounds    -> see Media.h/Media.m
    [self addEventListener:@selector(onResize:) atObject:self forType:SP_EVENT_TYPE_RESIZE];
    
    
    //Create the Message Layer
    _messageLayer = [MessageLayer sharedMessageLayer];
    
    //we check if we are using GC networking
    //if not we can manually create our own setup
    if ([GlobalFlags isGameWithGC]) {
        
    }
    else {
        [_messageLayer makePlayers];
        _currentPlayer = [_messageLayer getCurrentPlayer];
        _mePlayer = _currentPlayer;
    }

    
    _contents = [SPSprite sprite];
    [self addChild:_contents];
    
    _world = [SPSprite sprite];
    [_contents addChild:_world];
    
    SPQuad* q = [SPQuad quadWithWidth:Sparrow.stage.width*8 height:Sparrow.stage.height*8];
    q.x = -q.width/2;
    q.y = -q.height/2;
    q.color = 0xB3E8F2;
    [_world addChild:q];
    
    _hud = [[Hud alloc] initWithMap:_map];
    [_contents addChild:_hud];
    
    _map = [[Map alloc] initWithRandomMap];
	_map.gameEngine = self;
    _map.hud = _hud;
    [_world addChild:_map];
    
    
    _popupMenuSprite = [SPSprite sprite];
    [_world addChild:_popupMenuSprite];
    
    //event Listeners
    [self addEventListener:@selector(tileTouched:) atObject:self forType:EVENT_TYPE_TILE_TOUCHED];
    [self addEventListener:@selector(showActionMenu:) atObject:self forType:EVENT_TYPE_SHOW_ACTION_MENU];
    [self addEventListener:@selector(actionMenuAction:) atObject:self forType:EVENT_TYPE_ACTION_MENU_ACTION];
    [self addEventListener:@selector(endTurn:) atObject:self forType:EVENT_TYPE_TURN_ENDED];

    [self enableScroll];

    

    
    [self beginTurnWithPlayer:_currentPlayer];
	[MessageLayer sharedMessageLayer].gameEngine = self;
}


- (void)beginTurnWithPlayer:(GamePlayer*)player;
{
    [_map beginTurnPhases];
    //player can now make inputs again
    _map.touchable = true;
    
}

//This method is important. Change stuff in it depending on what you want to do
- (void)endTurn:(GHEvent*)event
{
    _map.touchable = false;
    _currentPlayerAction.selectedTile = nil;
    [_map endTurnUpdates];
    
    //We rebegin our turn
    [self beginTurnWithPlayer:_currentPlayer];
    
    /*
	if(_currentPlayer == [_players objectAtIndex:0]){
		_currentPlayer = [_players objectAtIndex:1];
	}
	else{
		_currentPlayer = [_players objectAtIndex:0];
	}
	
    //relay turn has ended
    //Begin Turn will get called again
    //Now we just simulate it by giving our player another turn
	if(_currentPlayer == _mePlayer){
		[self beginTurnWithPlayer:_currentPlayer];
	}
     */
}

//here we play the opponents move
- (void)playOtherPlayersMove:(enum ActionType)aType tileIndex:(int)tileIndex destTileIndex:(int)destTileIndex
{
	Tile *tile = (Tile*)[_map.tilesSprite childAtIndex:tileIndex];
	Tile *destTile;
	if (destTileIndex != -1){
		destTile = (Tile*)[_map.tilesSprite childAtIndex:destTileIndex];
	}
	
    switch (aType) {
        case UPGRADEVILLAGE:
        {
            [_map upgradeVillageWithTile:tile villageType:tile.village.vType + 1];
            break;
        }
        case BUILDMEADOW:
        {
            [_map buildMeadow:tile];
            break;
        }
        case MOVEUNIT:
        {
            [_map moveUnitWithTile:tile tile:destTile];
            break;
        }
        default:
            break;
    }
}

- (void)showActionMenu:(TileTouchedEvent*) event
{
    Tile* tile = event.tile;
    
    //if (tile.village.player != _currentPlayer) return;
    if (![tile canBeSelected]) return;
    
    [self removeTileListeners];
    [self selectTile:tile];
    
    _actionMenu = [[ActionMenu alloc] initWithTile:tile];
    [_popupMenuSprite addChild:_actionMenu];
    if (_actionMenu.buttonSprite.numChildren == 0) {
        [_actionMenu removeFromParent];
        [self addTileListeners];
    }
}

- (void)actionMenuAction:(ActionMenuEvent*) event
{
    NSLog(@"Action Menu Action");
    Tile* tile = event.tile;
    BOOL actionCompleted = true;
    
    enum ActionType aType = event.aType;
    
    switch (aType) {
        case UPGRADEVILLAGE:
        {
            [_map upgradeVillageWithTile:tile villageType:tile.village.vType + 1];
            break;
        }
        case BUYPEASANT:
        {
            [self selectTile:tile];
            _currentPlayerAction.action = aType;
            actionCompleted = false;
            break;
        }
        case BUYINFANTRY:
        {
            [self selectTile:tile];
            _currentPlayerAction.action = aType;
            actionCompleted = false;
            break;
        }
        case BUYSOLDIER:
        {
            [self selectTile:tile];
            _currentPlayerAction.action = aType;
            actionCompleted = false;
            break;
        }
        case BUYRITTER:
        {
            [self selectTile:tile];
            _currentPlayerAction.action = aType;
            actionCompleted = false;
            break;
        }
        case BUYCANNON:
        {
            [self selectTile:tile];
            _currentPlayerAction.action = aType;
            actionCompleted = false;
            break;
        }
        case SHOOTCANNON:
        {
            [self selectTile:tile];
            _currentPlayerAction.action = aType;
            actionCompleted = false;
            break;
        }
        case BUILDTOWER:
        {
            [self selectTile:tile];
            _currentPlayerAction.action = aType;
            actionCompleted = false;
            break;
        }
        case BUILDMEADOW:
        {
            [_map buildMeadow:tile];
            break;
        }
        case BUILDROAD:
        {
            [_map buildRoad:tile];
            break;
        }
        case UPGRADEUNIT:
        {
            [_map upgradeUnitWithTile:tile unitType:tile.unit.uType+1];
        }
        default:
            break;
    }
    
    [_actionMenu removeFromParent];
    [self addTileListeners];
    if (actionCompleted) {
        [self deselectTile:_currentPlayerAction.selectedTile];
    }
}

- (void)tileTouched:(TileTouchedEvent*) event
{
    //return if it's not your turn
    if (_mePlayer != _currentPlayer) {
        return;
    }
    NSLog(@"Tile touched");
    Tile* tile = event.tile;
    Tile* selectedTile = _currentPlayerAction.selectedTile;
    [selectedTile deselectTile];
    
    switch (_currentPlayerAction.action) {
        case AWAITINGCOMMAND:
        {
            if ([tile canBeSelected]) {
                [self selectTile:tile];
                if ([tile hasUnit]) _currentPlayerAction.action = MOVEUNIT;
            }
            break;
        }
        case MOVEUNIT:
        {
            [_map moveUnitWithTile:_currentPlayerAction.selectedTile tile:tile];
            [self deselectTile:selectedTile];
            break;
        }
        case BUYPEASANT:
        {
            [_map buyUnitFromTile:selectedTile tile:tile unitType:PEASANT];
            [self deselectTile:selectedTile];
            break;
        }
        case BUYINFANTRY:
        {
            [_map buyUnitFromTile:selectedTile tile:tile unitType:INFANTRY];
            [self deselectTile:selectedTile];
            break;
        }
        case BUYSOLDIER:
        {
            [_map buyUnitFromTile:selectedTile tile:tile unitType:SOLDIER];
            [self deselectTile:selectedTile];
            break;
        }
        case BUYRITTER:
        {
            [_map buyUnitFromTile:selectedTile tile:tile unitType:RITTER];
            [self deselectTile:selectedTile];
            break;
        }
        case BUYCANNON:
        {
            [_map buyUnitFromTile:selectedTile tile:tile unitType:CANNON];
            [self deselectTile:selectedTile];
            break;
        }
        case SHOOTCANNON:
        {
            [_map shootCannonFromTile: selectedTile tile:tile];
            [self deselectTile:selectedTile];
            break;
        }
        case BUILDTOWER:
        {
            [_map buildTowerFromTile:selectedTile tile:tile];
            [self deselectTile:selectedTile];
            break;
        }
        default:
            break;
    }
}

- (void)selectTile:(Tile*)tile
{
    _currentPlayerAction.selectedTile = tile;
    [_hud update:tile];
    [tile selectTile];
}

- (void)deselectTile:(Tile*)tile
{
    [_currentPlayerAction setAwaitingCommand];
    [tile deselectTile];
}

- (void)enableScroll
{
    [_world addEventListener:@selector(onMapTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    [self addEventListener:@selector(onEnterFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
}

- (void)disableScroll
{
    [_world removeEventListener:@selector(onMapTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    [self removeEventListener:@selector(onEnterFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
}

- (void)removeTileListeners
{
    [self removeEventListener:@selector(tileTouched:) atObject:self forType:EVENT_TYPE_TILE_TOUCHED];
    [self removeEventListener:@selector(showActionMenu:) atObject:self forType:EVENT_TYPE_SHOW_ACTION_MENU];
}

- (void)addTileListeners
{
    [self addEventListener:@selector(tileTouched:) atObject:self forType:EVENT_TYPE_TILE_TOUCHED];
    [self addEventListener:@selector(showActionMenu:) atObject:self forType:EVENT_TYPE_SHOW_ACTION_MENU];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerID{
	
}



- (void)onResize:(SPResizeEvent *)event
{
    NSLog(@"new size: %.0fx%.0f (%@)", event.width, event.height,
          event.isPortrait ? @"portrait" : @"landscape");
}


- (void)animateJugglers:(SPEnterFrameEvent *)event
{
    double passedTime = event.passedTime;
    [_gameJuggler advanceTime:passedTime];
}

@end
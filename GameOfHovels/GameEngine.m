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
#import "GlobalFlags.h"

@implementation GameEngine
{
    Map* _map;
    
    ActionMenu* _actionMenu;
    SPSprite* _contents;
    Hud* _hud;
    MessageLayer* _messageLayer;
    
    SPSprite* _popupMenuSprite;
    
    Tile* _selectedTile;
    
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
    
    _hud = [[Hud alloc] initWithPlayer:_mePlayer];
    [_contents addChild:_hud];
    
    
    SPQuad* q = [SPQuad quadWithWidth:Sparrow.stage.width*4 height:Sparrow.stage.height*4];
    q.x = -q.width/2;
    q.y = -q.height/2;
    q.color = 0xffffff;
    [_world addChild:q];
    
    
    _map = [[Map alloc] initWithRandomMap:_hud];
	_map.gameEngine = self;
    [_world addChild:_map];
    
    _popupMenuSprite = [SPSprite sprite];
    [_world addChild:_popupMenuSprite];
    
    //event Listeners
    [self addEventListener:@selector(tileTouched:) atObject:self forType:EVENT_TYPE_TILE_TOUCHED];
    [self addEventListener:@selector(actionMenuAction:) atObject:self forType:EVENT_TYPE_ACTION_MENU_ACTION];
    [self addEventListener:@selector(showActionMenu:) atObject:self forType:EVENT_TYPE_SHOW_ACTION_MENU];
    [self addEventListener:@selector(endTurn:) atObject:self forType:EVENT_TYPE_TURN_ENDED];

    [self enableScroll];

    
    _animationJuggler = [SPJuggler juggler];
    [self addEventListener:@selector(animateJugglers:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    
    _touching = NO;
    _lastScrollDist = 0;
    _scrollVector = [SPPoint pointWithX:0 y:0];
    
    

    [SPAudioEngine start];  // starts up the sound engine
    [Media initAtlas];      // loads your texture atlas -> see Media.h/Media.m
    [Media initSound];      // loads all your sounds    -> see Media.h/Media.m
    [self addEventListener:@selector(onResize:) atObject:self forType:SP_EVENT_TYPE_RESIZE];
    
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
    _selectedTile = nil;
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
            [_map upgradeVillageWithTile:tile];
            break;
        }
        case BUYUNIT:
        {
            [_map buyUnitFromTile:tile tile:destTile];
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
    
    if (tile.village.player != _currentPlayer) return;
    
    [self removeTileListener];
    [self selectTile:tile];
    
    _actionMenu = [[ActionMenu alloc] initWithTile:tile];
    [_popupMenuSprite addChild:_actionMenu];
}

- (void)actionMenuAction:(ActionMenuEvent*) event
{
    NSLog(@"Action Menu Action");
    Tile* tile = event.tile;
    BOOL actionCompleted = true;
    
    switch (event.aType) {
        case UPGRADEVILLAGE:
        {
            [_map upgradeVillageWithTile:tile];
            break;
        }
        case BUYUNIT:
        {
            [self selectTile:tile];
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
            [_map upgradeUnitWithTile:tile];
        }
        default:
            break;
    }
    
    [_actionMenu removeFromParent];
    [self addTileListener];
    if (actionCompleted) {
        [self deselectTile:_selectedTile];
    }
}

- (void)tileTouched:(TileTouchedEvent*) event
{
    Tile* tile = event.tile;
    
    if (_mePlayer != _currentPlayer && _selectedTile == nil) {
        return;
    }
    
    NSLog(@"Tile at position %f, %f touched and has %d connected tiles of the same color according to property. %d According to method . Has it been visited? %d", tile.x/54, tile.y/40, [tile getConnected],  [[tile getConnectedArray] count], [tile getVisited]);

    if (_selectedTile == nil && [tile canBeSelected]) {
        [self selectTile:tile];
    }
    else {
        Tile* destTile = tile;
        Unit* unit = _selectedTile.unit;

        //perform Unit actions
        if (unit != nil) {
            NSLog(@"Perform Unit action");
            if (tile != _selectedTile) {
                [_map moveUnitWithTile:_selectedTile tile:destTile];
            }
        }
        else if (_selectedTile.isVillage) {
            NSLog(@"Village Action");

            [_map buyUnitFromTile:_selectedTile tile:destTile];
        }

        [self deselectTile:_selectedTile];
    }
}

- (void)selectTile:(Tile*)tile
{
    _selectedTile = tile;
    [_hud update:tile];
    [tile selectTile];
}

- (void)deselectTile:(Tile*)tile
{
    _selectedTile = nil;
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

- (void)removeTileListener
{
    [self removeEventListener:@selector(tileTouched:) atObject:self forType:EVENT_TYPE_TILE_TOUCHED];
}

- (void)addTileListener
{
    [self addEventListener:@selector(tileTouched:) atObject:self forType:EVENT_TYPE_TILE_TOUCHED];
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
    [_animationJuggler advanceTime:passedTime];
}

@end
//
//  GameEngine.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>
#import "MessageLayer.h"

@class Map;
@class GamePlayer;

@interface GameEngine : SPSprite
{
    BOOL _touching;
    float _lastScrollDist;
    SPPoint* _scrollVector;
    SPSprite* _world;
}

@property GamePlayer* mePlayer;
@property GamePlayer* currentPlayer;

- (void)beginTurnWithPlayer:(GamePlayer*)player;
- (void)playOtherPlayersMove:(enum ActionType)aType tileIndex:(int)tileIndex destTileIndex:(int)destTileIndex;
-(void)setup:(Map*)map;
- (id)init:(Map*)map;

@end

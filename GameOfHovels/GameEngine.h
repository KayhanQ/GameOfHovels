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

- (void)beginTurn;
- (void)playOtherPlayersMove:(enum ActionType)aType tileIndex:(int)tileIndex destTileIndex:(int)destTileIndex;
- (void)playerExitedGame;
-(void)acceptOrRejectMap;
-(id)waitingForOtherPlayers;
-(void)makeOKActionTouchable;

@end

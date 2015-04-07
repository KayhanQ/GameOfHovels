//
//  MessageLayer.h
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-03-08.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//
@import GameKit;
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import "ActionMenu.h"
#import "GamePlayer.h"

@class GameEngine;
@class Map;

extern NSString *const PresentAuthenticationViewController;
extern NSString *const LocalPlayerIsAuthenticated;

@class Tile;

typedef enum {
	kMessageTypeRandomNumber = 0,
	kMessageTypeGameBegin,
	kMessageTypeMove,
	kMessageTypeGameOver
} MessageType;

typedef struct {
	MessageType messageType;
} Message;

typedef struct {
	Message message;
	uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
	Message message;
} MessageGameBegin;

typedef struct {
	Message message;
	int aType;
	int tileIndex;
	int destTileIndex;
} MessageMove;

typedef struct {
	Message message;
	BOOL player1Won;
} MessageGameOver;

typedef enum {
	kEndReasonWin,
	kEndReasonLose,
	kEndReasonDisconnect
} EndReason;

typedef enum {
	kGameStateWaitingForMatch = 0,
	kGameStateWaitingForRandomNumber,
	kGameStateWaitingForStart,
	kGameStateActive,
	kGameStateDone
} GameState;

@interface MessageLayer : NSObject<GKMatchmakerViewControllerDelegate, GKMatchDelegate>

+ (instancetype)sharedMessageLayer;
- (void)authenticateLocalPlayer;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
				 viewController:(UIViewController *)viewController;
- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController;
- (BOOL)allRandomNumbersAreReceived;
- (void)sendMoveWithType:(enum ActionType)aType tile:(Tile*)tile destTile:(Tile*)destTile;
- (void)makePlayers;
- (void)makePlayersGC;
- (GamePlayer*)getCurrentPlayer;
- (GamePlayer*)getPlayerForColor:(enum PlayerColor)pColor;
- (GamePlayer*)getMePlayer;

@property GameEngine* gameEngine;
@property NSMutableArray *players;

@property BOOL isPlayer1, receivedAllRandomNumbers, receivedRandom, matchHasStarted, enableGameCenter, matchStarted;
@property GameState gameState;
@property uint32_t ourRandom;
@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;
@property (nonatomic, strong) GKMatch *match;
@property NSObject *messageLayer;
@property (nonatomic, strong)NSData* mapData;
@end

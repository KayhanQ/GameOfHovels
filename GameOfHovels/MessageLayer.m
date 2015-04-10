


//
//  MessageLayer.m
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-03-08.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "MessageLayer.h"
#import "Tile.h"
#import "GameEngine.h"
#import "Map.h"
#import "MenuViewController.h"
#import "MapEncoding.h"
#import "GlobalFlags.h"

@implementation MessageLayer
NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
NSString *const LocalPlayerIsAuthenticated = @"local_player_authenticated";
@synthesize areHost = _areHost;
@synthesize gameEngine = _gameEngine;
@synthesize mapData = _mapData;
@synthesize mePlayer = _mePlayer;
@synthesize currentPlayer = _currentPlayer;
@synthesize listOfPlayersWhoAcceptedTheGame = _listOfPlayersWhoAcceptedTheGame;
+ (instancetype)sharedMessageLayer
{
	static MessageLayer *sharedMessageLayer;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMessageLayer = [[MessageLayer alloc] init];
	});
	return sharedMessageLayer;
}

- (id)init
{
	if( (self=[super init])) {
		_enableGameCenter = YES;
        _areHost = false;
        _listOfPlayersWhoAcceptedTheGame = [NSMutableArray array];
		// Set ourselves as player 1 and the game to active
		self.isPlayer1 = YES;		
		self.ourRandom = arc4random();
		NSLog(@"OurRandom=%d", self.ourRandom);
		[self setGameState:kGameStateWaitingForMatch];
        
        _players = [NSMutableArray array];
        
		[self authenticateLocalPlayer];
	}
	return self;
}

- (void)authenticateLocalPlayer
{
	if ([GKLocalPlayer localPlayer].isAuthenticated) {
		[[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
		return;
	}
	[[GKLocalPlayer localPlayer] setAuthenticateHandler:(^(UIViewController *viewController, NSError *error) {
		[self setLastError:error];
		
		if(viewController != nil) {
			[self setAuthenticationViewController:viewController];
		} else if([GKLocalPlayer localPlayer].isAuthenticated) {
			_enableGameCenter = YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
		} else {
			_enableGameCenter = NO;
		}
		NSLog(@"[GKLocalPlayer localPlayer].playerID=%@", [GKLocalPlayer localPlayer].playerID);
		
		//for some reason [GKLocalPlayer localPlayer].playerID returns null, but ONLY ON SIMULATOR
		if([GKLocalPlayer localPlayer].playerID != nil) {
			_mePlayer = [self createAndAddPlayer:[GKLocalPlayer localPlayer].playerID randomNumber:self.ourRandom];
		}
	})];
}

- (GamePlayer*)createAndAddPlayer:(NSString*)playerId randomNumber:(int)randomNumber {
    NSLog(@"createAndAddPlayer");
    GamePlayer* newPlayer = [[GamePlayer alloc] initWithNumber:[_players count] + 1];
    [newPlayer setPlayerId: playerId];
    [newPlayer setRandomNumber:randomNumber];
    [_players addObject:newPlayer];
    
    for (int i = 0; i < _players.count; i++) {
        GamePlayer* current1 = [_players objectAtIndex:i];
        for (int j = 0; j < _players.count; j++) {
            GamePlayer* current2 = [_players objectAtIndex: j];
            if (current1.randomNumber < current2.randomNumber) {
                [_players exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    return newPlayer;
}

- (BOOL)allRandomNumbersAreReceived
{
	NSLog(@"Players Count = %d", [_players count]);
	NSLog(@"Expected Players Count = %d", self.match.expectedPlayerCount);
    
	if ([_players count] == self.match.expectedPlayerCount) {
		return YES;
	}
	return NO;
}

- (void)didReceivePlayerOrderingRandomNumber:data fromPlayer:(NSString *)playerID
{
	MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
	NSLog(@"Received random number: %ud, ours %ud", messageInit->randomNumber, self.ourRandom);
	bool tie = false;
	
	if (messageInit->randomNumber == self.ourRandom) {
		NSLog(@"TIE!");
		tie = true;
		self.ourRandom = arc4random();
		[self sendRandomNumber];
	} else {
        [self createAndAddPlayer:playerID randomNumber:messageInit->randomNumber];
		if ([self allRandomNumbersAreReceived]) {
			_receivedAllRandomNumbers = YES;
		}
	}
}

- (void)sendData:(NSData *)data {
	NSLog(@"sendData");
	NSError *error;
	BOOL success = [self.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
	if (!success) {
		NSLog(@"Error sending init packet");
		[self matchEnded];
	}
}
-(void)checkIfAllAccepted {
	if ([_listOfPlayersWhoAcceptedTheGame count] == [_players count]) {
		[_gameEngine makeOKActionTouchable];
	}
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
	Message *message = (Message *) [data bytes];
	MessageMove * messageMove = (MessageMove *) [data bytes];
	MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];

		switch(message->messageType){
			case kMessageTypeRandomNumber:
				[self didReceivePlayerOrderingRandomNumber:data fromPlayer:playerID];
				break;
			case kMessageTypeGameBegin:
				break;
			case kMessageTypeGameAccepted:
				[_listOfPlayersWhoAcceptedTheGame addObject:playerID];
				[self checkIfAllAccepted];
				break;
            case kMessageTypeGameExited:
            {
                [_gameEngine playerExitedGame];
                break;
            }
            case kMessageTypePlayerLost:
            {
                MessagePlayerLost* messageLost = (MessagePlayerLost*) [data bytes];
                int playerLostID = messageLost->playerLostID;
                NSString* idString = [NSString stringWithFormat:@"%d",playerLostID];
                NSLog(@"message of type player lost!"); 
                NSLog(@"%@", idString);
                [self setLostForPlayerWithID:idString];
                break;
            }
			case kMessageTypeMove:
				[_gameEngine playOtherPlayersMove:messageMove->aType tileIndex:messageMove->tileIndex destTileIndex:messageMove->destTileIndex];
				break;
            case kMessageTypeTurnEnded:
            {
                NSLog(@"Turn Ended Message Received");
                [self incrementCurrentPlayer];
                [_gameEngine beginTurn];
                break;
            }
			case kMessageTypeGameOver:
				NSLog(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
				/* End Game */
				if (messageGameOver->player1Won) {
					//[self endScene:kEndReasonLose];
				} else {
					//[self endScene:kEndReasonWin];
				}
				break;
			default:
            {
                //this is super dangerous but it is how we do
				_mapData = data;
				ViewController *vc = [[ViewController alloc]init];
				[self.nav pushViewController:vc animated:false];
            }
		}
}

- (void)incrementCurrentPlayer
{
    for (GamePlayer* p in _players) {
        if (_currentPlayer == p) {
            int nextIndex = ([_players indexOfObject:p] + 1) % _players.count;
            _currentPlayer = [_players objectAtIndex:nextIndex];
            break;
        }
    }
}

- (void) sendGameAcceptedMessage{
	NSLog(@"send Game Accepted message");
	MessageGameAccepted message;
	message.message.messageType = kMessageTypeGameAccepted;
	NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameAccepted)];
	[self sendData:data];
	if(! [_listOfPlayersWhoAcceptedTheGame containsObject:_mePlayer.playerId]){
		[_listOfPlayersWhoAcceptedTheGame addObject:_mePlayer.playerId];
	}
	[self checkIfAllAccepted];
}

- (void)sendMessagePlayerLost:(GamePlayer*)player
{
    NSLog(@"send message plaer loost");
    MessagePlayerLost message;
    message.message.messageType = kMessageTypePlayerLost;
    message.playerLostID = [player.playerId intValue];
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessagePlayerLost)];
    [self sendData:data];
    
    [self setLostForPlayerWithID:player.playerId];
}

- (void)weHaveAWinner
{
    [_gameEngine displayWinnerAndQuit:[_players objectAtIndex:0]];
}

- (void)sendEndTurnMessage
{
    NSLog(@"send end turn message");
    MessageTurnEnded message;
    message.message.messageType = kMessageTypeTurnEnded;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageTurnEnded)];
    [self sendData:data];
    [self incrementCurrentPlayer];
}

- (void)sendGameExitedMessage
{
    NSLog(@"send GAME EXITED MESSAGE");
    MessageGameExited message;
    message.message.messageType = kMessageTypeGameExited;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameExited)];
    [self sendData:data];
}

- (void)reorderColorsOfPlayers {
    for (int i = 0; i<_players.count; i++) {
        GamePlayer* p = [_players objectAtIndex:i];
        p.pColor = i+1;
        NSLog(@"id %@, col %d",p.playerId,p.pColor);
    }
    _currentPlayer = [_players objectAtIndex:0];

}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
	if (_match != match) return;
	
	switch (state) {
		case GKPlayerStateConnected:
			NSLog(@"Player connected!");
			if (!_matchHasStarted && match.expectedPlayerCount == 0) {
				[self sendRandomNumber];
				NSLog(@"Ready to start match!");
			}
			break;
			
		case GKPlayerStateDisconnected:
			NSLog(@"Player disconnected!");
			_matchHasStarted = NO;
			[self matchEnded];
			break;
	}
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
	
	if (_match != match) return;
	
	NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
	_matchHasStarted = NO;
	[self matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
	
	if (_match != match) return;
	
	NSLog(@"Match failed with error: %@", error.localizedDescription);
	_matchHasStarted = NO;
	[self matchEnded];
}

- (void)matchEnded {
	NSLog(@"Match ended");
}


- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController
{ 
	if (authenticationViewController != nil) {
		_authenticationViewController = authenticationViewController;
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:PresentAuthenticationViewController
		 object:self];
	}
}

//We receive which move occured and encode and send it to all players
- (void)sendMoveWithType:(enum ActionType)aType tile:(Tile *)tile destTile:(Tile *)destTile
{
    NSLog(@"send Move With Type");
	MessageMove message;
	message.message.messageType = kMessageTypeMove;
	message.aType=aType;
	message.tileIndex=[tile.parent childIndex:tile];
	message.destTileIndex=-1;
	if (destTile!=nil) message.destTileIndex = [destTile.parent childIndex:destTile];
	NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)];
	[self sendData:data];
}

- (void)setLostForPlayerWithID:(NSString*)playerID
{
    for (GamePlayer* player in _players) {
        if ([player.playerId isEqualToString:playerID]) {
            player.hasLost = true;
            if (player == _mePlayer) {
                [_gameEngine displayYouHaveLost];
            }
            break;
        }
    }
    
    int numberPlayersLeft = _players.count;
    for (GamePlayer* player in _players) {
        if ([player hasLost]) numberPlayersLeft--;
    }
    if (numberPlayersLeft == 1) {
        [self weHaveAWinner];
    }
}

- (GamePlayer*)getPlayerForColor:(enum PlayerColor)pColor
{
    for (GamePlayer* player in _players) {
        if (player.pColor == pColor) return player;
    }
    return nil;
}


- (BOOL)isMyTurn
{
    if (_currentPlayer == _mePlayer) return true;
    return false;
}

- (void)sendRandomNumber {
	NSLog(@"sendRandomNumber");
	MessageRandomNumber message;
	message.message.messageType = kMessageTypeRandomNumber;
	message.randomNumber = self.ourRandom;
	NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
	[self sendData:data];
}

- (void)sendGameOver:(BOOL)player1Won {
    NSLog(@"Send Game Over");
	MessageGameOver message;
	message.message.messageType = kMessageTypeGameOver;
	message.player1Won = player1Won;
	NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];
	[self sendData:data];
}


- (void)setLastError:(NSError *)error
{
	_lastError = [error copy];
	if (_lastError) {
		NSLog(@"MessageLayer ERROR: %@",
			  [[_lastError userInfo] description]);
	}
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
				 viewController:(UIViewController *)viewController{
	
	if (!_enableGameCenter) return;
	
	_matchHasStarted = NO;
	self.match = nil;
	[viewController dismissViewControllerAnimated:NO completion:nil];
	
	GKMatchRequest *request = [[GKMatchRequest alloc] init];
	request.minPlayers = minPlayers;
	request.maxPlayers = maxPlayers;
	
	GKMatchmakerViewController *mmvc =
	[[GKMatchmakerViewController alloc] initWithMatchRequest:request];
	mmvc.matchmakerDelegate = self;
	
	[[MessageLayer sharedMessageLayer].nav presentViewController:mmvc animated:YES completion:nil];
}

// FOUND MATCH
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
	[viewController dismissViewControllerAnimated:YES completion:nil];
	self.match = match;
	match.delegate = self;
	if (!_matchHasStarted) {
		[self sendRandomNumber];
	}
}

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
	[viewController dismissViewControllerAnimated:YES completion:nil];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
	[viewController dismissViewControllerAnimated:YES completion:nil];
	NSLog(@"Error finding match: %@", error.localizedDescription);
}

@end

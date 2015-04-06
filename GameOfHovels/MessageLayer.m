

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

@implementation MessageLayer
NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
NSString *const LocalPlayerIsAuthenticated = @"local_player_authenticated";
@synthesize gameEngine = _gameEngine;

+ (instancetype)sharedMessageLayer
{
	static MessageLayer *sharedMessageLayer;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMessageLayer = [[MessageLayer alloc] init];
	});
	return sharedMessageLayer;
}

-(id) init
{
	if( (self=[super init])) {
		_enableGameCenter = YES;

		// Set ourselves as player 1 and the game to active
		self.isPlayer1 = YES;
		[self setGameState:kGameStateActive];
		
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
		if([GKLocalPlayer localPlayer].playerID != nil){
			[self createAndAddPlayer:[GKLocalPlayer localPlayer].playerID randomNumber:self.ourRandom];
		}
	})];
}

-(void)createAndAddPlayer:(NSString*)playerId randomNumber:(int)randomNumber{
	NSLog(@"[createAndAddPlayer");
	GamePlayer* p = [[GamePlayer alloc] initWithNumber:[_players count]];
	[p setPlayerId: playerId];
	[p setRandomNumber:randomNumber];
	if([_players count] == 0){
		[_players addObject:p];
	}
	for(int i = 0; i < [_players count]; i++){
		if(randomNumber < [[_players objectAtIndex:i] randomNumber]){
			[_players insertObject:p atIndex:i];
		}
	}
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
		if ([self allRandomNumbersAreReceived]) {
			_receivedAllRandomNumbers = YES;
		}
	}
	
	if (!tie && self.receivedAllRandomNumbers) {
		if (_gameState == kGameStateWaitingForRandomNumber) {
			_gameState = kGameStateWaitingForStart;
		}
		[self tryStartGame];
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
			[self setGameState:kGameStateActive];
			break;
		case kMessageTypeMove:
			[_gameEngine playOtherPlayersMove:messageMove->aType tileIndex:messageMove->tileIndex destTileIndex:messageMove->destTileIndex];
			break;
		case kMessageTypeGameOver:
			NSLog(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
			/* End Game */
			if (messageGameOver->player1Won) {
				//[self endScene:kEndReasonLose];
			} else {
				//[self endScene:kEndReasonWin];
			}
			break;
	}
}

- (void)tryStartGame {
	NSLog(@"tryStartGame");
	if (self.isPlayer1 && self.gameState == kGameStateWaitingForStart) {
		[self setGameState:kGameStateActive];
		[self sendGameBegin];
	}
}

- (void)matchStarted {
	NSLog(@"Match started");
	if (self.receivedRandom) {
		self.gameState = kGameStateWaitingForStart;
	} else {
		self.gameState = kGameStateWaitingForRandomNumber;
	}
	[self sendRandomNumber];
	[self tryStartGame];
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


// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
	if (_match != match) return;
	
	switch (state) {
		case GKPlayerStateConnected:
			NSLog(@"Player connected!");
			if (!_matchHasStarted && match.expectedPlayerCount == 0) {
				[self matchStarted];
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
	MessageMove message;
	message.message.messageType = kMessageTypeMove;
	message.aType=aType;
	message.tileIndex=[tile.parent childIndex:tile];
	message.destTileIndex=-1;
	if (destTile!=nil) message.destTileIndex = [destTile.parent childIndex:destTile];
	NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)];
	[self sendData:data];
}

//code Kayhan has implemented
- (void)makePlayers
{
    GamePlayer* p1 = [[GamePlayer alloc] initWithNumber:3];
    [_players addObject:p1];
    
	GamePlayer* p2 = [[GamePlayer alloc] initWithNumber:4];
    [_players addObject:p2];

    GamePlayer* p3 = [[GamePlayer alloc] initWithNumber:2];
    [_players addObject:p3];
}

/*- (void)makePlayersGC
{
	for (int i = 0; i < [_players count]; i++)
	{
		GamePlayer* p = [[GamePlayer alloc] initWithNumber:i];
		NSDictionary* player = [_players objectAtIndex:i];
		[_players removeObjectAtIndex:i];
		[p setPlayerId:(NSString*)[player objectForKey:@"PlayerId"]];
		[p setRandomNumber:(long)[player objectForKey:@"randomNumber"]];
		[_players addObject:p];
	}
}*/

- (GamePlayer*)getPlayerForColor:(enum PlayerColor)pColor;
{
    for (GamePlayer* player in _players) {
        if (player.pColor == pColor) return player;
    }
    return nil;
}

//TODO
- (GamePlayer*)getCurrentPlayer
{
    return [_players objectAtIndex:0];
}


- (void)sendRandomNumber {
	NSLog(@"sendRandomNumber");
	MessageRandomNumber message;
	message.message.messageType = kMessageTypeRandomNumber;
	message.randomNumber = self.ourRandom;
	NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
	[self sendData:data];
}

- (void)sendGameBegin {
	NSLog(@"sendGameBegin");
	MessageGameBegin message;
	message.message.messageType = kMessageTypeGameBegin;
	NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
	[self sendData:data];
	
}

- (void)sendGameOver:(BOOL)player1Won {
	
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
	
	[viewController presentViewController:mmvc animated:YES completion:nil];
}

// FOUND MATCH
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
	[viewController dismissViewControllerAnimated:YES completion:nil];
	self.match = match;
	match.delegate = self;
	if (!_matchHasStarted && match.expectedPlayerCount == 0) {
		NSLog(@"Ready to start match!");
		[self matchStarted];
		ViewController *vc = [[ViewController alloc]init];
		[viewController presentViewController:vc animated:YES completion:nil];
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

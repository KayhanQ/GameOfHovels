
//
//  MessageLayer.m
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-03-08.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "MessageLayer.h"
#import "Tile.h"
#define playerIdKey @"PlayerId"
#define randomNumberKey @"randomNumber"
#import "GameEngine.h"

@implementation MessageLayer
NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
NSString *const LocalPlayerIsAuthenticated = @"local_player_authenticated";
@synthesize gameEngine = _gameEngine;

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// Set up main loop to check for wins
		//[self scheduleUpdate];
		_enableGameCenter = YES;

		// Set ourselves as player 1 and the game to active
		self.isPlayer1 = YES;
		[self setGameState:kGameStateActive];
		
		//AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		//[[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.viewController delegate:self];
		
		self.ourRandom = arc4random();
		NSLog(@"OurRandom=%d", self.ourRandom);
		[self setGameState:kGameStateWaitingForMatch];
		self.orderOfPlayers = [NSMutableArray array];
		[self authenticateLocalPlayer];
	}
	return self;
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
	[viewController dismissViewControllerAnimated:YES completion:nil];
	self.match = match;
	match.delegate = self;
	if (!_matchHasStarted && match.expectedPlayerCount == 0) {
		NSLog(@"Ready to start match!");
		[self lookupPlayers];
		ViewController *vc = [[ViewController alloc]init];
		[viewController presentViewController:vc animated:YES completion:nil];
	}
}

- (void)lookupPlayers {
 
	NSLog(@"Looking up %d players...", self.match.playerIDs.count);
	[GKPlayer loadPlayersForIdentifiers:self.match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
		
		if (error != nil) {
			NSLog(@"Error retrieving player info: %@", error.localizedDescription);
			self.matchHasStarted = NO;
			[self matchEnded];
		} else {
			
			// Populate players dict
			self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
			for (GKPlayer *player in players) {
				NSLog(@"Found player: %@", player.alias);
				[self.playersDict setObject:player forKey:player.playerID];
			}
			
			// Notify delegate match can begin
			self.matchHasStarted = YES;
			[self matchStarted];
			
		}
	}];
}

-(void)processReceivedRandomNumber:(NSDictionary*)randomNumberDetails {
	if([_orderOfPlayers containsObject:randomNumberDetails]) {
		[_orderOfPlayers removeObjectAtIndex: [_orderOfPlayers indexOfObject:randomNumberDetails]];
	}
	[_orderOfPlayers addObject:randomNumberDetails];
	NSSortDescriptor *sortByRandomNumber =
	[NSSortDescriptor sortDescriptorWithKey:randomNumberKey
								  ascending:NO];
	NSArray *sortDescriptors = @[sortByRandomNumber];
	[_orderOfPlayers sortUsingDescriptors:sortDescriptors];
 	if ([self allRandomNumbersAreReceived]) {
		_receivedAllRandomNumbers = YES;
	}

}

- (BOOL)isLocalPlayerPlayer1
{
	NSDictionary *dictionary = _orderOfPlayers[0];
	if ([dictionary[playerIdKey]
		 isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
		NSLog(@"I'm player 1");

		return YES;
	}
	return NO;
}

- (void)tryStartGame {
	NSLog(@"tryStartGame");
	if (self.isPlayer1 && self.gameState == kGameStateWaitingForStart) {
		[self setGameState:kGameStateActive];
		[self sendGameBegin];
		//[self setupStringsWithOtherPlayerId:otherPlayerID];
	}
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


+ (instancetype)sharedMessageLayer
{
	static MessageLayer *sharedMessageLayer;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedMessageLayer = [[MessageLayer alloc] init];
	});
	return sharedMessageLayer;
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

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
	[viewController dismissViewControllerAnimated:YES completion:nil];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
	[viewController dismissViewControllerAnimated:YES completion:nil];
	NSLog(@"Error finding match: %@", error.localizedDescription);
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

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
 
	// Store away other player ID for later
	if (self.otherPlayerID == nil) {
		NSLog(@"self.otherPlayerID==nil, apparently");
		//otherPlayerID = [playerID retain];
	}
 
	Message *message = (Message *) [data bytes];
	if (message->messageType == kMessageTypeRandomNumber) {
		
		MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
		NSLog(@"Received random number: %ud, ours %ud", messageInit->randomNumber, self.ourRandom);
		bool tie = false;
		
		if (messageInit->randomNumber == self.ourRandom) {
			NSLog(@"TIE!");
			tie = true;
			self.ourRandom = arc4random();
			[self sendRandomNumber];
		} else {
			NSDictionary *dictionary = @{playerIdKey : playerID,
										 randomNumberKey : @(messageInit->randomNumber)};
			[self processReceivedRandomNumber:dictionary];
		}
		
		if (self.receivedAllRandomNumbers) {
			_isPlayer1 = [self isLocalPlayerPlayer1];
		}
		
		if (!tie && self.receivedAllRandomNumbers) {
			if (_gameState == kGameStateWaitingForRandomNumber) {
				_gameState = kGameStateWaitingForStart;
			}
			[self tryStartGame];
		}
	}else if (message->messageType == kMessageTypeGameBegin) {
		[self setGameState:kGameStateActive];
	} else if (message->messageType == kMessageTypeMove) {
		NSLog(@"Received move");
		
			//[player2 moveForward];
			MessageMove * messageMove = (MessageMove *) [data bytes];
			[_gameEngine playOtherPlayersMove:messageMove->aType tileIndex:messageMove->tileIndex destTileIndex:messageMove->destTileIndex];
	} else if (message->messageType == kMessageTypeGameOver) {
		MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
		NSLog(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
		/* End Game */
		if (messageGameOver->player1Won) {
			//[self endScene:kEndReasonLose];
		} else {
			//[self endScene:kEndReasonWin];
		}
	}
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
	if (_match != match) return;
	
	switch (state) {
		case GKPlayerStateConnected:
			// handle a new player connection.
			NSLog(@"Player connected!");
			
			if (!_matchHasStarted && match.expectedPlayerCount == 0) {
				[self lookupPlayers];
				NSLog(@"Ready to start match!");
			}
			
			break;
		case GKPlayerStateDisconnected:
			// a player just disconnected.
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
			NSLog([GKLocalPlayer localPlayer].playerID);
			[self.orderOfPlayers addObject:@{playerIdKey : [GKLocalPlayer localPlayer].playerID,
											 randomNumberKey : @(self.ourRandom)}];
		}
		
	})];
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

- (BOOL)allRandomNumbersAreReceived
{
	NSMutableArray *receivedRandomNumbers =
	[NSMutableArray array];
	
	for (NSDictionary *dict in _orderOfPlayers) {
		[receivedRandomNumbers addObject:dict[randomNumberKey]];
	}
	
	NSArray *arrayOfUniqueRandomNumbers = [[NSSet setWithArray:receivedRandomNumbers] allObjects];
	
	if (arrayOfUniqueRandomNumbers.count == self.match.playerIDs.count + 1) {
		return YES;
	}
	return NO;
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



@end

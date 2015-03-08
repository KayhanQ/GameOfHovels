//
//  GameKitHelper.h
//  CatRaceStarter
//
//  Created by Kauserali on 12/01/14.
//  Copyright (c) 2014 Raywenderlich. All rights reserved.
//

@import GameKit;
#import "ViewController.h"
extern NSString *const PresentAuthenticationViewController;
extern NSString *const LocalPlayerIsAuthenticated;

@protocol GameKitHelperDelegate
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerID;
@end

@interface GameKitHelper : NSObject<GKMatchmakerViewControllerDelegate, GKMatchDelegate>{
	BOOL matchStarted;
}

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;

@property (nonatomic, strong) GKMatch *match;
@property (nonatomic, assign) id <GameKitHelperDelegate> delegate;

@property NSMutableDictionary *playersDict;

+ (instancetype)sharedGameKitHelper;
- (void)authenticateLocalPlayer;

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GameKitHelperDelegate>)delegate;
@end

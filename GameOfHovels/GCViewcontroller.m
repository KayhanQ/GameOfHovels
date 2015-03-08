
//
//  GCViewcontroller.m
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-02-20.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "GCViewcontroller.h"
#import "GameKitHelper.h"

@interface GCViewcontroller()<GameKitHelperDelegate>
@end

@implementation GCViewcontroller
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticated)
												 name:LocalPlayerIsAuthenticated object:nil];
}

- (void)playerAuthenticated {
	[[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:self];
}

#pragma mark GameKitHelperDelegate
- (void)matchStarted {
	NSLog(@"Match started");
}

- (void)matchEnded {
	NSLog(@"Match ended");
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
	NSLog(@"Received data");
}


@end


//
//  GCViewcontroller.m
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-02-20.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "GCViewcontroller.h"
#import "MessageLayer.h"

@interface GCViewcontroller()
@end

@implementation GCViewcontroller
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticated)
												 name:LocalPlayerIsAuthenticated object:nil];
}

- (void)playerAuthenticated {
	NSLog(@"asdfasdf");
	[[MessageLayer sharedMessageLayer] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self
	];
}

@end

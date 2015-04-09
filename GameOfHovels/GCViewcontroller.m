
//
//  GCViewcontroller.m
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-02-20.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "GCViewcontroller.h"
#import "MessageLayer.h"
#import "GlobalFlags.h"
#import "MenuViewController.h"

@interface GCViewcontroller()
@end

@implementation GCViewcontroller
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    
    BOOL startWithGC = [GlobalFlags isGameWithGC];
    
    if (startWithGC) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticated)
                                                     name:LocalPlayerIsAuthenticated object:nil];
    }
    else {
        //This is only to test local play
        [[MessageLayer sharedMessageLayer] makePlayers];
        ViewController *vc = [[ViewController alloc]init];
        [[MessageLayer sharedMessageLayer].nav pushViewController:vc animated:YES];
    }

}

- (void)playerAuthenticated {
	//Menu
	MenuViewController *mvc = [[MenuViewController alloc]init];
	[[MessageLayer sharedMessageLayer] findMatchWithMinPlayers:2 maxPlayers:2 viewController:mvc];

	
	[[MessageLayer sharedMessageLayer].nav pushViewController:mvc animated:YES];
}

@end

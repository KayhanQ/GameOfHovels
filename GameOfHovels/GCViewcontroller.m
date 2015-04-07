
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
        ViewController *vc = [[ViewController alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
    }

}

- (void)playerAuthenticated {
	//Menu
	//[MessageLayer sharedMessageLayer].vc = [[ViewController alloc]init];

	MenuViewController *mvc = [[MenuViewController alloc]init];
	[self presentViewController:mvc animated:YES completion:nil];
	//[[MessageLayer sharedMessageLayer] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
}

@end

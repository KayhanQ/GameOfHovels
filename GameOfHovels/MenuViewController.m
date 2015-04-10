//
//  MenuViewController.m
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-04-05.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "MenuViewController.h"
#import "MessageLayer.h"
#import "LoadGameTableViewController.h"
#import "MapEncoding.h"

@implementation MenuViewController

//send maps
- (IBAction)newGame:(id)sender {
	ViewController* vc = [[ViewController alloc]init];
    [MessageLayer sharedMessageLayer].areHost = true;
	[[MessageLayer sharedMessageLayer].nav pushViewController:vc animated:YES];
	
}

//load maps
- (IBAction)loadGame:(id)sender {
	LoadGameTableViewController *lgvc = [[LoadGameTableViewController alloc] init];
    [MessageLayer sharedMessageLayer].areHost = true;
	[[MessageLayer sharedMessageLayer].nav pushViewController:lgvc animated:false];
}
@end

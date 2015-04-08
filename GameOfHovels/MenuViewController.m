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
#import "NewGameTableViewController.h"

@implementation MenuViewController

//send maps
- (IBAction)newGame:(id)sender {
	NewGameTableViewController *ngvc = [[NewGameTableViewController alloc] init];
	[self presentViewController:ngvc animated:YES completion:nil];
}

//load maps
- (IBAction)loadGame:(id)sender {
	LoadGameTableViewController *lgvc = [[LoadGameTableViewController alloc] init];
	[self presentViewController:lgvc animated:YES completion:nil];
}
@end

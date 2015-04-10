//
//  LoadGameTableViewController.m
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-04-06.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "LoadGameTableViewController.h"
#import "MapEncoding.h"
#import "MessageLayer.h"

@interface LoadGameTableViewController ()
@end

@implementation LoadGameTableViewController
@synthesize dirContents;

-(NSString*) createPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString* rootPath = paths[0];
	NSString* path = [rootPath stringByAppendingPathComponent:@"Saved_Games"];
	return path;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (!dirContents) {
		NSString* path = [self createPath];
		NSFileManager *fm = [NSFileManager defaultManager];
		dirContents = [fm contentsOfDirectoryAtPath:path error:nil];
	}
	
//	NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
//	NSString * mapsPath = [resourcePath stringByAppendingPathComponent:@"maps"];
//	NSError * error;
//	_listOfMaps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mapsPath error:&error];


	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSLog(@"what up: %d",[dirContents count]);
    return [dirContents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	static NSString *CellIdentifier = @"aCell";
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc]init];
	}

	if(indexPath.row < [dirContents count]){
		cell.textLabel.text = [self.dirContents objectAtIndex:indexPath.row];
	}
//	else{
//		cell.textLabel.text = [_listOfMaps objectAtIndex:(indexPath.row -[dirContents count])];
//	}
	
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//Get the cell
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString* path = [self createPath];
	path = [path stringByAppendingPathComponent:cell.textLabel.text];
	
	//get the data out of the file and send it to the mapdecoder
	NSData* encodedData = [fm contentsAtPath:path];
	[MessageLayer sharedMessageLayer].mapData = encodedData;

    NSLog(@"Table View Touched");
	//create a game engine with the map
	ViewController* vc = [[ViewController alloc]init];
    [MessageLayer sharedMessageLayer].areHost = true;
	[[MessageLayer sharedMessageLayer].nav pushViewController:vc animated:YES];
}


@end

//
//  LoadGameTableViewController.m
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-04-06.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "LoadGameTableViewController.h"
#import "MapEncoding.h"

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

	cell.textLabel.text = [self.dirContents objectAtIndex:indexPath.row];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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
	MapEncoding* mapEncoder = [[MapEncoding alloc] init];
	Map* map = [mapEncoder decodeMap:encodedData];
	
    // there is a map called 'goat' that you can try and load. There is a soldier on the top left tile.
    
    // Create the game using the map we just decoded.
	
	
	
	// write an init method in GameEngine that takes this map as input.
	
	//Create and present a "ViewController" with the game
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

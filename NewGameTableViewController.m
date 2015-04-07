//
//  NewGameTableViewController.m
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-04-06.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "NewGameTableViewController.h"
#import "MapEncoding.h"
#import "ViewController.h"
#import "GameEngine.h"

@interface NewGameTableViewController ()

@end

@implementation NewGameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
	NSString * mapsPath = [resourcePath stringByAppendingPathComponent:@"maps"];
	NSError * error;
	_listOfMaps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mapsPath error:&error];
	

		//We need a new directory called New_Game_Maps, and to store all of the game maps
		// that we need in the bundle.
		//Name these maps "three-way merge", or "castle", or w/e
		//hardcode the list of map names here.
	
	//grab the list of map names and display it in the "cellForRowAtIndexPath" method

	
	//when one of the (rows)maps is selected,
		//decodeMap and then call that new init method in GameEngine that takes a map as input
	
		//Now we need to tell everyone else that you just selected this map
		//Map agreement algorithm
		//Need a new messageType Map selection
		

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_listOfMaps count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//Get the cell
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc]init];
	}

	cell.textLabel.text = [_listOfMaps objectAtIndex:indexPath.row];
	//grab the list of map names and display it in the "cellForRowAtIndexPath" method
 
    return cell;
}


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
	NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
	NSString* mapsPath = [resourcePath stringByAppendingPathComponent:@"maps"];
	NSString* path = [mapsPath stringByAppendingPathComponent:cell.textLabel.text];
	
	//get the data out of the file and send it to the mapdecoder
	NSData* encodedData = [fm contentsAtPath:path];
	[MessageLayer sharedMessageLayer].mapData = encodedData;

	//create a game engine with the map
	ViewController* vc = [[ViewController alloc]init];
	
	[self presentViewController:vc animated:YES completion:nil];
	
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

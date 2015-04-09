//
//  LoadGameTableViewController.h
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-04-06.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameEngine.h"
@interface LoadGameTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>{
}
@property (strong, nonatomic) NSMutableArray* dirContents;
@property NSArray* listOfMaps;

@end

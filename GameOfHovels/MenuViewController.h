//
//  MenuViewController.h
//  GameOfHovels
//
//  Created by Martin Weiss 1 on 2015-04-05.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *NumberOfPlayersLabel;
- (IBAction)newGame:(id)sender;
- (IBAction)loadGame:(id)sender;

@end

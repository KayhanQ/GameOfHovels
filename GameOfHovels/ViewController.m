//
//  ViewController.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "ViewController.h"
#import "GameEngine.h"


@interface ViewController ()
{
    SPViewController *_viewController;
    UIWindow *_window;
}
@end

@implementation ViewController

- (id)init
{
	if ((self = [super init]))
	{
		[self loadSparrowGame];
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"In ViewController");
}

- (void)loadSparrowGame
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    _window = [[UIWindow alloc] initWithFrame:screenBounds];
    
    _viewController = [[SPViewController alloc] init];

    _viewController.multitouchEnabled = YES;
    
    [_viewController startWithRoot:[GameEngine class] supportHighResolutions:YES doubleOnPad:YES];
    
    [_window setRootViewController:_viewController];
    [_window makeKeyAndVisible];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



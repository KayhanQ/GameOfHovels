//
//  ViewController.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import "ViewController.h"
#import "GameEngine.h"
#import "MenuViewController.h"

@interface ViewController ()
{
    SPViewController *_viewController;
    UIWindow *_window;
	UIAlertController* _alertController;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"In ViewController");
    [self loadSparrowGame];
}

- (void)loadSparrowGame
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    _window = [[UIWindow alloc] initWithFrame:screenBounds];
    
    _viewController = [[SPViewController alloc] init];
    
    // Enable some common settings here:
    //
    // _viewController.showStats = YES;
    _viewController.multitouchEnabled = YES;
    // _viewController.preferredFramesPerSecond = 60;
    
    [_viewController startWithRoot:[GameEngine class] supportHighResolutions:YES doubleOnPad:YES];
    
    [_window setRootViewController:_viewController];
    [_window makeKeyAndVisible];
}

-(void)waitingForOtherPlayers{
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Game Time!"
										  message:@"Waiting for other players to accept your choice..."
										  preferredStyle:UIAlertControllerStyleAlert];
	
	UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc]
										initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	loading.frame=CGRectMake(150, 150, 16, 16);
	[alertController.view addSubview:loading];
	
	_alertController = alertController;
	
	[Sparrow.currentController presentViewController:alertController animated:YES completion:nil];

}
-(void)acceptOrRejectMap{
	UIAlertController *alertController = [UIAlertController
										  alertControllerWithTitle:@"Game Time!"
										  message:@"Do you want to play this map?."
										  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"...no" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
								   {
									   [self presentingViewController];
								   }];
	[alertController addAction:cancelAction];
	
	UIAlertAction *okAction = [UIAlertAction
							   actionWithTitle:NSLocalizedString(@"YES YES YES YES", @"OK action")
							   style:UIAlertActionStyleDefault
							   handler:^(UIAlertAction *action)
							   {
								   [[NSNotificationCenter defaultCenter] removeObserver:self
																				   name:UITextFieldTextDidChangeNotification
																				 object:nil];
							   }];
	okAction.enabled = YES;
	[alertController addAction:okAction];
	
	_alertController = alertController;
	
	[Sparrow.currentController presentViewController:alertController animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



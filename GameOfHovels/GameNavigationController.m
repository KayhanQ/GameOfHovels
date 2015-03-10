//
//  GameNavigationController.m
//  CatRaceStarter
//
//  Created by Kauserali on 30/12/13.
//  Copyright (c) 2013 Raywenderlich. All rights reserved.
//

#import "GameNavigationController.h"
#import "GameNavigationController.h"
#import "MessageLayer.h"

@implementation GameNavigationController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil];
    
    [MessageLayer sharedMessageLayer];
}

- (void)showAuthenticationViewController
{
    MessageLayer *messageLayer =
    [MessageLayer sharedMessageLayer];
    
    [self.topViewController presentViewController:
     messageLayer.authenticationViewController
                                         animated:YES
                                       completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

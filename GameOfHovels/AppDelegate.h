//
//  AppDelegate.h
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCViewcontroller.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
	GCViewcontroller	*viewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) GCViewcontroller *viewController;


@end


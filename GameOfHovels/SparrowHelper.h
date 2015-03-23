//
//  SparrowHelper.h
//  Bastion
//
//  Created by Kayhan Feroze Qaiser on 17/02/2015.
//
//


@interface SparrowHelper : NSObject
{
}

@property (nonatomic, readonly) SPJuggler* gameJuggler;

+ (instancetype)sharedSparrowHelper;
+ (void)centerPivot:(SPDisplayObject*)displayObject;



@end
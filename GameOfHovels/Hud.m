
//
//  Hud.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hud.h"
#import "GamePlayer.h"
#import "GHEvent.h"
#import "SparrowHelper.h"
#import "Tile.h"
#import "Village.h"
#import "GameEngine.h"
#import "Map.h"


@implementation Hud {
    
    SPButton* _endTurnButton;
    SPTextField* _woodField;
    SPTextField* _goldField;
    
    SPTextField* _upkeepField;
    SPTextField* _unitNameField;
    
    SPTextField* _healthField;
    SPTextField* _numTilesInRegion;
    
    SPTextField* _homeCoordField;
    SPTextField* _ownerField;
    
    SPTextField* _tileNumberField;
    
    int _yOffsetMinor;
    float _middleX;
    float _height;
    float _width;
}

@synthesize player = _player;

-(id)initWithMap:(Map *)map
{
    if (self=[super init]) {
        //custom code here
        
        //_player = player;
        _map = map;
        
        _height = 380;
        _width = 130;
        _yOffsetMinor = 3;
        
        SPImage* background = [SPImage imageWithContentsOfFile:@"hudpanel.png"];
        
        background.width = _width;
        background.height = _height + 4;
        
        [self addChild:background];
        
        _middleX = _width/2;
        SPTexture* buttonTexture = [SPTexture textureWithContentsOfFile:@"endturn.png"];
        
        _endTurnButton = [SPButton buttonWithUpState:buttonTexture];
        
        _endTurnButton.height = 40; //Just Some magic number
        _endTurnButton.width = 100;
        
        [SparrowHelper centerPivot:_endTurnButton];
        
        _endTurnButton.x = _middleX;
        _endTurnButton.y = _height - _endTurnButton.height;
        
        [self addChild:_endTurnButton];
        [_endTurnButton addEventListener:@selector(endTurnTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        
        //Village Info-------
        _woodField = [self newTextField];
        //_woodField.text = @"Wood: ";
        _woodField.y = 200;
        [self addChild:_woodField];
        
        _goldField = [self newTextField];
        //_goldField.text = @"Gold: ";
        _goldField.y = _woodField.y + _woodField.height + _yOffsetMinor;
        [self addChild:_goldField];
        
         _healthField = [self newTextField];
         //_healthField.text = @"Village Health: ";
         _healthField.y = _goldField.y + _goldField.height + _yOffsetMinor;
         [self addChild:_healthField];
         
         _numTilesInRegion = [self newTextField];
        // _numTilesInRegion.text = @"Village Health: ";
         _numTilesInRegion.y = _healthField.y + _healthField.height + _yOffsetMinor;
         [self addChild:_numTilesInRegion];

        //Unit Info---------
        _upkeepField = [self newTextField];
        _upkeepField.y = _woodField.y + _woodField.height + _yOffsetMinor;
        [self addChild:_upkeepField];
        
        _unitNameField = [self newTextField];
        _unitNameField.y = _woodField.y;
        [self addChild:_unitNameField];
        
        _homeCoordField = [self newTextField];
        _homeCoordField.y = _woodField.y - _woodField.height - _yOffsetMinor;
        _homeCoordField.fontSize = 10;
        [self addChild:_homeCoordField];
        
        _ownerField = [self newTextField];
        _ownerField.y = _woodField.y - 2*_woodField.height - _yOffsetMinor;
        [self addChild:_ownerField];
        
        
    }
    
    return self;
}

- (SPTextField*)newTextField
{
    SPTextField* t = [SPTextField textFieldWithWidth:_width height:15 text:@""];
    t.x = _middleX;
    //t.border = true;
    t.fontSize = 12;
    [SparrowHelper centerPivot:t];
    return t;
}

- (void)update:(Tile *)tile
{
    
    if(tile.hasUnit){ // put unit stats here: unit type, unit upkeep, owning village
        
        NSLog(@"Has unit");
        
        Unit* unit = [tile getUnit];
        
        _ownerField.text = @"";
        _homeCoordField.text = @"";
        _woodField.text = @"";
        _goldField.text= @"";
        
        
        Tile * villageTile = [_map getVillageTile: tile.village];
        
        NSLog(@"Home Coordinates: %.01f, %.01f", villageTile.x/54, villageTile.y/40);

        
        NSString* ownerFieldString = [NSString stringWithFormat:@"Owned By Player: %d", tile.pColor];
        _ownerField.text = ownerFieldString;
        
        NSString* homeCoordString = [NSString stringWithFormat:@"Home Coordinates: %.01f, %.01f",villageTile.x/54, villageTile.y/40];
        _homeCoordField.text = homeCoordString;
        
        NSString* unitNameString = [NSString stringWithFormat:@"Unit Type: %u", unit.uType];
        _unitNameField.text = unitNameString;
        
        NSString* upkeepString = [NSString stringWithFormat:@"Upkeep: %d", unit.upkeepCost];
        _upkeepField.text = upkeepString;
        
    }
    
    else if(tile.hasVillage){ //put village stats here
        NSLog(@"Has village");
        
        Village* v = tile.village;
        
        _ownerField.text = @"";
        _homeCoordField.text = @"";
        _upkeepField.text = @"";
        _unitNameField.text= @"";
        
        NSString* ownerFieldString = [NSString stringWithFormat:@"Owned By Player: %d", tile.pColor];
        _ownerField.text = ownerFieldString;
        
        NSString* homeCoordString = [NSString stringWithFormat:@"Coordinates: %.01f, %.01f", tile.x/54, tile.y/40];
        _homeCoordField.text = homeCoordString;
        
        NSString* woodString = [NSString stringWithFormat:@"Wood: %d", v.woodPile];
        _woodField.text = woodString;
        
        NSString* goldString = [NSString stringWithFormat:@"Gold: %d", v.goldPile];
        _goldField.text = goldString;
        
    }
    
    //who is the unit and all its stats, workstate
    //if you click a village then put up how many tiles the village has
}

- (void)endTurnTouched:(SPTouchEvent*) event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSLog(@"End turn pressed");
        GHEvent *event = [[GHEvent alloc] initWithType:EVENT_TYPE_TURN_ENDED];
        [self dispatchEvent:event];
    }
}


@end
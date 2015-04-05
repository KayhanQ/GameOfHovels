
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
    
    SPButton* _village1, *_village2, *_leftButton, *_rightButton, *_settingsButton;
    
    SPButton* _endTurnButton;
    
    NSMutableArray * listOfVillages;
    
    Tile * villageTile1, *villageTile2;
    
    SPImage *village1Picture;
    SPTexture * _buttonTexture; //TEST
    
    //unit
    SPTextField* _woodField;
    SPTextField* _goldField;
    SPTextField* _upkeepField;
    SPTextField* _unitNameField;
    //village
    SPTextField* _healthField;
    SPTextField* _numTilesInRegion;
    SPTextField* _homeCoordField;
    //universal
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
        
        listOfVillages = [map getTilesWithMyVillages];
        
        _height = 380;
        _width = 130;
        _yOffsetMinor = 3;
        
        SPImage* background = [SPImage imageWithContentsOfFile:@"hudpanel.png"];
        
        SPSprite* sprite = [SPSprite sprite]; //container for ui elements
        
        background.width = _width;
        background.height = _height + 4;
        
        [self addChild:background];
        
        _middleX = _width/2;
        SPTexture* buttonTexture = [SPTexture textureWithContentsOfFile:@"endturn.png"];
        _buttonTexture = buttonTexture;
     //   SPTexture* buttonTexture = [SPTexture textureWithContentsOfFile:@"blankButton.png"];
        
        
        //
        _settingsButton = [SPButton buttonWithUpState:buttonTexture];
        _settingsButton.y = 0;
        _settingsButton.height = 20; //Just Some magic number
        _settingsButton.width = background.width - 10;
        [sprite addChild:_settingsButton];
        
        
        _village1 = [SPButton buttonWithUpState:buttonTexture];
        _village1.x = 7;
        _village1.height = 100; //Just Some magic number
        _village1.width = background.width - 10;
        
        
        _village2 = [SPButton buttonWithUpState:buttonTexture];
        _village2.x = 7;
        _village2.height = 100; //Just Some magic number
         _village2.width = background.width - 10;
        
        //
        _village1.y = 20;
        
        village1Picture = [SPImage imageWithContentsOfFile:@"fort.png"];
        village1Picture.height = 40;
        village1Picture.width = 40;
        [_village1 addChild:village1Picture];
        
        [sprite addChild:_village1];
        
        
        
        _village2.y = _village1.y +90;
        [sprite addChild:_village2];
        
        _leftButton = [SPButton buttonWithUpState:buttonTexture];
        _leftButton.x = 7;
        _leftButton.y = _village2.y + 90;
        _leftButton.width = 50;
        _leftButton.height = 50;
        [sprite addChild:_leftButton];
        [_leftButton addEventListener:@selector(leftButtonTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        
        _rightButton = [SPButton buttonWithUpState:buttonTexture];
        _rightButton.x = _leftButton.x + 70;
        _rightButton.y = _leftButton.y;
        _rightButton.width = _leftButton.width;
        _rightButton.height = _leftButton.height;
        [sprite addChild:_rightButton];
        [_rightButton addEventListener:@selector(rightButtonTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];


        
        
        
        [self addChild:sprite];
        
        
        _endTurnButton = [SPButton buttonWithUpState:buttonTexture];
        
        _endTurnButton.height = 50; //Just Some magic number
        _endTurnButton.width = 110;
        
        [SparrowHelper centerPivot:_endTurnButton];
        
        _endTurnButton.x = _middleX;
        _endTurnButton.y = _height - _endTurnButton.height + 20;
        
        [self addChild:_endTurnButton];
        [_endTurnButton addEventListener:@selector(endTurnTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        
        [self initVillageFields];
        [self initUnitFields];
        
        
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

- (void)leftButtonTouched:(SPTouchEvent*) event
{
    NSLog(@"leftButton Touched");
    village1Picture.texture = _buttonTexture;
}

- (void)rightButtonTouched:(SPTouchEvent*) event
{
    NSLog(@"rightButton Touched");
}

- (void)initUnitFields{
    //Unit Info--------- ADD TO METHOD
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

-(void) initVillageFields{
    //Village Info------- ADD TO METHOD
    _woodField = [self newTextField];
    //_woodField.text = @"Wood: ";
    _woodField.y = 290;
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
}



@end
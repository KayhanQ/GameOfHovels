
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
    
    SPSprite* sprite;
    
    SPPoint * _center;
    
    SPButton* _village1, *_village2, *_leftButton, *_rightButton, *_settingsButton;
    
    SPButton* _endTurnButton;
    
    NSMutableArray * _listOfVillages;
    
    Tile * _villageTile1, *_villageTile2;
    SPTextField* _woodField1, *_goldField1,*_healthField1, *_woodField2, *_goldField2, *_healthField2;

    SPImage* _village1Icon, *_village2Icon;
    
    int village1Index, village2Index;
    SPTexture * _hovelTexture, *_townTexture, *_fortTexture, *_castleTexture;
    
    SPSprite* _world; //ADDED
    
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

-(id)initWithMap:(Map *)map world:(SPSprite*)world
{
    if (self=[super init]) {
        //custom code here
        
        //_player = player;
        _map = map;
        _world = world;
        
        sprite = [SPSprite sprite];//background
        
        _center.y = _world.height/2;
        _center.x = _world.width/2;
        
        _listOfVillages = [map getTilesWithMyVillages];
        village1Index = 0;
        village2Index = 1;
        
        _height = 380;
        _width = 130;
        _yOffsetMinor = 3;
    
        
        [self initButtons];
        [self initVillageFields];
        [self initTextures];
        [self initUITool];
        [self initUnitFields];
        [self updateUITool];
        
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
        
        _woodField.text = @"";
        _goldField.text = @"";
        _healthField.text = @"";
        
        Tile * villageTile = [_map getVillageTile: tile.village];
       // NSString* ownerFieldString = [NSString stringWithFormat:@"Owned By Player: %d", tile.pColor];
       // _ownerField.text = ownerFieldString;
        
        NSString* homeCoordString = [NSString stringWithFormat:@"Home Coordinates: %.01f, %.01f",villageTile.x/54, villageTile.y/40];
        _homeCoordField.text = homeCoordString;
        
        NSString* unitNameString = [NSString stringWithFormat:@"Unit Type: %u", unit.uType];
        _unitNameField.text = unitNameString;
        
        NSString* upkeepString = [NSString stringWithFormat:@"Upkeep: %d", unit.upkeepCost];
        _upkeepField.text = upkeepString;
        
        
        
    }
    
    else if(tile.hasVillage){ //put village stats here
        
        Village* v = tile.village;
        
     //   NSString* ownerFieldString = [NSString stringWithFormat:@"Owned By Player: %d", tile.pColor];
      //  _ownerField.text = ownerFieldString;
        
        
        _unitNameField.text = @"";
        _upkeepField.text = @"";
        
        NSString* homeCoordString = [NSString stringWithFormat:@"Coordinates: %.01f, %.01f", tile.x/54, tile.y/40];
        _homeCoordField.text = homeCoordString;
        
        NSString* woodString = [NSString stringWithFormat:@"Wood: %d", v.woodPile];
        _woodField.text = woodString;
        
        NSString* goldString = [NSString stringWithFormat:@"Gold: %d", v.goldPile];
        _goldField.text = goldString;
        
        NSString* healthString = [NSString stringWithFormat:@"Health: %d", v.health];
        _healthField.text = healthString;
        
    }
    
    [self updateUITool];
    
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
    
    village1Index = abs((village1Index -1) % [_listOfVillages count]); //CAREFUL ABOUT THIS
    village2Index= abs((village2Index -1) % [_listOfVillages count]);

    
    NSLog(@"The first village index: %d. The second: %d, total: %d", village1Index, village2Index, [_listOfVillages count] );

    _villageTile1 = [_listOfVillages objectAtIndex:village1Index];
    _villageTile2 =[_listOfVillages objectAtIndex:village2Index];
    
    [self updateUITool];

}

- (void)rightButtonTouched:(SPTouchEvent*) event
{
    NSLog(@"rightButton Touched");
    
    village1Index = abs((village1Index +1) % [_listOfVillages count]);
    village2Index= abs((village2Index +1) % [_listOfVillages count]);
    
   NSLog(@"The first village index: %d. The second: %d, total: %d", village1Index, village2Index, [_listOfVillages count] );
    _villageTile1 = [_listOfVillages objectAtIndex:village1Index];
    _villageTile2 =[_listOfVillages objectAtIndex:village2Index];
    
    [self updateUITool];
    
}

-(SPTexture*) getIcon:(Tile*)tile button:(SPButton*)button {
    
    int buildingType;
    
    buildingType = [tile getVillageType];
    
    SPTexture * returnedTexture;
    
    switch (buildingType) {
        case 1:
            NSLog(@"icon is a hovel");
            returnedTexture = _hovelTexture;
            break;
            
        case 2:
            NSLog(@"icon is a town");
            returnedTexture = _townTexture;
            break;
            
        case 3:
            NSLog(@"icon is a fort");
            returnedTexture = _fortTexture;
            //returnedTexture = _townTexture;
            break;
            
        case 4:
            NSLog(@"icon is a castle");
            returnedTexture = _castleTexture;
            break;
            
        default:
             NSLog(@"SOMETHING WENT WRONG");
            returnedTexture = _castleTexture;
            break;
    }
    
    return returnedTexture;
}


-(void) updateUITool
{
    
    if([sprite containsChild:_village1]){
    
        _village1Icon.texture = [self getIcon:_villageTile1 button:_village1];
    Village* v = _villageTile1.village;
    
    NSString* woodString = [NSString stringWithFormat:@"Wood: %d", v.woodPile];
    _woodField1.text = woodString;
    
    NSString* goldString = [NSString stringWithFormat:@"Gold: %d", v.goldPile];
    _goldField1.text = goldString;
    
    NSString* healthString = [NSString stringWithFormat:@"Health: %d", v.health];
    _healthField1.text = healthString;
    
        
        if([sprite containsChild:_village2]){
            //Check to see if village2 even exists
            _village2Icon.texture =[self getIcon:_villageTile2 button:_village2];
            Village* v = _villageTile2.village;
            
            NSString* woodString = [NSString stringWithFormat:@"Wood: %d", v.woodPile];
            _woodField2.text = woodString;
            
            NSString* goldString = [NSString stringWithFormat:@"Gold: %d", v.goldPile];
            _goldField2.text = goldString;
            
            NSString* healthString = [NSString stringWithFormat:@"Health: %d", v.health];
            _healthField2.text = healthString;
        }
    }
    

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
    _woodField.y = 290;
    [self addChild:_woodField];
    
    _goldField = [self newTextField];
    _goldField.y = _woodField.y + _woodField.height + _yOffsetMinor;
    [self addChild:_goldField];
    
    _healthField = [self newTextField];
    _healthField.y =_woodField.y - 2*_woodField.height - _yOffsetMinor;
    [self addChild:_healthField];
    
    _numTilesInRegion = [self newTextField];
    _numTilesInRegion.y = _healthField.y + _healthField.height + _yOffsetMinor;
    [self addChild:_numTilesInRegion];
}

-(void) initTextures{
    
    _hovelTexture = [SPTexture textureWithContentsOfFile:@"hovel.png"];
    _townTexture = [SPTexture textureWithContentsOfFile:@"town.png"];
    _fortTexture =[SPTexture textureWithContentsOfFile:@"fort.png"];
    _castleTexture =[SPTexture textureWithContentsOfFile:@"castle.png"];
    
}

-(void) initButtons{
    
    
    SPImage* background = [SPImage imageWithContentsOfFile:@"hudpanel.png"];
    background.width = _width;
    background.height = _height + 4;
    
    [self addChild:background];
    
     //container for ui elements
    

    _middleX = _width/2;
    SPTexture* endTurnTexture = [SPTexture textureWithContentsOfFile:@"endturn.png"];
    SPTexture* buttonTexture = [SPTexture textureWithContentsOfFile:@"blankButton.png"];
    
    
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
    
    /*
    village1Picture = [SPImage imageWithContentsOfFile:@"fort.png"];
    village1Picture.height = 40;
    village1Picture.width = 40;
    [_village1 addChild:village1Picture];
    */
    
    [sprite addChild:_village1];
    
    [_village1 addEventListener:@selector(village1Touched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];

 
    _village2.y = _village1.y +90;
    [sprite addChild:_village2];
     [_village2 addEventListener:@selector(village2Touched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
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
    
    
    _endTurnButton = [SPButton buttonWithUpState:endTurnTexture];
    
    _endTurnButton.height = 50; //Just Some magic number
    _endTurnButton.width = 110;
    
    [SparrowHelper centerPivot:_endTurnButton];
    
    _endTurnButton.x = _middleX;
    _endTurnButton.y = _height - _endTurnButton.height + 20;
    
    [self addChild:_endTurnButton];
    [_endTurnButton addEventListener:@selector(endTurnTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
}

-(void) initUITool
{
    if([_listOfVillages count] >= 2){
        _villageTile1 = [_listOfVillages objectAtIndex:village1Index];
        _villageTile2 = [_listOfVillages objectAtIndex:village2Index];
        
        //Init profile pics and info here.
        
        _village1Icon = [SPImage imageWithContentsOfFile:@"fort.png"];
        _village1Icon.texture = [self getIcon:_villageTile1 button:_village1];
        _village1Icon.height = 40;
        _village1Icon.width = 40;
        _village1Icon.x = 10;
        _village1Icon.y = 25;
        [_village1 addChild:_village1Icon];
        
        _woodField1 = [self newTextField];
        _woodField1.y = 30;
        _woodField1.text = @"Wood: ";
        [_village1 addChild:_woodField1];
        
        _goldField1 = [self newTextField];
        _goldField1.text = @"Gold: ";
        _goldField1.y = _woodField1.height + _woodField1.y;
        [_village1 addChild:_goldField1];
        
        _healthField1 = [self newTextField];
        _healthField1.text = @"Health: ";
        _healthField1.y = _goldField1.height + _goldField1.y;
        [_village1 addChild:_healthField1];
        
        
        
        _village2Icon = [SPImage imageWithContentsOfFile:@"fort.png"];
        _village2Icon.texture = [self getIcon:_villageTile2 button:_village2];
        _village2Icon.height = 40;
        _village2Icon.width = 40;
        _village2Icon.x = 10;
        _village2Icon.y = 25;
        [_village2 addChild:_village2Icon];
  
        _woodField2 = [self newTextField];
        _woodField2.y = _woodField1.y;
         _woodField2.text = @"Wood: ";
        [_village2 addChild:_woodField2];
        
        _goldField2 = [self newTextField];
         _goldField2.text = @"Gold: ";
        _goldField2.y = _woodField2.height + _woodField2.y;
        [_village2 addChild:_goldField2];
        
        _healthField2 = [self newTextField];
        _healthField2.text = @"Health: ";
        _healthField2.y = _goldField2.height + _goldField2.y;
        [_village2 addChild:_healthField2];
        
        
        
        
    }
    else if([_listOfVillages count] == 1)
    {
        
        _villageTile1 = [_listOfVillages objectAtIndex:village1Index];
        [sprite removeChild:_village2];
        
        _village1Icon = [SPImage imageWithContentsOfFile:@"fort.png"];
        _village1Icon.texture = [self getIcon:_villageTile1 button:_village1];
        _village1Icon.height = 40;
        _village1Icon.width = 40;
        _village1Icon.x = 10;
        _village1Icon.y = 25;
        [_village1 addChild:_village1Icon];
        
        _woodField1 = [self newTextField];
        _woodField1.y = 30;
        _woodField1.text = @"Wood: ";
        [_village1 addChild:_woodField1];
        
        _goldField1 = [self newTextField];
        _goldField1.text = @"Gold: ";
        _goldField1.y = _woodField1.height + _woodField1.y;
        [_village1 addChild:_goldField1];
        
        _healthField1 = [self newTextField];
        _healthField1.text = @"Health: ";
        _healthField1.y = _goldField1.height + _goldField1.y;
        [_village1 addChild:_healthField1];
   
        
    }
    
    else if([_listOfVillages count] ==0){
        [sprite removeChild:_village1];
        [sprite removeChild:_village2];
    }
    
}

-(void)village1Touched:(SPTouchEvent*) event
{
    
    _world.x = _villageTile1.x - 300;
    _world.y =_villageTile1.y- 300;
    
}


-(void)village2Touched:(SPTouchEvent*) event
{
    
   // _world.x = _villageTile2.x - 300;
    //_world.y =_villageTile2.y - 300;
    
    _world.x = _center.x + _villageTile2.x;
    _world.y = _center.y + _villageTile2.y;
  
}

@end
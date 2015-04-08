
//
//  Hud.m
//  GameOfHovels
//
//  Created by Kayhan Feroze Qaiser on 19/02/2015.
//  Copyright (c) 2015 CivetAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hud.h"
#import "GHEvent.h"
#import "TranslateWorldEvent.h"
#import "SparrowHelper.h"
#import "Tile.h"
#import "Village.h"
#import "GameEngine.h"
#import "Map.h"
#import "MessageLayer.h"

@implementation Hud {
    
    SPSprite* sprite;
    SPPoint * _center;
    SPButton* _village1, *_village2, *_leftButton, *_rightButton, *_settingsButton;
    
    SPButton* _endTurnButton;
    
    SPButton* _saveGameButton;
    
    NSMutableArray * _listOfVillages;
    
    Tile * _villageTile1, *_villageTile2;
    SPTextField* _woodField1, *_goldField1,*_healthField1, *_homeCoordField1, *_woodField2, *_goldField2, *_healthField2, *_homeCoordField2;
    
    SPButton* _nextVillageButton, *_quitButton;
    
    
    SPImage* _village1Icon, *_village2Icon;
    
    int village1Index, village2Index;
    SPTexture * _hovelTexture, *_townTexture, *_fortTexture, *_castleTexture, * _destroyedTexture;
    
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
    
    Tile* _currentTile;
    
    MessageLayer* _messageLayer;
    
    int _yOffsetMinor;
    float _middleX;
    float _height;
    float _width;
}

//@synthesize player = _player;

-(id)initWithMap:(Map *)map
{
    if (self=[super init]) {
        //custom code here
        
        //_player = player;
        _map = map;
        
        sprite = [SPSprite sprite];//background
        
        _center.y = _world.height/2;
        _center.x = _world.width/2;
        
        _listOfVillages = [map getTilesWithMyVillages];
        village1Index = 0;
        village2Index = 1;
        
        _messageLayer = [MessageLayer sharedMessageLayer];
        
        _height = 380;
        _width = 130;
        
        _yOffsetMinor = 3;
        
        
        [self initButtons];
        [self initVillageFields];
        [self initTextures];
        [self initUITool];
        [self initUnitFields];
        [self updateUITool];
        
        _middleX = _width/2;
        
    }
    
    return self;
}

- (SPButton*)newButton
{
    SPTexture* buttonTexture = [SPTexture textureWithContentsOfFile:@"button.png"];
    SPButton* button = [SPButton buttonWithUpState:buttonTexture];
    [SparrowHelper centerPivot:button];
    button.x = _middleX;
    button.scale = 0.4;
    return button;
}

- (SPTextField*)newTextField
{
    SPTextField* t = [SPTextField textFieldWithWidth:_width height:15 text:@""];
    t.x = _middleX;
    t.fontSize = 12;
    
    [SparrowHelper centerPivot:t];
    //[_uiElementsSprite addChild:t];
    return t;
}

- (void)update:(Tile *)tile
{
    
    _currentTile = tile;
    Village* v = tile.village;
    
    NSString* woodString = [NSString stringWithFormat:@"Wood: %d", v.woodPile];
    _woodField.text = woodString;
    
    NSString* goldString = [NSString stringWithFormat:@"Gold: %d", v.goldPile];
    _goldField.text = goldString;
    
    
    if(tile.hasUnit){ // put unit stats here: unit type, unit upkeep, owning village
        
        NSLog(@"Has unit");
        
        Unit* unit = [tile getUnit];
        
        _woodField.text = @"";
        _goldField.text = @"";
        _healthField.text = @"";
        _numTilesInRegion.text = @"";
        
        Tile * villageTile = [_map getVillageTile: tile.village];
        // NSString* ownerFieldString = [NSString stringWithFormat:@"Owned By Player: %d", tile.pColor];
        // _ownerField.text = ownerFieldString;
        
        NSString* homeCoordString = [NSString stringWithFormat:@"Home Coord: %.01f, %.01f",villageTile.x/54, villageTile.y/40];
        _homeCoordField.text = homeCoordString;
        
        NSString* unitNameString = [NSString stringWithFormat:@"Unit Type: %u", unit.uType];
        _unitNameField.text = unitNameString;
        
        NSString* upkeepString = [NSString stringWithFormat:@"Upkeep: %d", unit.upkeepCost];
        _upkeepField.text = upkeepString;
        
        
        
    }
    
    else if(tile.hasVillage){ //put village stats here
        
        Village* v = tile.village;
        
        int tCount = [_map getTilesforVillage:v].count;
        NSString* _numTilesInRegionString = [NSString stringWithFormat:@"Numb Tiles: %d", tCount];
        _numTilesInRegion.text = _numTilesInRegionString;
        
        
        _unitNameField.text = @"";
        _upkeepField.text = @"";
        _homeCoordField.text = @"";
        
        //NSString* homeCoordString = [NSString stringWithFormat:@"Coordinates: %.01f, %.01f", tile.x/54, tile.y/40];
        //_homeCoordField.text = homeCoordString;
        
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

- (void)nextVillageTouched:(SPTouchEvent*) event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSMutableArray* villageTiles = [_map getTilesWithMyVillages];
        Tile* tileToGoTo = nil;
        
        if (villageTiles == nil) return;
        
        tileToGoTo = [villageTiles objectAtIndex:0];
        for (int i = 0; i<villageTiles.count-1; i++) {
            Tile* vTile = [villageTiles objectAtIndex:i];
            if (_currentTile == vTile) {
                if (i == villageTiles.count-1) {
                    tileToGoTo = [villageTiles objectAtIndex:0];
                    break;
                }
                else {
                    tileToGoTo = [villageTiles objectAtIndex:i+1];
                    break;
                }
            }
        }
        _currentTile = tileToGoTo;
        
        if (_currentTile != nil) {
            SPPoint* localPoint = [SPPoint pointWithX:tileToGoTo.x y:tileToGoTo.y];
            TranslateWorldEvent* event = [[TranslateWorldEvent alloc] initWithType:EVENT_TYPE_TRANSLATE_WORLD point:localPoint];
            [self dispatchEvent:event];
        }
    }
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
    [self updateUITool];
}


- (void)saveGameTouched:(SPTouchEvent*) event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        GHEvent *event = [[GHEvent alloc] initWithType:EVENT_TYPE_SAVE_GAME];
        [self dispatchEvent:event];
    }
}


- (void)leftButtonTouched:(SPTouchEvent*) event
{
    
    [self updateUITool];
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if(touch){
        NSLog(@"leftButton Touched");
        
        if([_listOfVillages count] > 0){
            
            village1Index = (village1Index)-1 % [_listOfVillages count];
            if(village1Index < 0) village1Index += [_listOfVillages count];
            
            village2Index = (village1Index)-1 % [_listOfVillages count];
            if(village2Index < 0) village2Index += [_listOfVillages count];
            
            NSLog(@"The first village index: %d. The second: %d, total: %d", village1Index, village2Index, [_listOfVillages count] );
            _villageTile1 = [_listOfVillages objectAtIndex:village1Index];
            _villageTile2 =[_listOfVillages objectAtIndex:village2Index];
            
            [self updateUITool];
        }
    }
}

- (void)rightButtonTouched:(SPTouchEvent*) event
{
    
    [self updateUITool];
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if(touch){
        NSLog(@"rightButton Touched");
        
        if([_listOfVillages count] > 0){
            
            village1Index = abs((village1Index +1) % [_listOfVillages count]);
            village2Index= abs((village1Index +1) % [_listOfVillages count]);
            
            NSLog(@"The first village index: %d. The second: %d, total: %d", village1Index, village2Index, [_listOfVillages count] );
            _villageTile1 = [_listOfVillages objectAtIndex:village1Index];
            _villageTile2 =[_listOfVillages objectAtIndex:village2Index];
            
            [self updateUITool];
        }
    }
}

-(SPTexture*) getIcon:(Tile*)tile button:(SPButton*)button {
    
    int buildingType;
    
    buildingType = [tile getVillageType];
    
    SPTexture * returnedTexture;
    
    switch (buildingType) {
        case 1:
            returnedTexture = _hovelTexture;
            break;
            
        case 2:
            returnedTexture = _townTexture;
            break;
            
        case 3:
            returnedTexture = _fortTexture;
            //returnedTexture = _townTexture;
            break;
            
        case 4:
            returnedTexture = _castleTexture;
            break;
            
        default:
            returnedTexture = _destroyedTexture;
            NSLog(@"SOMETHING WENT WRONG");
            break;
    }
    
    return returnedTexture;
}


-(void) updateUITool
{
    
    _listOfVillages = [_map getTilesWithMyVillages];
    
    if([sprite containsChild:_village1] && [_listOfVillages count] != 0){
        
        _village1Icon.texture = [self getIcon:_villageTile1 button:_village1];
        Village* v = _villageTile1.village;
        
        NSString* woodString = [NSString stringWithFormat:@"Wood: %d", v.woodPile];
        _woodField1.text = woodString;
        
        NSString* goldString = [NSString stringWithFormat:@"Gold: %d", v.goldPile];
        _goldField1.text = goldString;
        
        NSString* healthString = [NSString stringWithFormat:@"Health: %d", v.health];
        _healthField1.text = healthString;
        
        NSString* homeCoordString1 = [NSString stringWithFormat:@"Coordinates: %.01f, %.01f", _villageTile1.x/54, _villageTile1.y/40];
        _homeCoordField1.text = homeCoordString1;
        
        
        if([sprite containsChild:_village2] && [_listOfVillages count] > 1){
            //Check to see if village2 even exists
            _village2Icon.texture =[self getIcon:_villageTile2 button:_village2];
            Village* v = _villageTile2.village;
            
            NSString* woodString = [NSString stringWithFormat:@"Wood: %d", v.woodPile];
            _woodField2.text = woodString;
            
            NSString* goldString = [NSString stringWithFormat:@"Gold: %d", v.goldPile];
            _goldField2.text = goldString;
            
            NSString* healthString = [NSString stringWithFormat:@"Health: %d", v.health];
            _healthField2.text = healthString;
            
            NSString* homeCoordString2 = [NSString stringWithFormat:@"Coordinates: %.01f, %.01f", _villageTile2.x/54, _villageTile2.y/40];
            _homeCoordField2.text = homeCoordString2;
            
            
        }
        else {
            
            [sprite removeChild: _village2];
            
        }
    } else {
        
        [sprite removeChild:_village1];
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
    _destroyedTexture = [SPTexture textureWithContentsOfFile:@"tombstone.png"];
    
    
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
    
    
    /* Settings Button
     _settingsButton = [SPButton buttonWithUpState:buttonTexture];
     _settingsButton.y = 0;
     _settingsButton.height = 20; //Just Some magic number
     _settingsButton.width = background.width - 10;
     [sprite addChild:_settingsButton];
     */
    
    
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
    
    
    
    /* Settings Button
     _settingsButton = [SPButton buttonWithUpState:buttonTexture];
     _settingsButton.y = 0;
     _settingsButton.height = 20; //Just Some magic number
     _settingsButton.width = background.width - 10;
     [sprite addChild:_settingsButton];
     */
    
    SPTexture* saveButtonTexture = [SPTexture textureWithContentsOfFile:@"blankButton.png"];
    _saveGameButton = [SPButton buttonWithUpState:saveButtonTexture];
    _saveGameButton.text = @"Save Game";
    _saveGameButton.height = 20; //Just Some magic number
    _saveGameButton.width = background.width - 10;
    
    SPRectangle * bounds= [SPRectangle rectangleWithX:-31 y:-8 width:_saveGameButton.width height:_saveGameButton.height];
    
    _saveGameButton.textBounds = bounds;
    //[SparrowHelper centerPivot:_saveGameButton];
    _saveGameButton.y = 1;
    _saveGameButton.x = 5;
    
    [sprite addChild:_saveGameButton];
    [_saveGameButton addEventListener:@selector(saveGameTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
    SPTexture* quitGameTexutre = [SPTexture textureWithContentsOfFile:@"blankButton.png"];
    _quitButton = [SPButton buttonWithUpState:quitGameTexutre];
    _quitButton.text = @"Quit";
    _quitButton.height = 30; //Just Some magic number
    _quitButton.width = background.width - 40;
    _quitButton.x = 420;
    SPRectangle * quitbounds= [SPRectangle rectangleWithX:-30 y:-10 width:_quitButton.width height:_quitButton.height];
    _quitButton.textBounds = quitbounds;
    
    [sprite addChild:_quitButton];
    [_quitButton addEventListener:@selector(quitTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
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
        _woodField1.x = 80 ;
        _woodField1.text = @"Wood: ";
        [_village1 addChild:_woodField1];
        
        _goldField1 = [self newTextField];
        _goldField1.text = @"Gold: ";
        _goldField1.y = _woodField1.height + _woodField1.y;
        _goldField1.x = _woodField1.x;
        [_village1 addChild:_goldField1];
        
        _healthField1 = [self newTextField];
        _healthField1.text = @"Health: ";
        _healthField1.y = _goldField1.height + _goldField1.y;
        _healthField1.x = _woodField1.x;
        [_village1 addChild:_healthField1];
        
        _homeCoordField1 = [self newTextField];
        _homeCoordField1.text = @"Coordinates: ";
        _homeCoordField1.y = _healthField1.y + _healthField1.height;
        _homeCoordField1.fontSize = 10;
        _homeCoordField1.x = 60;
        [_village1 addChild:_homeCoordField1];
        
        
        
        _village2Icon = [SPImage imageWithContentsOfFile:@"fort.png"];
        _village2Icon.texture = [self getIcon:_villageTile2 button:_village2];
        _village2Icon.height = 40;
        _village2Icon.width = 40;
        _village2Icon.x = 10;
        _village2Icon.y = 25;
        [_village2 addChild:_village2Icon];
        
        _woodField2 = [self newTextField];
        _woodField2.y = _woodField1.y;
        _woodField2.x = _woodField1.x;
        _woodField2.text = @"Wood: ";
        [_village2 addChild:_woodField2];
        
        _goldField2 = [self newTextField];
        _goldField2.text = @"Gold: ";
        _goldField2.y = _woodField2.height + _woodField2.y;
        _goldField2.x = _goldField1.x;
        [_village2 addChild:_goldField2];
        
        _healthField2 = [self newTextField];
        _healthField2.text = @"Health: ";
        _healthField2.y = _goldField2.height + _goldField2.y;
        _healthField2.x = _healthField1.x;
        [_village2 addChild:_healthField2];
        
        _homeCoordField2 = [self newTextField];
        _homeCoordField2.text = @"Coordinates: ";
        _homeCoordField2.y = _healthField2.y + _goldField2.height;
        _homeCoordField2.x = 60;
        _homeCoordField2.fontSize = 10;
        [_village2 addChild:_homeCoordField2];
        
        
        
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
        
        _homeCoordField1 = [self newTextField];
        _homeCoordField1.text = @"Coordinates: ";
        _homeCoordField1.y = _healthField1.y + _healthField1.height;
        _homeCoordField1.x = 60;
        _homeCoordField1.fontSize = 10;
        [_village1 addChild:_homeCoordField2];
        
        
    }
    
    else if([_listOfVillages count] ==0){
        [sprite removeChild:_village1];
        [sprite removeChild:_village2];
    }
    
}

-(void)village1Touched:(SPTouchEvent*) event
{
    
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        SPPoint* localPoint = [SPPoint pointWithX:_villageTile1.x y:_villageTile1.y];
        TranslateWorldEvent* event = [[TranslateWorldEvent alloc] initWithType:EVENT_TYPE_TRANSLATE_WORLD point:localPoint];
        [self dispatchEvent:event];
    }
}


-(void)village2Touched:(SPTouchEvent*) event
{
    
    
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        
        SPPoint* localPoint = [SPPoint pointWithX:_villageTile2.x y:_villageTile2.y];
        TranslateWorldEvent* event = [[TranslateWorldEvent alloc] initWithType:EVENT_TYPE_TRANSLATE_WORLD point:localPoint];
        [self dispatchEvent:event];
    }
}

- (void)quitTouched:(SPTouchEvent*) event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touch)
    {
        NSLog(@"Quit Touched");
    }
}

@end
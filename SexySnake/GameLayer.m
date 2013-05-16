//
//  GameLayer.m
//  SexySnake
//
//  Created by LCR on 5/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"
#import "SSSnake.h"
#import "SSMap.h"
#import "MainScreenLayer.h"
#import "JSONKit.h"


@implementation GameLayer

+ (CCScene *)sceneOf1P
{
    NSLog(@"enter 1P mode");
    return [GameLayer sceneWithMode:SINGLE_PLAYER];
}

+ (CCScene *)sceneOf2P
{
    NSLog(@"enter 2P mode");
    [[SSConnectionManager sharedManager] determineServer];
    return [GameLayer sceneWithMode:MULTI_PLAYER];
}

+ (CCScene *)sceneWithMode:(Mode)mode;
{
    CCScene *scene = [CCScene node];
    GameLayer *gameLayer = [GameLayer node];
    gameLayer.mode = mode;
    [scene addChild:gameLayer];
    return scene;
}

- (id)init
{
    if ((self = [super init])) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        isTouchEnabled_ = YES;
        
        // Create label for motion data
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(size.width / 2, size.height / 2);
//        [self addChild:background];
        
//        _label = [CCLabelTTF labelWithString:@"Hello World!" fontName:@"Helvetica" fontSize:20];
//        _label.position = ccp(size.width / 2, size.height - 40);
//        _label.color = ccc3(255, 0, 0);
        
//        [self addChild:_label];
        
        [self createPauseMenu];
        
        
        CCSprite *mapSprite = [CCSprite spriteWithFile:@"map.png"];
        mapSprite.position = ccp(size.width / 2 - 50, size.height / 2 - 40 );
        [self addChild:mapSprite];
        
        [[Const sharedConst] setMapStartingX:mapSprite.position.x - mapSprite.boundingBox.size.width / 2];
        [[Const sharedConst] setMapStartingY:mapSprite.position.y + mapSprite.boundingBox.size.height / 2];
                
        // Configure motion manager
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 15.0 / 60.0;
        
        if (_motionManager.isDeviceMotionAvailable)
            [_motionManager startDeviceMotionUpdates];

        
        [self schedule:@selector(updateDeviceMotion:) interval:0.05f repeat:kCCRepeatForever delay:0.0f];

        
        // set SSConnectionManager delegate
        [SSConnectionManager sharedManager].delegate = self;
        
        // set map
        _map = [[SSMap alloc] init];
        _map.gameLayer = self;
        

        // testing wall
        //[_map wallIsBuiltAt:[Grid gridWithRow:0 Col:0]];
        
        // setup counter
        _counter = 3;
        
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playEffect:@"countdown.mp3"];
        [self schedule:@selector(countdown:) interval:1.0f repeat:4 delay:2.0f];
//        [self startGame];
        
        _bigBullets = [NSMutableArray array];
        
    }
    return self;
}

#pragma mark - Motion control methods

// set direction of mySnake
- (void)updateDeviceMotion:(ccTime)delta
{
    CMDeviceMotion *currentDeviceMotion = _motionManager.deviceMotion;
    CMAttitude *currentAttitude = currentDeviceMotion.attitude;
    
    float roll = currentAttitude.roll;
    float pitch = currentAttitude.pitch;
    float yaw = currentAttitude.yaw;
    
//    [_label setString:[NSString stringWithFormat:@"roll:%.2f  pitch:%.2f  yaw:%.2f",
//                       CC_RADIANS_TO_DEGREES(roll), CC_RADIANS_TO_DEGREES(pitch), CC_RADIANS_TO_DEGREES(yaw)]];
    
    float componentX = - CC_RADIANS_TO_DEGREES(pitch) * 20;
    float componentY = - CC_RADIANS_TO_DEGREES(roll) * 20;
    
    if (abs(componentX) > abs(componentY)) {
        if (componentX > 0) _mySnake.direction = RIGHT;
        else _mySnake.direction = LEFT;
    } else {
        if (componentY > 0) _mySnake.direction = UP;
        else _mySnake.direction = DOWN;
    }
}

- (void)updateMySnakePosition:(ccTime)delta
{
    [_mySnake move];
}

- (void)updateOtherSnakePosition:(ccTime)delta
{
    [_otherSnake move];
    
}


# pragma mark - Update Server/Client Map 

- (void)setupInfoExchange
{
    if (_mode == MULTI_PLAYER) {
        if ([SSConnectionManager sharedManager].role == SERVER) {
            [self schedule:@selector(updateMapInfo:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
            [self schedule:@selector(sendSnakeInfoToClient:) interval:BASE_UPDATE_INTERVAL*5 repeat:kCCRepeatForever delay:0.0f];
            [self schedule:@selector(sendMapInfoToClinet:) interval:(BASE_UPDATE_INTERVAL)/10 repeat:kCCRepeatForever delay:0.0f];
        }
//        else{
//            [self schedule:@selector(updateClientMap:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
//            [self schedule:@selector(sendInfoToServer:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
//        }
        
    }
    else
        [self schedule:@selector(updateMapInfo:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
    
}

- (void)sendSnakeInfoToClient:(ccTime)delta
{
    NSArray *mySnakeArray = [Grid arrayForGrids:_mySnake.grids];
    NSString *mySnakeSent = [mySnakeArray JSONString];
    [[SSConnectionManager sharedManager] sendMessage:mySnakeSent forAction:ACTION_SEND_SERVER_SNAKE];
    NSArray *otherSnakeArray = [Grid arrayForGrids:_otherSnake.grids];
    NSString *otherSnakeSent = [otherSnakeArray JSONString];
    [[SSConnectionManager sharedManager] sendMessage:otherSnakeSent forAction:ACTION_SEND_CLIENT_SNAKE];
    
}

- (void)sendMapInfoToClinet:(ccTime)delta
{
    NSArray *mapArray = [_map mapToArray];
    NSString *mapSent = [mapArray JSONString];
    [[SSConnectionManager sharedManager] sendMessage:mapSent forAction:ACTION_SEND_MAP];
}


//- (void)sendInfoToServer:(ccTime)delta
//{
//
//}

- (void)updateMapInfo:(ccTime)delta
{
    if (!_startGenerateTarget) {
        _startGenerateTarget = YES;
        [_map spawnTarget];
    }
    
    if (!_startGenBulletTarget) {
        _startGenBulletTarget = YES;
        [_map spawnBulletTarget];
    }
    
    [_map updatePositionOfServerSnake:_mySnake.grids ClientSnake:_otherSnake.grids];
    
//    if (_mySnake.isShoot) {
//        [_map snakeShootsAt:[[_mySnake grids] objectAtIndex:0] WithDireciton:_mySnake.direction];
//        [_mySnake finishShooting];
//    }
//    
//    if (_otherSnake.isShoot) {
//        [_map snakeShootsAt:[[_otherSnake grids] objectAtIndex:0] WithDireciton:_otherSnake.direction];
//        [_otherSnake finishShooting];
//    }
    
    if (_mySnake.isBuilding) {
        //NSLog(@"mySnake builds");
        NSMutableArray *grids = [_mySnake grids];
        [_map wallIsBuiltAt:[grids objectAtIndex:[grids count]-1]];
        [_mySnake finishBuilding];
    }
    
    if (_otherSnake.isBuilding) {
        //NSLog(@"otherSnake builds");
        NSMutableArray *grids = [_otherSnake grids];
        [_map wallIsBuiltAt:[grids objectAtIndex:[grids count]-1]];
        [_otherSnake finishBuilding];
    }
    
//    [_map updatePositionOfBullet];
}


//- (void)updateClientMap:(ccTime)delta
//{
//    
//}



#pragma mark - SSConnectionManager delegate methods

- (void)connectionManager:(SSConnectionManager *)connectionManager didReceiveDictionary:(NSDictionary *)dictionary
{
    NSString *action = dictionary[JSONKeyAction];
    NSString *message = dictionary[JSONKeyMessage];
    CCLOG(@"Receive Message:[%@] %@", action, message);
    
    if ([action isEqualToString:ACTION_CHANGE_DIRECTION]) {
        [_otherSnake setDirectionFromRemote:[message intValue]];
        
    } else if ([action isEqualToString:ACTION_PAUSE_GAME]) {
        [self pauseGame];
        
    } else if ([action isEqualToString:ACTION_RESUME_GAME]) {
        [self resumeGame];
        
    } else if ([action isEqualToString:ACTION_QUIT_GAME]) {
        [self quitGame];
        
    } else if ([action isEqualToString:ACTION_SEND_SERVER_SNAKE]) {
        NSMutableArray *otherSankeArray = [message objectFromJSONString];
        [_otherSnake updateSnakeInfo:otherSankeArray];
        
    } else if ([action isEqualToString:ACTION_SEND_CLIENT_SNAKE]) {
        NSMutableArray *mySnakeArray = [message objectFromJSONString];
        [_mySnake updateSnakeInfo:mySnakeArray];
        
    } else if ([action isEqualToString:ACTION_SEND_MAP]){ 
        NSMutableArray *receivedArray = [message objectFromJSONString];
        //NSMutableArray *newMap = [SSMap arrayToMap:receivedArray];
        if ([SSConnectionManager sharedManager].role == CLIENT) {
            [_map oneDimensionArrayForMap:receivedArray];
            //[_map rerenderMap:newMap];
        }
    } else if ([action isEqualToString:ACTION_SHOOT]) {
        Grid *nextGrid = [Grid gridForDirection:_otherSnake.direction toGrid:_otherSnake.grids[0]];
        BulletSprite *bullet = [BulletSprite bulletWithPositionInGrid:nextGrid andDirection:_otherSnake.direction];
        bullet.delegate = self;
        [self addChild:bullet];
        [bullet fire];
    } else if ([action isEqualToString:ACTION_BUILDWALL]) {
        [_otherSnake buildWall];
    }
}


#pragma mark - Game flow methods

- (void)countdown:(ccTime)delta
{
    //[[SimpleAudioEngine sharedEngine] playEffect:@"countdown.mp3"];
    if (_counter < 0) {
        [self removeChild:_countdownSprite cleanup:YES];
        [self unschedule:@selector(countdown:)];
//        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"time machine.mp3"];
        [self startGame];
    } else {
        CGSize size = [[CCDirector sharedDirector] winSize];
        CGPoint center = ccp(size.width / 2, size.height / 2);
        if (_countdownSprite) [self removeChild:_countdownSprite cleanup:YES];
        _countdownSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"countdown-%d.png", _counter]];
        _countdownSprite.position = center;
        [self addChild:_countdownSprite];
        --_counter;
    }
}

- (void)startGame
{
    //[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"space_travel.mp3"];
    // Create local snake
    [self setupInfoExchange];
    
    Grid *grid;
    if ([SSConnectionManager sharedManager].role == SERVER)
        grid = [Grid gridWithRow:SERVER_ROW Col:SERVER_COL];
    else
        grid = [Grid gridWithRow:CLIENT_ROW Col:CLIENT_COL];

    
    _mySnake = [SSSnake mySnakeWithInitialGrid:grid];
    [self addChild:_mySnake];
    
    [self schedule:@selector(updateMySnakePosition:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
//    [self schedule:@selector(updateMapInfo:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
    _mySnake.gameLayer = self;

    if (_mode == MULTI_PLAYER) {
        Grid *grid;
        if ([SSConnectionManager sharedManager].role == SERVER)
            grid = [Grid gridWithRow:CLIENT_ROW Col:CLIENT_COL];
        else
            grid = [Grid gridWithRow:SERVER_ROW Col:SERVER_COL];
        
        _otherSnake =  [SSSnake otherSnakeWithInitialGrid:grid];
        [self addChild:_otherSnake];
        
        _otherSnake.gameLayer = self;
        
    }else
        [self schedule:@selector(updateMapInfo:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
    
    [self schedule:@selector(updateOtherSnakePosition:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
//    
//    if ([SSConnectionManager sharedManager].role == SERVER || [SSConnectionManager sharedManager].role == NONE)
//        [self schedule:@selector(updateMapInfo:) interval:0.1f repeat:kCCRepeatForever delay:0.0f];

    [self createScoreLabels];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background.mp3"];
}

- (void)endGame
{
    [self unscheduleAllSelectors];
    NSString *message;
    if (_mode == SINGLE_PLAYER) message = @"Yon Win!";
    else if (_mySnake.length == WIN_SNAKE_LENGTH) message = @"You Win!";
    else message = @"You Lost...";
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Finished!"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK!"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)pauseGame
{
    if (!_isPaused) {
        _isPaused = YES;
        if (!_pauseLayer) [self createPauseLayer];
        [self addChild:_pauseLayer];
        isTouchEnabled_ = NO;
        [self pauseSchedulerAndActions];
    }
}

- (void)resumeGame
{
    _isPaused = NO;
    isTouchEnabled_ = YES;
    [self removeChild:_pauseLayer cleanup:NO];
    [self resumeSchedulerAndActions];
}

- (void)restartGame
{
    
}

- (void)quitGame
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainScreenLayer scene] withColor:ccWHITE]];
}


#pragma mark - control UI methods

- (void)createScoreLabels
{
    CGSize size = [CCDirector sharedDirector].winSize;
    
    if (_mode == SINGLE_PLAYER) {
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:@"My Snake: 1" fontName:AmenaFontName fontSize:40];
        scoreLabel.position = ccp(120, size.height - 60);
        scoreLabel.color = ccc3(255, 255, 255);
        [self addChild:scoreLabel];
        _scoreLabels = [NSArray arrayWithObject:scoreLabel];
        
    } else {
        CCLabelTTF *myScoreLabel = [CCLabelTTF labelWithString:@"My Snake: 1" fontName:AmenaFontName fontSize:40];
        myScoreLabel.position = ccp(120, size.height - 60);
        myScoreLabel.color = ccc3(255, 255, 255);
        
        CCLabelTTF *otherScoreLabel = [CCLabelTTF labelWithString:@"That Snake: 1" fontName:AmenaFontName fontSize:40];
        otherScoreLabel.position = ccp(240, size.height - 60);
        otherScoreLabel.color = ccc3(255, 255, 255);
        
        [self addChild:myScoreLabel];
        [self addChild:otherScoreLabel];
        
        _scoreLabels = [NSArray arrayWithObjects:myScoreLabel, otherScoreLabel, nil];
    }
}

- (void)createPauseMenu
{
    CGSize size = [CCDirector sharedDirector].winSize;
    CCMenuItem *pauseItem = [CCMenuItemImage itemWithNormalImage:@"pause-button.png"  selectedImage:@"pause-button.png" block:^(id sender) {
        [self pauseGame];
        [[SSConnectionManager sharedManager] sendMessage:@"" forAction:ACTION_PAUSE_GAME];
    }];
    
    _shootItem = [CCMenuItemImage itemWithNormalImage:@"shoot-button.png" selectedImage:@"shoot-button-pressed.png" block:^(id sender) {
        CCLOG(@"Shoot Button pressed.");
        [_mySnake shoot];
    }];
    
    _shootItemDisabled = [CCMenuItemImage itemWithNormalImage:@"shoot-button-disabled.png" selectedImage:@"shoot-button-disabled.png"];
    
    
    _wallItem = [CCMenuItemImage itemWithNormalImage:@"build-wall-button.png" selectedImage:@"build-wall-button-pressed.png" block:^(id sender) {
        CCLOG(@"Build Wall Button pressed.");
        [_mySnake buildWall];
    }];
    
    _wallItemDisabled = [CCMenuItemImage itemWithNormalImage:@"build-wall-button-disabled.png" selectedImage:@"build-wall-button-disabled.png"];

 
    [self updateScoreLabelForSnake:_mySnake];
    
    CCMenu *menu = [CCMenu menuWithItems:pauseItem, nil];
    menu.position = ccp(size.width - 70, size.height - 60);
    [self addChild:menu];
    
    
    
    
    CCMenu *shootMenu = [CCMenu menuWithItems:_shootItemDisabled, _shootItem, nil];
    shootMenu.position = ccp(size.width - 70, 210);
    CCMenu *wallMenu = [CCMenu  menuWithItems:_wallItemDisabled, _wallItem, nil];
    wallMenu.position = ccp(size.width - 70, 100);
//    [weaponMenu alignItemsVerticallyWithPadding:20];
    [self addChild:shootMenu];
    [self addChild:wallMenu];
    
    for (int i = 0; i < MAX_BULLET_NUM; ++i) {
        CCSprite *normal = [CCSprite spriteWithFile:@"bullet-big.png"];
        normal.position = ccp(size.width - 70, 290 + 30 * i);
        CCSprite *disabled = [CCSprite spriteWithFile:@"bullet-big-disabled.png"];
        disabled.position = ccp(size.width - 70, 290 + 30 * i);
        [_bigBullets addObject:@[normal, disabled]];
        [self addChild:normal];
        [self addChild:disabled];
    }
    
   [self updateShootButton];
    
}


- (void)createPauseLayer
{
    CGSize size = [CCDirector sharedDirector].winSize;
    
    _pauseLayer = [CCLayerColor layerWithColor:ccc4(100, 100, 100, 200)];
    CCLabelTTF *pauseTitle = [CCLabelTTF labelWithString:@"Pause" fontName:AmenaFontName fontSize:48];
    pauseTitle.color = ccc3(255, 255, 255);
    pauseTitle.position = ccp(size.width / 2, size.height - 100);
    [_pauseLayer addChild:pauseTitle];
    
    CCMenuItem *resumeBtn = [CCMenuItemFont itemWithString:@"Resume" block:^(id sender) {
        [self resumeGame];
        [[SSConnectionManager sharedManager] sendMessage:@"" forAction:ACTION_RESUME_GAME];
    }];
    
    CCMenuItem *restartBtn = [CCMenuItemFont itemWithString:@"Restart" block:^(id sender) {

    }];
    
    CCMenuItem *quitBtn = [CCMenuItemFont itemWithString:@"Quit" block:^(id sender) {
        if (_mode == SINGLE_PLAYER) {
            [self quitGame];
        } else {
            // TODO
            // should ask another player
            [self quitGame];
            [[SSConnectionManager sharedManager] sendMessage:@"" forAction:ACTION_QUIT_GAME];
        }
    }];
        
    CCMenu *menu = [CCMenu menuWithItems:resumeBtn, restartBtn, quitBtn, nil];
    
    [menu alignItemsVerticallyWithPadding:80];
    menu.position = ccp(size.width / 2, size.height / 2);
    
    [_pauseLayer addChild:menu];
    


}

- (void)updateShootButton
{
    if (!_mySnake) {
        _shootItem.visible = NO;
        _shootItemDisabled.visible = YES;
        return;
    }
    
    if (_mySnake.numberOfBulletTarget == 0) {
        _shootItem.visible = NO;
        _shootItemDisabled.visible = YES;
    } else {
        _shootItemDisabled.visible = NO;
        _shootItem.visible = YES;
    }
    
    for (NSUInteger i = 0; i < MAX_BULLET_NUM; ++i) {
        if (i >= _mySnake.numberOfBulletTarget) {
            [_bigBullets[i][0] setVisible:NO];
            [_bigBullets[i][1] setVisible:YES];
        } else {
            [_bigBullets[i][0] setVisible:YES];
            [_bigBullets[i][1] setVisible:NO];
        }
    }
}

- (void)updateScoreLabelForSnake:(SSSnake *)snake
{
    if (snake == _mySnake) {
        ((CCLabelTTF *) _scoreLabels[0]).string = [NSString stringWithFormat:@"My Snake: %d", _mySnake.length];
        _wallItem.visible = (_mySnake.length > 1);
        _wallItemDisabled.visible = !_wallItem.visible;
    } else {
        ((CCLabelTTF *) _scoreLabels[1]).string = [NSString stringWithFormat:@"The Snake: %d", _otherSnake.length];
    }
    
    if (_mySnake.length == WIN_SNAKE_LENGTH || _otherSnake.length == WIN_SNAKE_LENGTH) [self endGame];
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self quitGame];
}

@end

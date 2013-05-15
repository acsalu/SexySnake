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

#define BASE_UPDATE_INTERVAL 0.3


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
        
        _label = [CCLabelTTF labelWithString:@"Hello World!" fontName:@"Helvetica" fontSize:20];
        _label.position = ccp(size.width / 2, size.height - 40);
        _label.color = ccc3(255, 0, 0);
        
        [self addChild:_label];
        
        [self createPauseMenu];
        
        
        CCSprite *mapSprite = [CCSprite spriteWithFile:@"map.png"];
        mapSprite.position = ccp(size.width / 2, size.height / 2);
        [self addChild:mapSprite];
        
        [[Const sharedConst] setMapStartingX:mapSprite.position.x - mapSprite.boundingBox.size.width / 2];
        [[Const sharedConst] setMapStartingY:mapSprite.position.y + mapSprite.boundingBox.size.height / 2];
                
        // Configure motion manager
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 30.0 / 60.0;
        
        if (_motionManager.isDeviceMotionAvailable)
            [_motionManager startDeviceMotionUpdates];
        

        if (_mode == MULTI_PLAYER) {
            if ([SSConnectionManager sharedManager].role ==  SEEK_CUR) {
                [self schedule:@selector(updateDeviceMotion:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
            }
            else{
                
            }
            
        }
        
        //[self schedule:@selector(updateDeviceMotion:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];

        
        // set SSConnectionManager delegate
        [SSConnectionManager sharedManager].delegate = self;
        
        // set map
        _map = [[SSMap alloc] init];
        _map.gameLayer = self;
        
        // setup counter
        _counter = 3;
//        [self schedule:@selector(countdown:) interval:1.0f];
        [self startGame];
        
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
    
    [_label setString:[NSString stringWithFormat:@"roll:%.2f  pitch:%.2f  yaw:%.2f",
                       CC_RADIANS_TO_DEGREES(roll), CC_RADIANS_TO_DEGREES(pitch), CC_RADIANS_TO_DEGREES(yaw)]];
    
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
    
    if (_mySnake.isShoot) {
        [_map snakeShootsAt:[[_mySnake grids] objectAtIndex:0] WithDireciton:_mySnake.direction];
        [_mySnake finishShooting];
    }
    
    if (_otherSnake.isShoot) {
        [_map snakeShootsAt:[[_otherSnake grids] objectAtIndex:0] WithDireciton:_otherSnake.direction];
        [_otherSnake finishShooting];
    }
    
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
    
    [_map updatePositionOfBullet];
}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CCLOG(@"Send Hello Message");
    [[SSConnectionManager sharedManager] sendMessage:@"Hello from your friend." forAction:ACTION_HELLO];
}

#pragma mark - SSConnectionManager delegate methods

- (void)connectionManager:(SSConnectionManager *)connectionManager didReceiveDictionary:(NSDictionary *)dictionary
{
    NSString *action = dictionary[@"action"];
    NSString *message = dictionary[@"message"];
    CCLOG(@"Receive Message:[%@] %@", action, message);
    
    if ([action isEqualToString:ACTION_CHANGE_DIRECTION]) {
        [_otherSnake setDirectionFromRemote:[message intValue]];
        
    } else if ([action isEqualToString:ACTION_PAUSE_GAME]) {
        [self pauseGame];
        
    } else if ([action isEqualToString:ACTION_RESUME_GAME]) {
        [self resumeGame];
    }
}


#pragma mark - Game flow methods

- (void)countdown:(ccTime)delta
{
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
    // Create local snake
    
    Grid *grid;
    if ([SSConnectionManager sharedManager].role == SERVER)
        grid = [Grid gridWithRow:SERVER_ROW Col:SERVER_COL];
    else
        grid = [Grid gridWithRow:CLIENT_ROW Col:CLIENT_COL];

    
    _mySnake = [SSSnake mySnakeWithInitialGrid:grid];
    [self addChild:_mySnake];
    
    [self schedule:@selector(updateMySnakePosition:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
    [self schedule:@selector(updateMapInfo:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
    
    
    if (_mode == MULTI_PLAYER) {
        Grid *grid;
        if ([SSConnectionManager sharedManager].role == SERVER)
            grid = [Grid gridWithRow:CLIENT_ROW Col:CLIENT_COL];
        else
            grid = [Grid gridWithRow:SERVER_ROW Col:SERVER_COL];
        
        _otherSnake =  [SSSnake otherSnakeWithInitialGrid:grid];
        [self addChild:_otherSnake];
        
    }
        
        [self schedule:@selector(updateOtherSnakePosition:) interval:BASE_UPDATE_INTERVAL repeat:kCCRepeatForever delay:0.0f];
    
    if ([SSConnectionManager sharedManager].role == SERVER || [SSConnectionManager sharedManager].role == NONE)
        [self schedule:@selector(updateMapInfo:) interval:0.1f repeat:kCCRepeatForever delay:0.0f];

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

- (void)createPauseMenu
{
    CGSize size = [CCDirector sharedDirector].winSize;
    CCMenuItem *pauseItem = [CCMenuItemImage itemWithNormalImage:@"pause-button.png"  selectedImage:@"pause-button.png" block:^(id sender) {
        [self pauseGame];
        [[SSConnectionManager sharedManager] sendMessage:@"" forAction:ACTION_PAUSE_GAME];
    }];
    
    CCMenuItem *shootItem = [CCMenuItemFont itemWithString:@"Shoot" block:^(id sender) {
        CCLOG(@"Shoot Button pressed.");
        [_mySnake shoot];
    }];
    
    CCMenu *menu = [CCMenu menuWithItems:shootItem, pauseItem, nil];
    menu.position = ccp(size.width - 250, pauseItem.boundingBox.size.height / 2);
    [menu alignItemsHorizontallyWithPadding:30];
    [self addChild:menu];
}


- (void)createPauseLayer
{
    CGSize size = [CCDirector sharedDirector].winSize;
    
    _pauseLayer = [CCLayerColor layerWithColor:ccc4(100, 100, 100, 200)];
    CCLabelTTF *pauseTitle = [CCLabelTTF labelWithString:@"Pause" fontName:@"Helvetica" fontSize:28];
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
        }
    }];
        
    CCMenu *menu = [CCMenu menuWithItems:resumeBtn, restartBtn, quitBtn, nil];
    
    [menu alignItemsVerticallyWithPadding:80];
    menu.position = ccp(size.width / 2, size.height / 2);
    
    [_pauseLayer addChild:menu];

}



@end

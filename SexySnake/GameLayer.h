//
//  GameLayer.h
//  SexySnake
//
//  Created by LCR on 5/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "cocos2d.h"
#import "SSConnectionManager.h"
#import "SSMap.h"
#import "Const.h"
#import "BulletSprite.h"

@class SSSnake;


@interface GameLayer : CCLayer <SSConnectionManagerDelegate, BulletSpriteDelegate>

+ (CCScene *)sceneOf1P;
+ (CCScene *)sceneOf2P;

+ (CCScene *)sceneWithMode:(Mode)mode;

// Game Data
@property (nonatomic) Mode mode;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) int counter;


// Motion Control
@property (nonatomic, strong) CCLabelTTF *label;
@property (nonatomic, strong) CMMotionManager *motionManager;

// Game UI
@property (strong, nonatomic) SSSnake *mySnake;
@property (strong, nonatomic) SSMap *map;
@property (strong, nonatomic) SSSnake *otherSnake;
@property (strong, nonatomic) CCLayer *pauseLayer;
@property (strong, nonatomic) CCSprite *countdownSprite;
@property (assign, nonatomic) BOOL startGenerateTarget;
@property (assign, nonatomic) BOOL startGenBulletTarget;


@end

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

@class SSSnake;

@interface GameLayer : CCLayer <SSConnectionManagerDelegate>

+ (CCScene *)sceneOf1P;
+ (CCScene *)sceneOf2P;

+ (CCScene *)sceneWithMode:(Mode)mode;

// Game Data
@property (nonatomic) Mode mode;
@property (nonatomic) BOOL isPaused;


// Motion Control
@property (nonatomic, strong) CCLabelTTF *label;
@property (nonatomic, strong) CMMotionManager *motionManager;

// Game UI
@property (strong, nonatomic) SSSnake *mySnake;
@property (strong, nonatomic) SSMap *map;
@property (strong, nonatomic) SSSnake *otherSnake;
@property (strong, nonatomic) CCLayer *pauseLayer;

@end

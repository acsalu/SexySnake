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
#import "SimpleAudioEngine.h"


#import "SimpleAudioEngine.h"
@class SSSnake;


@interface GameLayer : CCLayer <SSConnectionManagerDelegate, BulletSpriteDelegate, UIAlertViewDelegate>

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
@property (strong, nonatomic) CCMenuItem *shootItem;
@property (strong, nonatomic) CCMenuItem *shootItemDisabled;
@property (strong, nonatomic) CCMenuItem *wallItem;
@property (strong, nonatomic) CCMenuItem *wallItemDisabled;
@property (assign, nonatomic) BOOL startGenerateTarget;
@property (assign, nonatomic) BOOL startGenBulletTarget;
@property (strong, nonatomic) NSArray *scoreLabels;

@property (strong, nonatomic) NSMutableArray *bigBullets;


// Update UI
- (void)updateShootButton;
- (void)updateScoreLabelForSnake:(SSSnake *)snake;

@end

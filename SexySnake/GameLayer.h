//
//  GameLayer.h
//  SexySnake
//
//  Created by LCR on 5/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class SSSnake;

@interface GameLayer : CCLayer

+ (CCScene *)sceneOf1P;
+ (CCScene *)sceneOf2P;

+ (CCScene *)scene;

@property (strong, nonatomic) SSSnake *mySnake;

@end

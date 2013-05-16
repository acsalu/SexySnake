//
//  BulletSprite.h
//  SexySnake
//
//  Created by LCR on 5/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Const.h"

@class BulletSprite;
@class GameLayer;
@class SSSnake;
@class SSMap;
@class Grid;

@protocol BulletSpriteDelegate <NSObject>


- (BOOL)bullet:(BulletSprite *)bullet wouldMoveFrom:(Grid *) originGrid To:(Grid *)currentGrid;

// GameLayer

// SSSnake
- (void)bullet:(BulletSprite *)bullet shootSnakeAt:(Grid*)grid;

// SSMap
- (void)removeTargetAt:(Grid *)grid;
- (void)removeBulletTargetAt:(Grid *)grid;
- (void)removeWallAt:(Grid *)grid;

@end


@interface BulletSprite : CCSprite

@property (weak, nonatomic) GameLayer<BulletSpriteDelegate> *delegate;
@property (weak, nonatomic) SSSnake<BulletSpriteDelegate> *mySnake;
@property (weak, nonatomic) SSSnake<BulletSpriteDelegate> *otherSnake;
@property (weak, nonatomic) SSMap<BulletSpriteDelegate> *map;

@property (nonatomic) Direction direction;
@property (strong, nonatomic) Grid *positionInGrid;
@property (nonatomic) ccTime rate;


+ (BulletSprite *)bulletWithPositionInGrid:(Grid *)grid andDirection:(Direction)direction;

- (void)fire;

@end

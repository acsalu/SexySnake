//
//  SSSnake.h
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Const.h"
#import "BulletSprite.h"
#import "SimpleAudioEngine.h"

@class GameLayer;
@class Grid;

@interface SSSnake : CCSprite <BulletSpriteDelegate>

@property (weak, nonatomic) GameLayer *gameLayer;

@property (nonatomic) Direction direction;
@property (nonatomic, strong) NSMutableArray *components;
@property (nonatomic, strong) NSMutableArray *grids;
@property (nonatomic, assign, readonly) NSUInteger length;
//@property (nonatomic, assign) BOOL isShoot;
@property (nonatomic, assign) BOOL isBuilding;
@property (nonatomic, assign) int numberOfBulletTarget;
@property (nonatomic, assign) BOOL hasEaten;
@property (nonatomic, assign) BOOL hasLongBia;

+ (SSSnake *)mySnakeWithInitialGrid:(Grid *)grid;
+ (SSSnake *)otherSnakeWithInitialGrid:(Grid *)grid;

// update from other device
- (void)setDirectionFromRemote:(Direction)direction;

- (void)updateSnakeInfo:(NSMutableArray*) bodyArray;

- (void)move;
- (void)eatTarget;
- (void)eatBulletTarget;
- (void)getShotAt:(Grid*)grid;
- (void)getBitAt:(Grid*)grid;
- (void)getBitAtIndex:(NSUInteger)index;
- (void)hitWall;
- (void)buildWall;
- (void)shoot;
//- (void)finishShooting;
- (void)finishBuilding;



@end


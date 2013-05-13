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

@class Grid;

@interface SSSnake : CCSprite

@property (nonatomic) Direction direction;
@property (nonatomic, strong) NSMutableArray *components;
@property (nonatomic, strong) NSMutableArray *grids;
@property (nonatomic, assign) BOOL isShoot;


+ (SSSnake *)snakeWithInitialGrid:(Grid *)grid;

// update from other device
- (void)setDirectionFromRemote:(Direction)direction;


- (void)move;
- (void)eatTarget;
- (void)eatBulletTarget;
- (void)getShotAt:(Grid*)grid;
- (void)getBitAt:(Grid*)grid;
- (void)hitWall;
- (void)shoot;
- (void)finishShooting;



@end


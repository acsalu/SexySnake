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


+ (SSSnake *)snakeWithInitialGrid:(Grid *)grid;
+ (SSSnake *)snakeWithInitialPosition:(CGPoint)position;

// update from other device
- (void)setDirectionFromRemote:(Direction)direction;


- (void)move;
- (void)eatTarget;


@end


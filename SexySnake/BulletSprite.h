//
//  BulletSprite.h
//  SexySnake
//
//  Created by LCR on 5/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SSMap.h"
#import "Const.h"

@class BulletSprite;
@class GameLayer;

//typedef enum {
//} BulletEvent;

@protocol BulletSpriteDelegate <NSObject>


- (BOOL)bullet:(BulletSprite *)bullet wouldMoveFrom:(Grid *) originGrid To:(Grid *)currentGrid;
- (void)bullet:(BulletSprite *)bullet shootAt:(Grid*)grid;


@end



@interface BulletSprite : CCSprite

@property (weak, nonatomic) GameLayer<BulletSpriteDelegate> *delegate;

@property (nonatomic) Direction direction;
@property (strong, nonatomic) Grid *positionInGrid;
@property (nonatomic) ccTime rate;


+ (BulletSprite *)bulletWithPositionInGrid:(Grid *)grid andDirection:(Direction)direction;

- (void)fireAtRate:(ccTime)rate;

@end

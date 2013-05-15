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


@protocol BulletSpriteDelegate <NSObject>

@required
- (BOOL)bullet:(BulletSprite *)bullet wouldMoveFrom:(Grid *) originGrid To:(Grid *)currentGrid;


@end


@interface BulletSprite : CCSprite

@property (weak, nonatomic) GameLayer<BulletSpriteDelegate> *delegate;
@property (weak, nonatomic) SSMap *map;

@property (nonatomic) Direction direction;
@property (strong, nonatomic) Grid *positionInGrid;
@property (nonatomic) ccTime rate;


+ (BulletSprite *)bulletWithPositionInGrid:(Grid *)grid andDirection:(Direction)direction;

- (void)fire;

@end

//
//  BulletSprite.h
//  SexySnake
//
//  Created by LCR on 5/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameLayer.h"
#import "SSMap.h"
#import "Const.h"

@class BulletSprite;

//typedef enum {
//} BulletEvent;

@protocol BulletSpriteDelegate <NSObject>

@required
- (BOOL)bullet:(BulletSprite *)bullet wouldMoveFrom:(Grid *) originGrid To:(Grid *)currentGrid;


@end



@interface BulletSprite : CCSprite

@property (weak, nonatomic) GameLayer<BulletSpriteDelegate> *delegate;

@property (nonatomic) Direction direction;
@property (strong, nonatomic) Grid *positionInGrid;

+ (BulletSprite *)bulletWithPositionInGrid:(Grid *)grid andDirection:(Direction)direction;

- (void)fireAtRate:(ccTime)rate;

@end

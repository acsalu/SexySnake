//
//  GameLayer.m
//  SexySnake
//
//  Created by LCR on 5/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"


@implementation GameLayer

+ (CCScene *)sceneOf1P
{
    NSLog(@"enter 1P mode");
    return [GameLayer scene];
}

+ (CCScene *)sceneOf2P
{
    NSLog(@"enter 2P mode");
    return [GameLayer scene];
}

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    GameLayer *gameLayer = [GameLayer node];
    [scene addChild:gameLayer];
    return scene;
}


@end

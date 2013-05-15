//
//  MainScreenLayer.m
//  SexySnake
//
//  Created by LCR on 5/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MainScreenLayer.h"
#import "GameLayer.h"

@implementation MainScreenLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	MainScreenLayer *layer = [MainScreenLayer node];
	[scene addChild: layer];
	return scene;
}

- (id)init
{
    if (self = [super init]) {
        [self createMenu];
    }
    return self;
}

- (void)createMenu
{
    [CCMenuItemFont setFontSize:80];
    
    CCMenuItem *singlePlayerBtn = [CCMenuItemFont itemWithString:@"1P" block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[GameLayer sceneOf1P]];
    }];

    CCMenuItem *twoPlayerBtn = [CCMenuItemFont itemWithString:@"2P" block:^(id sender) {
        SSConnectionManager *manager = [SSConnectionManager sharedManager];
        manager.mainScreenDelegate = self;
        [manager connectToDevice];
    }];
      
    CCMenu *mainMenu = [CCMenu menuWithItems:singlePlayerBtn, twoPlayerBtn, nil];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    [mainMenu alignItemsHorizontallyWithPadding:80];
    mainMenu.position = ccp(size.width/2, size.height/2);
    
    [self addChild:mainMenu];
}

- (void)managerDidConnect
{
    [[CCDirector sharedDirector] replaceScene:[GameLayer sceneOf2P]];
}

@end

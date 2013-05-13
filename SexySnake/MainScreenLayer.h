//
//  MainScreenLayer.h
//  SexySnake
//
//  Created by LCR on 5/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SSConnectionManager.h"

@interface MainScreenLayer : CCLayer <SSConnectionDelegate>

+ (CCScene *)scene;

@end

//
//  SSUtility.m
//  SexySnake
//
//  Created by Acsa Lu on 5/11/13.
//
//

#import "Const.h"

NSString * const JSONKeyAction = @"action";
NSString * const JSONKeyMessage = @"message";

@implementation Const

+ (Const *)sharedConst
{
    static Const *sharedConst;
    @synchronized(self) {
        if (!sharedConst) {
            sharedConst = [[self alloc] init];
        }
    }
    return sharedConst;
}

@end

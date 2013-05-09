//
//  SSConnectionManager.h
//  SexySnake
//
//  Created by LCR on 5/9/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface SSConnectionManager : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>

@property (strong, nonatomic) GKSession *session;

+ (SSConnectionManager *)sharedManager;

- (void)connectToDevice;

@end

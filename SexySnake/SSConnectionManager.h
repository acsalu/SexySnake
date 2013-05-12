//
//  SSConnectionManager.h
//  SexySnake
//
//  Created by LCR on 5/9/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Const.h"

extern NSString *const ACTION_HELLO;
extern NSString *const ACTION_CHANGE_DIRECTION;
extern NSString *const ACTION_PAUSE_GAME;
extern NSString *const ACTION_RESUME_GAME;
extern NSString *const ACTION_RESTART_GAME;
extern NSString *const ACTION_QUIT_GAME;

@class SSConnectionManager;

@protocol SSConnectionManagerDelegate <NSObject>

@required
- (void)connectionManager:(SSConnectionManager *)connectionManager didReceiveDictionary:(NSDictionary *)dictionary;

@end

@interface SSConnectionManager : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>

@property (strong, nonatomic) GKSession *session;
@property (weak, nonatomic) id<SSConnectionManagerDelegate> delegate;
@property (nonatomic) Role role;

+ (SSConnectionManager *)sharedManager;

- (void)connectToDevice;
- (void)sendMessage:(NSString *)message forAction:(NSString *)action;

@end

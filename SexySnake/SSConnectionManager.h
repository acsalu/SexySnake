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

extern NSString *const ACTION_COINTOSS;
extern NSString *const ACTION_HELLO;
extern NSString *const ACTION_CHANGE_DIRECTION;
extern NSString *const ACTION_PAUSE_GAME;
extern NSString *const ACTION_RESUME_GAME;
extern NSString *const ACTION_RESTART_GAME;
extern NSString *const ACTION_QUIT_GAME;
extern NSString *const ACTION_SEND_MAP;
extern NSString *const ACTION_RECEIVE_MAP;
extern NSString *const ACTION_SEND_SNAKE_INFO;
extern NSString *const ACTION_RECEIVE_SNAKE_INFO;


@class SSConnectionManager;

@protocol SSConnectionManagerDelegate <NSObject>

@required
- (void)connectionManager:(SSConnectionManager *)connectionManager didReceiveDictionary:(NSDictionary *)dictionary;

@end

@protocol SSConnectionDelegate <NSObject>

@required
- (void)managerDidConnect;

@end



@interface SSConnectionManager : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>
{
    NSNumber *gameUniqueID;
}

@property (strong, nonatomic) GKSession *session;
@property (nonatomic) Role role;

@property (weak, nonatomic) id<SSConnectionManagerDelegate> delegate;
@property (weak, nonatomic) id<SSConnectionDelegate> mainScreenDelegate;

+ (SSConnectionManager *)sharedManager;

- (void)connectToDevice;
- (void)determineServer;
- (void)sendMessage:(NSString *)message forAction:(NSString *)action;

@end

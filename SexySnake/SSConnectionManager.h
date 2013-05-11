//
//  SSConnectionManager.h
//  SexySnake
//
//  Created by LCR on 5/9/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class SSConnectionManager;

@protocol SSConnectionManagerDelegate <NSObject>

@required
- (void)connectionManager:(SSConnectionManager *)connectionManager didReceiveMessage:(NSString *)message;

@end

@interface SSConnectionManager : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>

@property (strong, nonatomic) GKSession *session;
@property (weak, nonatomic) id<SSConnectionManagerDelegate> delegate;

+ (SSConnectionManager *)sharedManager;

- (void)connectToDevice;
- (void)sendMessage:(NSString *)message;

@end

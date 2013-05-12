//
//  SSConnectionManager.m
//  SexySnake
//
//  Created by LCR on 5/9/13.
//
//

#import "SSConnectionManager.h"
#import "GameLayer.h"
#import "JSONKit.h"


NSString *const ACTION_HELLO = @"HELLO";
NSString *const ACTION_CHANGE_DIRECTION = @"CHANGE_DIRECTION";

NSString *const ACTION_PAUSE_GAME = @"PAUSE_GAME";
NSString *const ACTION_RESUME_GAME = @"RESUME_GAME";
NSString *const ACTION_RESTART_GAME = @"RESTART_GAME";
NSString *const ACTION_QUIT_GAME = @"QUIT_GAME";

NSString *const ACTION_DECLARE_SERVER = @"DECLARE_SERVER";

@implementation SSConnectionManager 

+ (SSConnectionManager *)sharedManager
{
    static SSConnectionManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        sharedManager.role = NONE;
    });
    return sharedManager;
}


- (void)connectToDevice
{
    if (self.session == nil) {
        GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
        picker.delegate = self;
        picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
        [picker show];
    }
}


- (void)sendMessage:(NSString *)message forAction:(NSString *)action
{
//    NSData *testData = [@"Jack Chao ^.<" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = @{@"action":action, @"message":message};
    [self.session sendDataToAllPeers:[dict JSONData] withDataMode:GKSendDataReliable error:nil];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([receivedString isEqualToString:ACTION_DECLARE_SERVER]) {

    } else if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self.delegate respondsToSelector:@selector(connectionManager:didReceiveDictionary:)])
                [self.delegate connectionManager:self didReceiveDictionary:(NSDictionary *) [receivedString objectFromJSONString]];
            else
                CCLOG(@"sucks");
        });
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message"
                                                            message:receivedString
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    NSString *sessionID = @"sessionID";
    GKSession *session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModePeer];
    return session;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    session.delegate = self;
    self.session = session;
    [session setDataReceiveHandler:self withContext:nil];
    
    picker.delegate = nil;
    [picker dismiss];
    
    
    [[CCDirector sharedDirector] replaceScene:[GameLayer sceneOf2P]];
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"I'm client");
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    if (state == GKPeerStateConnected) {
        NSLog(@"Session state changed : GKPeerStateConnected");
    } else {
        if (state == GKPeerStateDisconnected) _role = NONE;
        
        self.session.delegate = nil;
        
        self.session = nil;
    }
}


@end

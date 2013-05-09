//
//  SSConnectionManager.m
//  SexySnake
//
//  Created by LCR on 5/9/13.
//
//

#import "SSConnectionManager.h"

//
#import "GameLayer.h"
//


@implementation SSConnectionManager 

+ (SSConnectionManager *)sharedManager
{
    static SSConnectionManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
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


- (void)sendMessage
{
    NSData *testData = [@"Jack Chao ^.<" dataUsingEncoding:NSUTF8StringEncoding];
    [self.session sendDataToAllPeers:testData withDataMode:GKSendDataReliable error:nil];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:receivedString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
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

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    if (state == GKPeerStateConnected) {
        NSLog(@"Session state changed : GKPeerStateConnected");
    } else {
        self.session.delegate = nil;
        self.session = nil;
    }
}



@end

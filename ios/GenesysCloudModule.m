#import "GenesysCloudModule.h"
#import <GenesysCloud/GenesysCloud.h>

/************************************************************/
// MARK: - GenesysCloudModule
/************************************************************/

@interface GenesysCloudModule()<ChatControllerDelegate>

/************************************************************/
// MARK: - Properties
/************************************************************/
@property (nonatomic, strong) ChatController *chatController;
@property (nonatomic, readonly) BOOL emitterHasListeners;
@end

@implementation GenesysCloudModule

RCT_EXPORT_MODULE(GenesysCloud)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

/************************************************************/
// MARK: - Exported Methods
/************************************************************/

RCT_EXPORT_METHOD(startChat: (NSString *)deploymentId: (NSString *)domain: (NSString *)tokenStoreKey: (BOOL)logging) {
    MessengerAccount *account = [self setupAccount:deploymentId domain:domain tokenStoreKey:tokenStoreKey logging:logging];
    [self startChatWithAccount:account];
}

RCT_EXPORT_METHOD(startChatWithCustomAttributes: (NSString *)deploymentId: (NSString *)domain: (NSString *)tokenStoreKey: (BOOL)logging: (NSDictionary<NSString *, NSString *> *) customAttributes) {
    MessengerAccount *account = [self setupAccount:deploymentId domain:domain tokenStoreKey:tokenStoreKey logging:logging];
    account.customAttributes = customAttributes;
    [self startChatWithAccount:account];
}

// RCT_EXPORT_METHOD(startChat: (NSString *)deploymentId: (NSString *)domain: (BOOL)logging) {
//     MessengerAccount *account = [self setupAccount:deploymentId domain:domain logging:logging];
//     [self startChatWithAccount:account];
// }

// RCT_EXPORT_METHOD(startChat: (NSString *)deploymentId: (NSString *)domain: (BOOL)logging: (NSDictionary<NSString *, NSString *> *) customParams) {
//     MessengerAccount *account = [self setupAccount:deploymentId domain:domain logging:logging];
//     //account.customAttributes = customAttributes;
//     [self startChatWithAccount:account];
// }

/************************************************************/
// MARK: - Private Methods
/************************************************************/

- (MessengerAccount *)setupAccount:(NSString *)deploymentId
                            domain:(NSString *)domin
                     tokenStoreKey:(NSString *)tokenStoreKey
                           logging:(BOOL)logging {
    return [[MessengerAccount alloc] initWithDeploymentId:deploymentId domain:domin tokenStoreKey:tokenStoreKey logging:logging];
}

// - (MessengerAccount *)setupAccount:(NSString *)deploymentId
//                             domain:(NSString *)domin
//                            logging:(BOOL)logging {
//     return [[MessengerAccount alloc] initWithDeploymentId:deploymentId domain:domin logging:logging];
// }

- (void)startChatWithAccount:(MessengerAccount *)account {
    self.chatController = [[ChatController alloc] initWithAccount:account];
    [self setupInitialConfigurations];
    self.chatController.delegate = self;
}

- (void)setupInitialConfigurations {
    self.chatController.viewConfiguration.incomingBotConfig.avatar = nil;
    self.chatController.viewConfiguration.incomingLiveConfig.avatar = nil;
    self.chatController.viewConfiguration.outgoingConfig.avatar = nil;
}

- (void)doneButtonPressed {
    [self.chatController endChat];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
}

/************************************************************/
// MARK: - ChatControllerDelegate
/************************************************************/

- (void)shouldPresentChatViewController:(UINavigationController *)viewController {
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    viewController.navigationBar.topItem.rightBarButtonItem = doneBarButtonItem;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)didFailWithError:(BLDError *)error {
    if (_emitterHasListeners) {
        [self sendEventWithName:@"onMessengerError" body:@{
            @"errorCode": error.error.domain ? error.error.domain: @"",
            @"reason": error.error.code ? @(error.error.code).stringValue : @"",
            @"message": error.error.userInfo[@"reason"] ? error.error.userInfo[@"reason"] : @""
        }];
    }
}

- (void)didUpdateState:(ChatStateEvent *)event {
    NSString *state;
    if (event.state == ChatStarted) {
        state = @"started";
    } else if (event.state == ChatEnded) {
        state = @"ended";
    }
    
    if (_emitterHasListeners && state.length) {
        [self sendEventWithName:@"onMessengerState" body:@{
            @"state": state
        }];
    }
}

/************************************************************/
// MARK: - RCTEventEmitter
/************************************************************/

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onMessengerError", @"onMessengerState"];
}

// Will be called when this module's first listener is added.
- (void)startObserving {
    _emitterHasListeners = YES;
}

// Will be called when this module's last listener is removed, or on dealloc.
- (void)stopObserving {
    _emitterHasListeners = NO;
}

@end


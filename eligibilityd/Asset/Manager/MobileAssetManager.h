//
//  MobileAssetManager.h
//  eligibilityd
//
//  Audited for macOS 15.2
//  Status: WIP

#import <Foundation/Foundation.h>
#import "BoronAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface MobileAssetManager : NSObject

+ (instancetype)sharedInstance;

// TODO
@property (nonatomic, strong) BoronAsset *greymatterAsset;
@property (nonatomic, strong) BoronAsset *xcodeLLMAsset;
@property (nonatomic, strong) BoronAsset *ironAsset;

@property (nonatomic, strong) NSNumber *assetVersion;
@property (nonatomic, strong, readonly) NSObject<OS_dispatch_queue> *internalQueue;
@property (nonatomic, strong, readonly) NSObject<OS_dispatch_queue> *mobileAssetQueue;
@property (nonatomic, strong) NSNumber *fallbackVersion;

- (void)registerForMobileAssetUpdateNotification;
- (void)asyncRefetchMobileAsset;
@end

NS_ASSUME_NONNULL_END

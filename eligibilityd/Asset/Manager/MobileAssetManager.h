//
//  MobileAssetManager.h
//  eligibilityd
//
//  Created by Kyle on 2024/7/14.
//

#import <Foundation/Foundation.h>
#import "BoronAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface MobileAssetManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, retain) NSObject<OS_dispatch_queue> *internalQueue;
@property (nonatomic, retain) NSObject<OS_dispatch_queue> *mobileAssetQueue;

@property (nonatomic, strong) BoronAsset* ironAsset;
@property (nonatomic, strong) BoronAsset* xcodeLLMAsset;

- (void)asyncRefetchMobileAsset;
@end

NS_ASSUME_NONNULL_END

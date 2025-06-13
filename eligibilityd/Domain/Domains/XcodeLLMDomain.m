//
//  XcodeLLMDomain.m
//  eligibilityd
//
//  Audited for macOS 15.2
//  Status: Complete

#import "XcodeLLMDomain.h"
#import "MobileAssetManager.h"

@interface XcodeLLMDomain ()
- (void)_internal_doInit;
@end

@implementation XcodeLLMDomain

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (EligibilityDomainType)domain {
    return EligibilityDomainTypeXcodeLLM;
}

- (NSNotificationName)domainChangeNotificationName {
    return @"com.apple.os-eligibility-domain.change.xcode-llm";
}

- (void)_internal_doInit {
    [self setDeviceRegionInterest];    
    [self setDeviceClassesOfInterest:[NSSet setWithObject:@"Mac"]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _internal_doInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _internal_doInit];
    }
    return self;
}

- (void)updateParameters {
    return;
}

- (EligibilityInputStatus)computeInputStatusForDeviceRegionCodesInput:(DeviceRegionCodeInput *)input {
    // macOS 15.0 Beta 1
    // return input.isChinaSKU ? EligibilityInputStatusNotEligible : EligibilityInputStatusEligible;
    NSSet<NSString *> *countryCodes = MobileAssetManager.sharedInstance.xcodeLLMAsset.countryCodes;
    if (input.deviceRegionCode == nil) {
        return EligibilityInputStatusEligible;
    }
    return [countryCodes containsObject:input.deviceRegionCode] ? EligibilityInputStatusNotEligible : EligibilityInputStatusEligible;
}

@end

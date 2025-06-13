//
//  IronDomain.m
//  eligibilityd
//
//  Audited for macOS 15.2
//  Status: Complete

#import "IronDomain.h"
#import "MobileAssetManager.h"
#import "EligibilityLog.h"

@interface IronDomain ()
- (void)_internal_doInit;
@end

@implementation IronDomain

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (EligibilityDomainType)domain {
    return EligibilityDomainTypeIron;
}

- (NSNotificationName)domainChangeNotificationName {
    return @"com.apple.os-eligibility-domain.change.iron";
}

- (void)_internal_doInit {
    [self updateParameters];
    [self setDeviceClassesOfInterest:[NSSet setWithObjects:@"iPhone", @"Mac", nil]];
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
    BoronAsset *asset = MobileAssetManager.sharedInstance.ironAsset;
    NSSet *countryCodes = asset.countryCodes;
    [self setLocatedCountriesOfInterest:countryCodes isInverted:YES];
    [self setBillingCountriesOfInterest:countryCodes isInverted:YES];
    return;
}

- (EligibilityAnswer)computeWithError:(NSError * _Nullable *)errorPtr {
    NSDictionary<NSString *, NSNumber *> *status = self.status;
    if (!status) {
        os_log_fault(eligibility_log(), "%s: Failed to get status for Iron domain", __func__);
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOATTR userInfo:nil];
        if (errorPtr) {
            *errorPtr = error;
        }
        return EligibilityAnswerInvalid;
    }
    
    if (status[@"OS_ELIGIBILITY_INPUT_DEVICE_CLASS"].unsignedIntValue != EligibilityInputStatusEligible) {
        self.answer = EligibilityAnswerNotEligible;
        return EligibilityAnswerNotYetAvailable;
    }
    
    EligibilityInputStatus countryLocationStatus = status[@"OS_ELIGIBILITY_INPUT_COUNTRY_LOCATION"].unsignedIntValue;
    EligibilityInputStatus countryBillingStatus = status[@"OS_ELIGIBILITY_INPUT_COUNTRY_BILLING"].unsignedIntValue;
    if (countryLocationStatus == EligibilityInputStatusNotEligible && countryBillingStatus == EligibilityInputStatusNotEligible) {
        self.answer = EligibilityAnswerNotEligible;
    } else if (countryBillingStatus != EligibilityInputStatusEligible && countryLocationStatus == EligibilityInputStatusNotEligible){
        self.answer = EligibilityAnswerNotEligible;
    } else {
        self.answer = EligibilityAnswerEligible;
    }
    return EligibilityAnswerNotYetAvailable;
}

@end

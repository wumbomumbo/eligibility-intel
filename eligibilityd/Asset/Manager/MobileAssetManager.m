//
//  MobileAssetManager.m
//  eligibilityd
//
//  Audited for macOS 15.2
//  Status: WIP

#import "MobileAssetManager.h"
#import "EligibilityUtils.h"
#import "EligibilityLog.h"
#import "GlobalConfiguration.h"

// MARK: - Constants
#define COUNTRY_CODES_KEY @"Country Codes"
#define GRACE_PERIOD_KEY @"Grace Period"
#define POLICIES_KEY @"Policies"

// MARK: - Time Constants
#define GRACE_PERIOD_ZERO @0
#define GRACE_PERIOD_ONE_MONTH @2592000  // 30 days in seconds

// MARK: - Country Code Sets
#define EMPTY_COUNTRY_CODES @[]

// EEA Countries (37 countries)
#define EEA_COUNTRY_CODES @[ \
    /* Nordic Countries */ \
    @"DK", @"FI", @"IS", @"NO", @"SE", \
    \
    /* Western Europe */ \
    @"AT", @"BE", @"DE", @"FR", @"IE", @"LI", @"LU", @"NL", \
    \
    /* Southern Europe */ \
    @"CY", @"ES", @"GR", @"IT", @"MT", @"PT", \
    \
    /* Eastern Europe */ \
    @"BG", @"CZ", @"EE", @"HR", @"HU", @"LT", @"LV", @"PL", @"RO", @"SI", @"SK", \
    \
    /* Special Territories */ \
    @"AX",  /* Åland Islands */ \
    @"GF",  /* French Guiana */ \
    @"GP",  /* Guadeloupe */ \
    @"MF",  /* Saint Martin */ \
    @"MQ",  /* Martinique */ \
    @"RE",  /* Réunion */ \
    @"YT",  /* Mayotte */ \
]

// EU Countries (34 countries)
#define EU_COUNTRY_CODES @[ \
    /* Nordic Countries */ \
    @"DK", @"FI", @"SE", \
    \
    /* Western Europe */ \
    @"AT", @"BE", @"DE", @"FR", @"IE", @"LU", @"NL", \
    \
    /* Southern Europe */ \
    @"CY", @"ES", @"GR", @"IT", @"MT", @"PT", \
    \
    /* Eastern Europe */ \
    @"BG", @"CZ", @"EE", @"HR", @"HU", @"LT", @"LV", @"PL", @"RO", @"SI", @"SK", \
    \
    /* Special Territories */ \
    @"AX",  /* Åland Islands */ \
    @"GF",  /* French Guiana */ \
    @"GP",  /* Guadeloupe */ \
    @"MF",  /* Saint Martin */ \
    @"MQ",  /* Martinique */ \
    @"RE",  /* Réunion */ \
    @"YT",  /* Mayotte */ \
]

// CN + EU Countries (35 countries)
#define CN_EU_COUNTRY_CODES @[ \
    /* Nordic Countries */ \
    @"DK", @"FI", @"SE", \
    \
    /* Western Europe */ \
    @"AT", @"BE", @"DE", @"FR", @"IE", @"LU", @"NL", \
    \
    /* Southern Europe */ \
    @"CY", @"ES", @"GR", @"IT", @"MT", @"PT", \
    \
    /* Eastern Europe */ \
    @"BG", @"CZ", @"EE", @"HR", @"HU", @"LT", @"LV", @"PL", @"RO", @"SI", @"SK", \
    \
    /* Special Territories */ \
    @"AX",  /* Åland Islands */ \
    @"GF",  /* French Guiana */ \
    @"GP",  /* Guadeloupe */ \
    @"MF",  /* Saint Martin */ \
    @"MQ",  /* Martinique */ \
    @"RE",  /* Réunion */ \
    @"YT",  /* Mayotte */ \
    @"CN",  /* China */ \
]

#define CHINA_SKU_COUNTRY_CODES @[@"CH"]

// MARK: - Default Configuration
#define DEFAULT_CONFIG_PLIST @{ \
    /* Base Metals */ \
    @"Aluminum": @{ \
        COUNTRY_CODES_KEY: EEA_COUNTRY_CODES, \
    }, \
    @"Argon": @{ \
        COUNTRY_CODES_KEY: EU_COUNTRY_CODES, \
    }, \
    @"Arsenic": @{ \
        COUNTRY_CODES_KEY: EU_COUNTRY_CODES, \
    }, \
    @"Beryllium": @{ \
        COUNTRY_CODES_KEY: EMPTY_COUNTRY_CODES, \
        GRACE_PERIOD_KEY: GRACE_PERIOD_ZERO, \
    }, \
    @"Boron": @{ \
        COUNTRY_CODES_KEY: EU_COUNTRY_CODES, \
        GRACE_PERIOD_KEY: GRACE_PERIOD_ONE_MONTH, \
    }, \
    @"Bromine": @{ \
        COUNTRY_CODES_KEY: EU_COUNTRY_CODES, \
    }, \
    @"Carbon": @{ \
        @"TODO": @"", \
    }, \
    @"Chlorine": @{ \
        @"TODO": @"", \
    }, \
    @"Chromium": @{ \
        @"TODO": @"", \
    }, \
    @"Cobalt": @{ \
        @"TODO": @"", \
    }, \
    @"Copper": @{ \
        @"TODO": @"", \
    }, \
    @"Fluorine": @{ \
        @"TODO": @"", \
    }, \
    @"Gallium": @{ \
        @"TODO": @"", \
    }, \
    @"Germanium": @{ \
        @"TODO": @"", \
    }, \
    @"Greymatter": @{ \
        COUNTRY_CODES_KEY: CN_EU_COUNTRY_CODES, \
    }, \
    @"Helium": @{ \
        @"TODO": @"", \
    }, \
    @"Hydrogen": @{ \
        @"TODO": @"", \
    }, \
    @"Iron": @{ \
        COUNTRY_CODES_KEY: EU_COUNTRY_CODES, \
    }, \
    @"Krypton": @{ \
        @"TODO": @"", \
    }, \
    @"Lithium": @{ \
        @"TODO": @"", \
    }, \
    @"Lot X": @{ \
        @"TODO": @"", \
    }, \
    @"Magnesium": @{ \
        @"TODO": @"", \
    }, \
    @"Manganese": @{ \
        @"TODO": @"", \
    }, \
    @"Neon": @{ \
        @"TODO": @"", \
    }, \
    @"Nickel": @{ \
        @"TODO": @"", \
    }, \
    @"Nitrogen": @{ \
        @"TODO": @"", \
    }, \
    @"Oxygen": @{ \
        @"TODO": @"", \
    }, \
    @"Phosphorus": @{ \
        @"TODO": @"", \
    }, \
    @"Podcasts Transcripts": @{ \
        @"TODO": @"", \
    }, \
    @"Potassium": @{ \
        @"TODO": @"", \
    }, \
    @"Rubidium": @{ \
        @"TODO": @"", \
    }, \
    @"Scandium": @{ \
        @"TODO": @"", \
    }, \
    @"SearchMarketplaces": @{ \
        @"TODO": @"", \
    }, \
    @"Selenium": @{ \
        @"TODO": @"", \
    }, \
    @"Silicon": @{ \
        @"TODO": @"", \
    }, \
    @"Sodium": @{ \
        @"TODO": @"", \
    }, \
    @"Strontium": @{ \
        @"TODO": @"", \
    }, \
    @"Sulfur": @{ \
        GRACE_PERIOD_KEY: GRACE_PERIOD_ONE_MONTH, \
        POLICIES_KEY: @[ \
            @{ \
                @"OS_ELIGIBILITY_INPUT_COUNTRY_BILLING": EU_COUNTRY_CODES, \
                @"OS_ELIGIBILITY_INPUT_COUNTRY_LOCATION": EU_COUNTRY_CODES, \
            }, \
            @{ \
                @"OS_ELIGIBILITY_INPUT_COUNTRY_BILLING": @[@"KR"], \
                @"OS_ELIGIBILITY_INPUT_DEVICE_CLASS": @[@"iPhone", @"iPad"], \
            } \
        ], \
    }, \
    @"Swift Assist": @{ \
        COUNTRY_CODES_KEY: CHINA_SKU_COUNTRY_CODES, \
    }, \
    @"Titanium": @{ \
        COUNTRY_CODES_KEY: EU_COUNTRY_CODES, \
    }, \
    @"Vanadium": @{ \
        COUNTRY_CODES_KEY: EU_COUNTRY_CODES, \
        GRACE_PERIOD_KEY: GRACE_PERIOD_ONE_MONTH, \
    }, \
    @"Version": @19, \
    @"Xcode LLM": @{ \
        COUNTRY_CODES_KEY: CHINA_SKU_COUNTRY_CODES, \
    }, \
    @"Yttrium": @{ \
        COUNTRY_CODES_KEY: EMPTY_COUNTRY_CODES, \
    }, \
}

@interface MobileAssetManager ()

@property (nonatomic, strong) NSObject<OS_dispatch_queue> *internalQueue;
@property (nonatomic, strong) NSObject<OS_dispatch_queue> *mobileAssetQueue;

- (void)_initDomainsWithConfigPlist:(NSDictionary *)plist;

@end

@implementation MobileAssetManager

+ (instancetype)sharedInstance {
    static MobileAssetManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mobileAssetQueue = dispatch_queue_create("com.apple.eligibility.MobileAssetManager.mobileAsset", dispatch_queue_attr_make_with_autorelease_frequency(nil, DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM));
        _internalQueue = dispatch_queue_create("com.apple.eligibility.MobileAssetManager.internal", dispatch_queue_attr_make_with_autorelease_frequency(nil, DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM));
        [self _initDomainsWithConfigPlist:nil];
        [self registerForMobileAssetUpdateNotification];
        asyncBlock(self.mobileAssetQueue, ^{
            os_log(eligibility_log(), "%s: Marking interest in MobileAsset", __func__);
        });
    }
    return self;
    struct __CFDictionary;
}

- (void)_initDomainsWithConfigPlist:(NSDictionary *)plist {
    NSDictionary *fallbackMobileAsset = DEFAULT_CONFIG_PLIST;
    NSNumber *fallbackVersion = fallbackMobileAsset[@"Version"];
    if (![fallbackVersion isKindOfClass:NSNumber.class]) {
        os_log_fault(eligibility_log(), "%s: Fallback Mobile Asset is malformed: Missing version key", __func__);
        fallbackVersion = @0;
    }
    self.fallbackVersion = fallbackVersion;
    NSDictionary *finalAsset;
    if (plist != nil) {
        NSNumber *version = plist[@"Version"];
        if (![version isKindOfClass:NSNumber.class]) {
            version = nil;
        }
        if ([version compare:fallbackVersion] == NSOrderedAscending) {
            finalAsset = plist;
        } else {
            finalAsset = fallbackMobileAsset;
        }
    } else {
        finalAsset = fallbackMobileAsset;
    }
    
    // Override logic
    if (GlobalConfiguration.sharedInstance.hasInternalContent) {
        const char *override_path = copy_eligibility_domain_mobile_asset_override_path();
        if (override_path == NULL) {
            os_log_error(eligibility_log(), "%s: Failed to copy mobile asset override path; Ignoring it", __func__);
        } else {
            NSString *override_string = [NSString stringWithUTF8String:override_path];
            free((void *)override_path);
            NSURL *override_url = [NSURL fileURLWithPath:override_string isDirectory:NO];
            NSDictionary *override_contents = [NSDictionary dictionaryWithContentsOfURL:override_url error:nil];
            if (override_contents != nil) {
                os_log(eligibility_log(), "%s: Found Mobile Asset override plist at path %@; Using that instead instead of real values", __func__, override_url.path);
                finalAsset = override_contents;
            }
        }
    }
    // TODO: init assets using finalAsset
}

- (NSNumber *)assetVersion {
    __block NSNumber *version;
    dispatch_sync(self.internalQueue, ^{
        version = _assetVersion;
    });
    return version;
}

- (void)registerForMobileAssetUpdateNotification {
    // TODO: MobileAsset framework
    // MAAutoAssetNotifications
}

- (void)asyncRefetchMobileAsset {
    // com.apple.MobileAsset.OSEligibility
    asyncBlock(self.mobileAssetQueue, ^{
        // TODO
    });
}

@end

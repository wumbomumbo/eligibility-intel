//
//  ExternalBootDriveInput.h
//  eligibilityd
//
//  Audited for macOS 15.3.1
//  Status: Complete

#import "EligibilityInput.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExternalBootDriveInput : EligibilityInput

@property(nonatomic, assign, readonly) BOOL hasExternalBootDrive;

@end

NS_ASSUME_NONNULL_END

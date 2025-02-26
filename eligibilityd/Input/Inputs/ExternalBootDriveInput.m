//
//  ExternalBootDriveInput.m
//  eligibilityd
//
//  Audited for macOS 15.3.1
//  Status: Complete

#import "ExternalBootDriveInput.h"
#import "EligibilityLog.h"
#import <sys/mount.h>

@interface ExternalBootDriveInput ()

@property(nonatomic, assign, readwrite) BOOL hasExternalBootDrive;

+ (BOOL)queryHasExternalBootDrive;

@end

@implementation ExternalBootDriveInput

+ (BOOL)queryHasExternalBootDrive {
    struct statfs buf;
    bzero(&buf, sizeof(struct statfs));
    BOOL result = statfs("/", &buf);
    if (result != 0) {
        int error = errno;
        os_log_error(eligibility_log(), "%s: Failed to stat '/', assuming external: %s(%d)", __func__, strerror(error), error);
        return YES;
    }
    return buf.f_flags & MNT_REMOVABLE;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super initWithInputType:EligibilityInputTypeExternalBoot status:EligibilityInputStatusNone process:@"eligibilityd"];
    if (self) {
        _hasExternalBootDrive = [ExternalBootDriveInput queryHasExternalBootDrive];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithInputType:EligibilityInputTypeExternalBoot status:EligibilityInputStatusNone process:@"eligibilityd"];
    if (self) {
        _hasExternalBootDrive = [ExternalBootDriveInput queryHasExternalBootDrive];
    }
    return self;
}

- (NSUInteger)hash {
    return [super hash] ^ self.hasExternalBootDrive;
}

- (BOOL)isEqual:(id)other {
    if (![super isEqual:other]) {
        return NO;
    } else if (other == self) {
        return YES;
    } else {
        if (![other isKindOfClass:self.class]) {
            return NO;
        }
        ExternalBootDriveInput *otherInput = (ExternalBootDriveInput *)other;
        if (!(self.hasExternalBootDrive == otherInput.hasExternalBootDrive)) {
            os_log(eligibility_log(), "%s: Property %s did not match", __func__, "hasExternalBootDrive");
            return NO;
        } else {
            return YES;
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[ExternalBootDriveInput hasExternalBootDrive:%@ %@]", self.hasExternalBootDrive ? @"Y" : @"N", [super description]];
}

@end

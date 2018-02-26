/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <ifaddrs.h>
#import <net/if.h>

typedef NS_ENUM(NSInteger, TCDevicePlatform) {
    kTCDeviceUnknown = 0,
    
    kTCDeviceSimulator,
    kTCDeviceSimulatoriPhone,
    kTCDeviceSimulatoriPad,
    kTCDeviceSimulatorAppleTV,
    
    
    kTCDevice1GiPhone,
    kTCDevice3GiPhone,
    kTCDevice3GSiPhone,
    
    kTCDevice4iPhone,
    kTCDevice4SiPhone,
    
    kTCDevice5iPhone,
    kTCDevice5CiPhone,
    kTCDevice5SiPhone,
    
    kTCDevice6iPhone,
    kTCDevice6PlusiPhone,
    
    kTCDeviceSEiPhone,
    kTCDevice6SiPhone,
    kTCDevice6SPlusiPhone,
    
    kTCDevice7iPhone,
    kTCDevice7PlusiPhone,
    
    kTCDevice8iPhone,
    kTCDevice8PlusiPhone,
    kTCDeviceXiPhone,
    
    kTCDevice1GiPod,
    kTCDevice2GiPod,
    kTCDevice3GiPod,
    kTCDevice4GiPod,
    kTCDevice5GiPod,
    kTCDevice6GiPod,
    
    kTCDevice1GiPad,
    kTCDevice2GiPad,
    kTCDevice1GiPadMini,
    
    kTCDevice3GiPad,
    kTCDevice4GiPad,
    kTCDevice5GiPad,
    
    kTCDevice1GiPadAir,
    kTCDevice2GiPadMini,
    kTCDevice3GiPadMini,
    kTCDevice4GiPadMini,
    kTCDevice2GiPadAir,
    
    kTCDevice1GiPadPro9_7,
    kTCDevice1GiPadPro12_9,
    
    kTCDevice1GiPadPro10_5,
    kTCDevice2GiPadPro12_9,
    
    kTCDeviceAppleTV2,
    kTCDeviceAppleTV3,
    kTCDeviceAppleTV4,
    
    kTCDeviceUnknowniPhone,
    kTCDeviceUnknowniPod,
    kTCDeviceUnknowniPad,
    kTCDeviceUnknownAppleTV,
    
    
    kTCDeviceCount,
};

typedef NS_ENUM(NSInteger, TCDeviceFamily) {
    kTCDeviceFamilyUnknown = 0,
    kTCDeviceFamilyiPhone,
    kTCDeviceFamilyiPod,
    kTCDeviceFamilyiPad,
    kTCDeviceFamilyAppleTV,
};

typedef NS_ENUM(NSInteger, TCDeviceScreen) {
    kTCDeviceScreenUnknown = 0,
    kTCDeviceScreen3Dot5inch,
    kTCDeviceScreen4inch,
    kTCDeviceScreen4Dot7inch,
    kTCDeviceScreen5Dot5inch,
};


NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (TCHardware)

- (NSString *)platform;
- (NSString *)hwmodel;
- (TCDevicePlatform)platformType;
- (NSString *)platformString;
- (TCDeviceScreen)deivceScreen;

- (NSUInteger)cpuFrequency;
- (NSUInteger)busFrequency;
- (NSUInteger)cpuCount;
- (NSUInteger)totalMemory;
- (NSUInteger)userMemory;

- (unsigned long long)appUsedMemory;
- (unsigned long long)appFreeMemory;

- (nullable NSNumber *)totalDiskSpace;
- (nullable NSNumber *)freeDiskSpace;

- (nullable NSString *)macaddress;

- (BOOL)hasRetinaDisplay;
- (TCDeviceFamily)deviceFamily;
- (BOOL)hasCellular;
- (BOOL)cellularAccessable;


#pragma mark -

+ (BOOL)isIpv4Available;
+ (BOOL)isIpv6Available;

// enumerate running IPv4, IPv6 interfaces. Skip the loopback interface.
+ (void)enumerateNetworkInterfaces:(void (^)(struct ifaddrs *addr, BOOL *stop))block;

+ (nullable NSString *)stringFromSockAddr:(const struct sockaddr *)addr includeService:(BOOL)includeService;

typedef NS_ENUM(NSInteger, TCNetworkInterfaceType) {
    kTCNetworkInterfaceTypeLoopback, // lo0
    kTCNetworkInterfaceTypeCellular, // pdp_ip0
    kTCNetworkInterfaceTypeWiFi, // en0
    kTCNetworkInterfaceTypeHotspot, // bridge100
    kTCNetworkInterfaceTypeUSB, // en2, iOS 11 iPod: en3
    kTCNetworkInterfaceTypeBluetooth, // en3, iOS 11 iPod: en2
    
    kTCNetworkInterfaceTypeNEVPN, // utun1
    kTCNetworkInterfaceTypePersonalVPN, // ipsec0
    
    kTCNetworkInterfaceTypeCount,
};

+ (nullable NSString *)ipFromInterface:(TCNetworkInterfaceType)type;

@end

NS_ASSUME_NONNULL_END

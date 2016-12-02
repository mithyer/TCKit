//
//  NSBundle+TCHelper.m
//  TCKit
//
//  Created by dake on 16/12/2.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "NSBundle+TCHelper.h"

@implementation NSBundle (TCHelper)

+ (NSBundle *)hostMainBundle
{
    static NSBundle *s_bundle = nil;
    if (nil == s_bundle) {
        s_bundle = NSBundle.mainBundle;
        if ([s_bundle.bundleURL.pathExtension isEqualToString:@"appex"]) {
            NSURL *url = s_bundle.bundleURL.URLByDeletingLastPathComponent.URLByDeletingLastPathComponent;
            s_bundle = [NSBundle bundleWithURL:url];
        }
    }
    return s_bundle;
}

+ (BOOL)isHostMainBundle
{
    return [NSBundle.mainBundle isEqual:self.hostMainBundle];
}

@end

@implementation UIImage (AppExtension)

+ (UIImage *)hostMainBundleImageNamed:(NSString *)name
{
    return [UIImage imageNamed:name inBundle:NSBundle.hostMainBundle compatibleWithTraitCollection:nil];
}

@end

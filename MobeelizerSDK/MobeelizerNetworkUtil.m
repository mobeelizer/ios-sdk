// 
// MobeelizerNetworkUtil.m
// 
// Copyright (C) 2012 Mobeelizer Ltd. All Rights Reserved.
//
// Mobeelizer SDK is free software; you can redistribute it and/or modify it 
// under the terms of the GNU Affero General Public License as published by 
// the Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
// for more details.
//
// You should have received a copy of the GNU Affero General Public License 
// along with this program; if not, write to the Free Software Foundation, Inc., 
// 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
// 

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreFoundation/CoreFoundation.h>

#import "Mobeelizer+Internal.h"
#import "MobeelizerNetworkUtil.h"

@implementation MobeelizerNetworkUtil

+ (MobeelizerNetworkStatus)checkNetworkStatus {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    
    if(reachability == nil) {
        MobeelizerLog(@"Reachability is nil.");
        return MobeelizerNetworkStatusNone;
    }
    
    SCNetworkReachabilityFlags flags;
    
    if (!SCNetworkReachabilityGetFlags(reachability, &flags)) {
        CFRelease(reachability);
        NSLog(@"###2 why?");
        return MobeelizerNetworkStatusNone;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        CFRelease(reachability);
        MobeelizerLog(@"Target host is not reachable.");
        return MobeelizerNetworkStatusNone;
    }
    
    MobeelizerNetworkStatus status = MobeelizerNetworkStatusNone;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        MobeelizerLog(@"If target host is reachable and no connection is required then we'll assume (for now) that your on Wi-Fi");
        status = MobeelizerNetworkStatusWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        MobeelizerLog(@"... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs");        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            MobeelizerLog(@"... and no [user] intervention is needed");        
            status = MobeelizerNetworkStatusWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        MobeelizerLog(@"... but WWAN connections are OK if the calling application is using the CFNetwork (CFSocketStream?) APIs");        
        status = MobeelizerNetworkStatusMobile;
    }
    
    CFRelease(reachability);

    return status;
}

@end

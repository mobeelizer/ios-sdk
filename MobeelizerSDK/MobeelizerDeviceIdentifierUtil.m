// 
// MobeelizerDeviceIdentifierUtil.m
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

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "MobeelizerDeviceIdentifierUtil.h"
#import "MobeelizerDigestUtil.h"

@interface MobeelizerDeviceIdentifierUtil ()
    
+ (NSString *)macaddress;
+ (NSString *)bundleIdentifier;

@end

@implementation MobeelizerDeviceIdentifierUtil

+ (NSString *)deviceIdentifier {    
    return [MobeelizerDigestUtil stringFromMD5:[NSString stringWithFormat:@"%@%@",[MobeelizerDeviceIdentifierUtil macaddress], [MobeelizerDeviceIdentifierUtil bundleIdentifier]]];
}

+ (NSString *)macaddress {
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return nil;
    }
    
    if (sysctl(mib, 6, nil, &len, nil, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return nil;
    }
    
    if ((buf = malloc(len)) == nil) {
        printf("Could not allocate memory. error!\n");
        return nil;
    }
    
    if (sysctl(mib, 6, buf, &len, nil, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return nil;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macaddress = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                            *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return macaddress;
}

+ (NSString *)bundleIdentifier {
    return [[NSBundle mainBundle] bundleIdentifier];
}

@end

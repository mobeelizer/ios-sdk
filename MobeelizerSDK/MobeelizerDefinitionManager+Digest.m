// 
// MobeelizerDefinitionManager+Digest.m
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

#import "MobeelizerDefinitionManager+Digest.h"
#import "MobeelizerDigestUtil.h"

@implementation MobeelizerDefinitionManager (Digest)

- (NSString *)digestVersion {
    NSMutableString *digest = [NSMutableString string];    
    [digest appendString:self.vendor];    
    [digest appendString:@"$"];
    [digest appendString:self.application];
    [digest appendString:@"$"];
    [digest appendString:self.conflictMode];
    [digest appendString:@"$"];
    [MobeelizerDefinitionManager addSortedDigests:self.devices toDigest:digest];
    [digest appendString:@"$"];
    [MobeelizerDefinitionManager addSortedDigests:self.groups toDigest:digest];    
    [digest appendString:@"$"];
    [MobeelizerDefinitionManager addSortedDigests:[self versionDigestRoles] toDigest:digest];
    [digest appendString:@"$"];
    [MobeelizerDefinitionManager digest:self.models andAddSortedToDigest:digest];    
    
    return [MobeelizerDigestUtil stringFromSHA256:digest];
}

+ (void)addSortedDigests:(NSArray *)digests toDigest:(NSMutableString *)digest {
    NSArray *sortedDigest = [digests sortedArrayUsingSelector:@selector(compare:)];
    [digest appendString:[sortedDigest componentsJoinedByString:@"&"]];
}

+ (void)digest:(NSArray *)objects andAddSortedToDigest:(NSMutableString *)digest {
    NSMutableArray *digests = [NSMutableArray array];
    
    for(id object in objects) {
        [digests addObject:[object performSelector:@selector(versionDigest)]];
    }
    
    [MobeelizerDefinitionManager addSortedDigests:digests toDigest:digest];
}

- (NSArray *)versionDigestRoles {
    NSMutableArray *digests = [NSMutableArray array];
    
    for(NSArray *role in self.roles) {
        [digests addObject:[NSString stringWithFormat:@"{%@$%@}", [role objectAtIndex:0], [role objectAtIndex:1]]];
    }
    
    return digests;
}

@end

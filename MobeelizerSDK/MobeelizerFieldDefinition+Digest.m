// 
// MobeelizerFieldDefinition+Digest.m
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

#import "MobeelizerFieldDefinition+Digest.h"
#import "MobeelizerFieldDefinition+Internal.h"
#import "MobeelizerDefinitionManager+Digest.h"

@implementation MobeelizerFieldDefinition (Digest)

- (NSString *)versionDigest {
    NSMutableString *digest = [NSMutableString string];
    [digest appendString:self.name];
    [digest appendString:@"{"];
    [digest appendString:self.type];
    [digest appendString:@"$"];    
    [digest appendString:(self.required ? @"true" : @"false")];
    [digest appendString:@"$"];        
    [digest appendString:(self.defaultValue == nil ? @"null" : [NSString stringWithFormat:@"%@", self.defaultValue])];
    [digest appendString:@"$"];
    
    NSMutableArray *credentialsDigests = [NSMutableArray array];
    NSDictionary *credentials = self.credentials;    
    for(NSString *credentialsRole in [credentials keyEnumerator]) {
        MobeelizerFieldCredentials *credential = [credentials objectForKey:credentialsRole];
        [credentialsDigests addObject:[self calculateCredentialsDigest:credentialsRole readAllowed:credential.readAllowed createAllowed:credential.createAllowed updateAllowed:credential.updateAllowed]];
    }    
    [MobeelizerDefinitionManager addSortedDigests:credentialsDigests toDigest:digest];
    
    [digest appendString:@"$"];
    
    NSMutableArray *optionsDigests = [NSMutableArray array];
    NSDictionary *options = self.options;
    for(NSString *optionName in [options keyEnumerator]) {
        [optionsDigests addObject:[NSString stringWithFormat:@"%@=%@", optionName, [options valueForKey:optionName]]];
    }
    [MobeelizerDefinitionManager addSortedDigests:optionsDigests toDigest:digest];
    
    [digest appendString:@"}"];
    return digest;
}

- (NSString *)calculateCredentialsDigest:(NSString *)role readAllowed:(MobeelizerCredential)readAllowed createAllowed:(MobeelizerCredential)createAllowed updateAllowed:(MobeelizerCredential)updateAllowed {
    return [NSString stringWithFormat:@"%@=%d%d%d%d%d", role, [self calculateCredentialDigest:readAllowed], [self calculateCredentialDigest:createAllowed], [self calculateCredentialDigest:updateAllowed], 0, 0];
}

- (NSInteger)calculateCredentialDigest:(MobeelizerCredential)credential {
    switch (credential) {
        case MobeelizerCredentialOwn:
            return 1;
        case MobeelizerCredentialGroup:
            return 2;
        case MobeelizerCredentialAll:
            return 3;            
        default:
            return 0;
    }
}


@end

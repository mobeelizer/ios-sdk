// 
// MobeelizerDevelopmentConnectionManager.m
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

#import "Mobeelizer.h"
#import "MobeelizerOperationError.h"
#import "MobeelizerDevelopmentConnectionManager.h"

@interface MobeelizerDevelopmentConnectionManager ()
    
@property (nonatomic, strong) NSString *developmentRole;
    
@end

@implementation MobeelizerDevelopmentConnectionManager

@synthesize developmentRole=_developmentRole;

- (id)initWithRole:(NSString *)developmentRole {
    if(self = [super init]) {
        _developmentRole = developmentRole;
    }
    return self;
}

- (void)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password returningError:(MobeelizerOperationError **)error {
    self.instance = instance;
    self.user = user;
    self.group = [self.developmentRole componentsSeparatedByString:@"-"][0];
    self.role = self.developmentRole;
    self.instanceGuid = @"00000000-0000-0000-0000-000000000000";
    self.initialSyncRequired = FALSE;
}

@end

// 
// MobeelizerInternalDatabase.h
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

#import <Foundation/Foundation.h>

@class Mobeelizer;

@interface MobeelizerInternalDatabase : NSObject

- (id)initWithMobeelizer:(Mobeelizer *)mobeelizer;
- (void)destroy;
- (BOOL)checkIfInitializationIsRequiredForInstance:(NSString *)instance andInstanceGuid:(NSString *)instanceGuid andUser:(NSString *)user;
- (BOOL)isInitialSyncRequiredForInstance:(NSString *)instance andInstanceGuid:(NSString *)instanceGuid andUser:(NSString *)user;
- (void)setInitialSyncAsNotRequiredForInstance:(NSString *)instance andUser:(NSString *)user;
- (void)setRole:(NSString *)role andInstanceGuid:(NSString *)instanceGuid forInstance:(NSString *)instance andUser:(NSString *)user andPassword:(NSString *)password;
- (NSDictionary *)getRoleAndInstanceGuidForInstance:(NSString *)instance andUser:(NSString *)user andPassword:(NSString *)password;
- (void)clearRoleAndInstanceGuidForInstance:(NSString *)instance andUser:(NSString *)user;
- (void)setInitializationFinishedForInstance:(NSString *)instance andInstanceGuid:(NSString *)instanceGuid andUser:(NSString *)user;

@end

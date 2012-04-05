// 
// Mobeelizer+Internal.h
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
#import "MobeelizerDatabase.h"
#import "MobeelizerInternalDatabase.h"
#import "MobeelizerConnectionManager.h"
#import "MobeelizerDefinitionManager.h"
#import "MobeelizerFileManager.h"

#define SHOW_LOG
#undef SHOW_SQL

#ifdef SHOW_LOG
#define MobeelizerLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define MobeelizerLog(...)
#endif

#ifdef SHOW_SQL
#define MobeelizerLogSql(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define MobeelizerLogSql(...)
#endif

#define MobeelizerException(ex, fmt, ...) [NSException raise:ex format:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__];

@interface Mobeelizer ()

@property (nonatomic, readonly) NSString *vendor;
@property (nonatomic, readonly) NSString *application;
@property (nonatomic, readonly) NSString *versionDigest;
@property (nonatomic, readonly, strong) NSString *device;
@property (nonatomic, readonly, strong) NSString *deviceIdentifier;
@property (nonatomic, readonly, strong) NSURL *url;
@property (nonatomic, readonly) NSString *instance;
@property (nonatomic, readonly) NSString *user;
@property (nonatomic, readonly) NSString *role;
@property (nonatomic, readonly) NSString *instanceGuid;
@property (nonatomic, readonly, strong) NSString *mode;
@property (nonatomic, readonly, strong) MobeelizerDatabase *database;
@property (nonatomic, readonly, strong) MobeelizerInternalDatabase *internalDatabase;
@property (nonatomic, readonly, strong) MobeelizerDefinitionManager *definitionManager;
@property (nonatomic, readonly, strong) MobeelizerConnectionManager *connectionManager;
@property (nonatomic, readonly, strong) MobeelizerFileManager *fileManager;
@property (nonatomic, readonly) BOOL multitaskingSupported;

+ (Mobeelizer *)sharedInstance;

@end

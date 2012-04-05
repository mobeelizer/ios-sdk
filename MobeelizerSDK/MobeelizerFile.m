// 
// MobeelizerFile.m
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

#import "MobeelizerFile+Internal.h"
#import "Mobeelizer+Internal.h"

@interface MobeelizerFile ()

@property (nonatomic, weak) Mobeelizer *mobeelizer;

@end 

@implementation MobeelizerFile

@synthesize name=_name, guid=_guid, mobeelizer=_mobeelizer;
@dynamic data;

- (id)initWithGuid:(NSString *)guid andName:(NSString *)name andMobeelizer:(Mobeelizer *)mobeelizer {
    if(self = [super init]) {
        _mobeelizer = mobeelizer;
        if(![self.mobeelizer.fileManager fileExists:guid]) {
            MobeelizerException(@"File not found", @"File with guid %@ not found", guid);
        }        
        _guid = guid;
        _name = name;        
    } 
    return self;
}

- (id)initWithName:(NSString *)name andData:(NSData *)data andMobeelizer:(Mobeelizer *)mobeelizer {
    if(self = [super init]) {
        _mobeelizer = mobeelizer;
        _guid = [self.mobeelizer.fileManager addFile:data];
        _name = name;
    } 
    return self;    
}

- (NSData *)data {
    return [self.mobeelizer.fileManager getDataForGuid:self.guid];
}

@end

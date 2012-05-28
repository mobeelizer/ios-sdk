// 
// MobeelizerFileFieldType.m
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

#import "MobeelizerFileFieldType.h"
#import "MobeelizerFile+Internal.h"
#import "Mobeelizer+Internal.h"
#import "MobeelizerError+Internal.h"
#import "MobeelizerErrors+Internal.h"

@implementation MobeelizerFileFieldType

- (void)addValueFromObject:(id)object toQueryParams:(NSMutableArray *)params {
    MobeelizerFile *value = [object valueForKey:self.name];
    
    if(value == nil) {
        [params addObject:[NSNull null]];
        [params addObject:[NSNull null]];
    } else {
        [params addObject:value.guid];
        [params addObject:value.name];
    }
}

- (void)addValueFromRow:(NSDictionary *)row toObject:(id)object {
    NSString *guid = [row valueForKey:[NSString stringWithFormat:@"%@_guid", self.name]];
    
    if(guid == nil) {
        return;
    }
    
    NSString *name = [row valueForKey:[NSString stringWithFormat:@"%@_name", self.name]];
    
    [object setValue:[[MobeelizerFile alloc] initWithGuid:guid andName:name andMobeelizer:[Mobeelizer sharedInstance]] forKey:self.name];
}

- (void)addValueFromJson:(NSDictionary *)json toObject:(id)object {
    NSError* error = nil;
    
    NSString *fieldData = [json valueForKey:self.name];
    
    if(fieldData == nil) {
        return;
    }
    
    NSDictionary* fieldJson = [NSJSONSerialization JSONObjectWithData:[fieldData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    if(error != nil) {
        MobeelizerLog(@"JSON parser has failed: %@ for data: [%@]", [error localizedDescription], fieldData);
        return;
    }
    
    [object setValue:[[MobeelizerFile alloc] initWithGuid:[fieldJson valueForKey:@"guid"] andName:[fieldJson valueForKey:@"filename"] andMobeelizer:[Mobeelizer sharedInstance]] forKey:self.name];
}

- (void)addValueFromRow:(NSDictionary *)row toJson:(NSDictionary *)json {
    NSString *guid = [row valueForKey:[NSString stringWithFormat:@"%@_guid", self.name]];
    
    if(guid == nil) {
        return;
    }
    
    NSString *name = [row valueForKey:[NSString stringWithFormat:@"%@_name", self.name]];
    
    [json setValue:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:guid, name, nil] forKeys:[NSArray arrayWithObjects:@"guid", @"filename", nil]] forKey:self.name];
}

- (NSArray *)getColumns {
    return [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@_guid", self.name], [NSString stringWithFormat:@"%@_name", self.name], nil];
}

- (NSString *)queryForCreate {
    NSMutableString *query = [NSMutableString stringWithFormat:@"%@_guid TEXT(36)", self.name];    
    
    if(self.required) {
        [query appendString:@" NOT NULL"];
    }
    
    [query appendString:@" REFERENCES _files(_guid), "];
    [query appendFormat:@"%@_name TEXT(255)", self.name];

    if(self.required) {
        [query appendString:@" NOT NULL"];
    }

    return query;
}

- (NSArray *)supportedCTypes {
    return [NSArray arrayWithObject:@"MobeelizerFile"];
}

- (NSString *)dictionaryCType {
    return @"MobeelizerFile";
}

- (NSString *)supportedTypes {
    return @"MobeelizerFile";
}

@end

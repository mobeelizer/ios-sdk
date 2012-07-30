// 
// MobeelizerDefinitionManager.m
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
#import "Mobeelizer+Internal.h"
#import "MobeelizerModelDefinition+Definition.h"
#import "MobeelizerModelCredentials+Internal.h"
#import "MobeelizerFieldDefinition+Definition.h"
#import "MobeelizerFieldCredentials+Internal.h"
#import "MobeelizerTextFieldType.h"
#import "MobeelizerBelongsToFieldType.h"
#import "MobeelizerBooleanFieldType.h"
#import "MobeelizerDateFieldType.h"
#import "MobeelizerDecimalFieldType.h"
#import "MobeelizerIntegerFieldType.h"
#import "MobeelizerFileFieldType.h"

@interface MobeelizerDefinitionManager ()

@property (nonatomic, strong) MobeelizerModelDefinition *lastModel;
@property (nonatomic, strong) MobeelizerFieldDefinition *lastField;
@property (nonatomic, strong) NSString *lastOptionName;
@property (nonatomic, strong) NSString *lastOptionValue;
@property (nonatomic, weak) NSString *modelPrefix;

- (MobeelizerFieldDefinition *)allocFieldWithType:(NSString *)type;

@end

@implementation MobeelizerDefinitionManager

@synthesize application=_application, vendor=_vendor, versionDigest=_versionDigest, groups=_groups, roles=_roles, devices=_devices, models=_models, lastModel=_lastModel, lastField=_lastField, lastOptionName=_lastOptionName, lastOptionValue=_lastOptionValue, modelPrefix=_modelPrefix, conflictMode=_conflictMode;

- (id)initWithAsset:(NSString *)theDefinitionAsset andModelPrefix:(NSString *)thePrefix {
    if (self = [super init]) {
        _modelPrefix = thePrefix;
        
        NSArray *fileComponents = [theDefinitionAsset componentsSeparatedByString:@"."];        
        
        NSArray *pathComponents = [[fileComponents objectAtIndex:0] componentsSeparatedByString:@"/"];        
        
        NSString *path = nil;
        
        if([pathComponents count] == 1) {
            path = [[NSBundle mainBundle] pathForResource:[pathComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
        } else {
            path = [[NSBundle mainBundle] pathForResource:[pathComponents objectAtIndex:([pathComponents count] - 1)] ofType:[fileComponents objectAtIndex:1] inDirectory:[[pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - 1)] componentsJoinedByString:@"/"]];
        }
        
        MobeelizerLog(@"Application definition: %@", path);
        
        NSError *error;
        
        NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&error];
        
        if(error != nil) {
            MobeelizerLog(@"Cannot read application definition: %@", [error localizedDescription]);
            return nil;
        }
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        
        BOOL result = [parser parse];
        
        if(!result) {
            MobeelizerLog(@"Cannot parse application definition: %@", [[parser parserError] localizedDescription]);
            return nil;
        }
        
        if(self.lastModel != nil || self.lastField != nil || self.lastOptionName != nil || self.lastOptionValue != nil) {
            MobeelizerLog(@"Error while parsing application definition.");
            return nil;
        }
        
        _versionDigest = [self digestVersion];
    }
    
    return self;
}

- (NSArray *)modelsForRole:(NSString *)role andOwner:(NSString *)owner andGroup:(NSString *)group {
    NSMutableArray *array = [NSMutableArray array];
    
    for(int i = 0; i < [self.models count]; i++) {        
        MobeelizerModelDefinition *modelForRole = [[self.models objectAtIndex:i] modelForRole:role andOwner:owner andGroup:group];
        
        if(modelForRole != nil) {
            [array addObject:modelForRole];
        }
    }
    
    return array;
}

#pragma mark parsing xml

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.groups = [NSMutableArray array];
    self.devices = [NSMutableArray array];
    self.roles = [NSMutableArray array];
    self.models = [NSMutableArray array];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributes {
    if([elementName isEqualToString:@"application"]) {
        self.application = [attributes objectForKey:@"application"];
        self.vendor = [attributes objectForKey:@"vendor"];
        self.conflictMode = [attributes objectForKey:@"conflictMode"];
    } else if([elementName isEqualToString:@"device"]) {
        [self.devices addObject:[attributes objectForKey:@"name"]];
    } else if([elementName isEqualToString:@"group"]) {
        [self.groups addObject:[attributes objectForKey:@"name"]];
    } else if([elementName isEqualToString:@"role"]) {
        NSString *device = [attributes objectForKey:@"device"];
        NSString *group = [attributes objectForKey:@"group"];
        [self.roles addObject:[NSArray arrayWithObjects:group, device, nil]];
    } else if([elementName isEqualToString:@"model"]) {
        self.lastModel = [[MobeelizerModelDefinition alloc] initWithAttributes:attributes andModelPrefix:self.modelPrefix];
        [self.models addObject:self.lastModel];
    } else if([elementName isEqualToString:@"field"]) {
        self.lastField = [[self allocFieldWithType:[attributes objectForKey:@"type"]] initWithAttributes:attributes];
        [self.lastModel addField:self.lastField];
    } else if([elementName isEqualToString:@"option"]) { 
        self.lastOptionName = [attributes objectForKey:@"name"];
    } else if([elementName isEqualToString:@"credential"] && self.lastField != nil) { 
        [self.lastField addCredentials:[[MobeelizerFieldCredentials alloc] initWithAttributes:attributes] forRole:[attributes objectForKey:@"role"]];
    } else if([elementName isEqualToString:@"credential"]) { 
        [self.lastModel addCredentials:[[MobeelizerModelCredentials alloc] initWithAttributes:attributes] forRole:[attributes objectForKey:@"role"]];
    }
}

- (MobeelizerFieldDefinition *)allocFieldWithType:(NSString *)type {
    if([type isEqualToString:@"TEXT"]) {
        return [MobeelizerTextFieldType alloc];
    } else if([type isEqualToString:@"INTEGER"]) { 
        return [MobeelizerIntegerFieldType alloc];
    } else if([type isEqualToString:@"BOOLEAN"]) { 
        return [MobeelizerBooleanFieldType alloc];
    } else if([type isEqualToString:@"DECIMAL"]) { 
        return [MobeelizerDecimalFieldType alloc];
    } else if([type isEqualToString:@"DATE"]) { 
        return [MobeelizerDateFieldType alloc];
    } else if([type isEqualToString:@"FILE"]) { 
        return [MobeelizerFileFieldType alloc];
    } else if([type isEqualToString:@"BELONGS_TO"]) { 
        return [MobeelizerBelongsToFieldType alloc];
    } else {
        MobeelizerException(@"Error while alloc type", @"Unknown field type: %@", type);       
        return nil;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if([elementName isEqualToString:@"model"]) {
        self.lastModel = nil;
    } else if([elementName isEqualToString:@"field"]) {
        self.lastField = nil;
    } else if([elementName isEqualToString:@"option"]) { 
        [self.lastField addOption:self.lastOptionName withValue:self.lastOptionValue];
        self.lastOptionName = nil;
        self.lastOptionValue = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(self.lastOptionName != nil) {        
        self.lastOptionValue = string;
    }
}

@end

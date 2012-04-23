// 
// MobeelizerRealConnectionManager.m
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

#import "MobeelizerRealConnectionManager.h"
#import "Mobeelizer+Internal.h"
#import "MobeelizerInternalDatabase.h"
#import "MobeelizerNetworkUtil.h"

@interface MobeelizerRealConnectionManager ()

@property (nonatomic, strong) NSString *password;
@property (nonatomic, weak) Mobeelizer *mobeelizer;

- (NSData *)requestPath:(NSString *)path withMethod:(NSString *)method withParams:(NSDictionary *)params returningStatusCode:(int *)statusCode;
- (NSData *)requestPath:(NSString *)path withFile:(NSData *)file returningStatusCode:(int *)statusCode;

@end

@implementation MobeelizerRealConnectionManager

@synthesize mobeelizer=_mobeelizer, password=_password;

- (id)initWithMobeelizer:(Mobeelizer *)mobeelizer {
    if(self = [super init]) {
        _mobeelizer = mobeelizer;
    }
    return self;
}

- (BOOL) networkConnected {
    return [MobeelizerNetworkUtil checkNetworkStatus] != MobeelizerNetworkStatusNone;
}

- (MobeelizerLoginStatus)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password {
    BOOL networkConnected = [self networkConnected];
    
    self.instance = instance;
    self.user = user;
    self.password = password;
    self.initialSyncRequired = FALSE;
    
    if (!networkConnected) {
        NSDictionary *roleAndInstanceGuid = [self.mobeelizer.internalDatabase getRoleAndInstanceGuidForInstance:self.instance andUser:self.user andPassword:self.password];
        
        if (self.role == nil) {
            MobeelizerLog(@"Login failure. Missing connection failure.");
            self.instance = nil;
            self.user = nil;
            self.password = nil;
            return MobeelizerLoginStatusMissingConnectionFailure;
        } else {
            MobeelizerLog(@"Login with role '%@' from database successful.", self.role);
            self.role = [roleAndInstanceGuid objectForKey:@"role"];
            self.instanceGuid = [roleAndInstanceGuid objectForKey:@"instanceGuid"];
            return MobeelizerLoginStatusOk; 
        }
    }
    
    int statusCode;
    
    NSData *data = [self requestPath:@"authenticate" withMethod:@"GET" withParams:[NSDictionary dictionary] returningStatusCode:&statusCode];
    
    if(statusCode != 200) {
        NSDictionary *roleAndInstanceGuid = [self.mobeelizer.internalDatabase getRoleAndInstanceGuidForInstance:self.instance andUser:self.user andPassword:self.password];
        
        if (roleAndInstanceGuid == nil) {
            MobeelizerLog(@"Login failure. Connection failure with status %d.", statusCode);
            self.instance = nil;
            self.user = nil;
            self.password = nil;
            return MobeelizerLoginStatusConnectionFailure;
        } else {
            MobeelizerLog(@"Login with role '%@' from database successful.", self.role);
            self.role = [roleAndInstanceGuid objectForKey:@"role"];
            self.instanceGuid = [roleAndInstanceGuid objectForKey:@"instanceGuid"];
            return MobeelizerLoginStatusOk; 
        }
    }
    
    NSError* error = nil;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if(error != nil) {
        MobeelizerLog(@"JSON parser has failed: %@ for data: %@", [error localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        return MobeelizerLoginStatusOtherFailure;
    }
    
    NSString *status = [json objectForKey:@"status"];
    
    if([status isEqualToString:@"OK"]) {
        self.role = [[json objectForKey:@"content"] objectForKey:@"role"];        
        self.instanceGuid = [[json objectForKey:@"content"] objectForKey:@"instanceGuid"];        
        self.initialSyncRequired = [self.mobeelizer.internalDatabase isInitialSyncRequiredForInstance:self.instance andInstanceGuid:self.instanceGuid andUser:self.user];
        
        [self.mobeelizer.internalDatabase setRole:self.role andInstanceGuid:self.instanceGuid forInstance:self.instance andUser:self.user andPassword:self.password];
        
        MobeelizerLog(@"Login with role '%@', instanceGuid '%@' and initial sync required %@", self.role, self.instanceGuid, self.initialSyncRequired ? @"TRUE" : @"FALSE");

        return MobeelizerLoginStatusOk; 
    } else { 
        [self.mobeelizer.internalDatabase clearRoleAndInstanceGuidForInstance:self.instance andUser:self.user];
        
        self.instance = nil;
        self.user = nil;
        self.password = nil;
        
        if([status isEqualToString:@"ERROR"]) {
            NSDictionary *content = [json objectForKey:@"content"];
            NSString *message = [content objectForKey:@"messageCode"];
            
            if ([message isEqualToString:@"authenticationFailure"]) {
                MobeelizerLog(@"Login failure. Authentication error: %@", [content objectForKey:@"message"]);
                return MobeelizerLoginStatusAuthenticationFailure;
            } else {
                MobeelizerLog(@"Login failure. Error: %@", [content objectForKey:@"message"]);
                return MobeelizerLoginStatusOtherFailure;
            }
        } else {
            MobeelizerLog(@"Login failure. Invalid response: %@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
            return MobeelizerLoginStatusOtherFailure;
        }
    }
}

- (NSString *)requestSyncAll {
    MobeelizerLog(@"Request sync all");
    
    int statusCode;
    
    NSData *data = [self requestPath:@"synchronizeAll" withMethod:@"POST" withParams:[NSDictionary dictionary] returningStatusCode:&statusCode];
    
    if(statusCode != 200) {
        MobeelizerException(@"Request sync all failure.", @"Request sync all failure. Connection failure with status %d.", statusCode);
        return nil;
    }
    
    NSError* error = nil;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if(error != nil) {
        MobeelizerLog(@"JSON parser has failed: %@ for data: %@", [error localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        return nil;
    }
    
    NSString *status = [json objectForKey:@"status"];

    if([status isEqualToString:@"OK"]) {
        return [json objectForKey:@"content"];
    } else if([status isEqualToString:@"ERROR"]) {
        MobeelizerException(@"Request sync all failure.", @"Request sync all with message: %@.", [[json objectForKey:@"content"] objectForKey:@"message"]);
        return nil;
    } else {
        MobeelizerException(@"Request sync all failure.", @"Request sync all: %@.", [json objectForKey:@"content"]);
        return nil;
    }
}

- (NSString *)requestSyncDiff:(NSString *)dataPath {
    MobeelizerLog(@"Request Sync Diff");
    
    int statusCode;
    
    NSData *data = [self requestPath:@"synchronize" withFile:[NSData dataWithContentsOfFile:dataPath] returningStatusCode:&statusCode];
    
    if(statusCode != 200) {
        MobeelizerException(@"Request sync diff failure.", @"Request sync diff failure. Connection failure with status %d.", statusCode);
        return nil;
    }
    
    NSError* error = nil;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if(error != nil) {
        MobeelizerLog(@"JSON parser has failed: %@ for data: %@", [error localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        return nil;
    }
    
    NSString *status = [json objectForKey:@"status"];
    
    if([status isEqualToString:@"OK"]) {
        return [json objectForKey:@"content"];
    } else if([status isEqualToString:@"ERROR"]) {
        MobeelizerException(@"Request sync diff failure.", @"Request sync diff with message: %@.", [[json objectForKey:@"content"] objectForKey:@"message"]);
        return nil;
    } else {
        MobeelizerException(@"Request sync diff failure.", @"Request sync diff: %@.", [json objectForKey:@"content"]);
        return nil;
    }
}

- (BOOL)waitUntilSyncRequestComplete:(NSString *)ticket {
    for(int i = 0; i < 100; i++) {
        MobeelizerLog(@"Check task status: %@", ticket);
        
        int statusCode;
        
        NSData *data = [self requestPath:@"checkStatus" withMethod:@"GET" withParams:[NSDictionary dictionaryWithObject:ticket forKey:@"ticket"]  returningStatusCode:&statusCode];
        
        if(statusCode != 200) {
            MobeelizerException(@"Check task status failure.", @"Check task status failure. Connection failure with status %d.", statusCode);
            return FALSE;
        }
        
        NSError* error = nil;
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if(error != nil) {
            MobeelizerLog(@"JSON parser has failed: %@ for data: %@", [error localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
            return FALSE;
        }
        
        NSString *status = [json objectForKey:@"status"];
        
        if([status isEqualToString:@"OK"]) {
            NSString *taskStatus = [[json objectForKey:@"content"] objectForKey:@"status"];

            MobeelizerLog(@"Check task status: %@ = %@", ticket, taskStatus);
            
            if([taskStatus isEqualToString:@"REJECTED"]) {
                MobeelizerLog(@"Check task status: REJECTED with> result %@ and message %@", [[json objectForKey:@"content"] objectForKey:@"result"], [[json objectForKey:@"content"] objectForKey:@"message"]);
                return FALSE;
            } else if([taskStatus isEqualToString:@"FINISHED"]) {
                return TRUE;
            }
        } else if([status isEqualToString:@"ERROR"]) {
            MobeelizerException(@"Check task status failure.", @"Check task status with message: %@.", [[json objectForKey:@"content"] objectForKey:@"message"]);
            return FALSE;
        } else {
            MobeelizerException(@"Check task status failure.", @"Check task status: %@.", [json objectForKey:@"content"]);
            return FALSE;
        }
        
        [NSThread sleepForTimeInterval:pow(6.0, log(i+1.0))];
    }
    
    return FALSE;
}

- (NSString *)getSyncData:(NSString *)ticket {
    MobeelizerLog(@"Get sync data: %@", ticket);
    
    int statusCode;
    
    NSData *data = [self requestPath:@"data" withMethod:@"GET" withParams:[NSDictionary dictionaryWithObject:ticket forKey:@"ticket"] returningStatusCode:&statusCode];
    
    if(statusCode != 200) {
        MobeelizerException(@"Get sync data failure.", @"Get sync data failure. Connection failure with status %d.", statusCode);
    }
    
    NSString *dataFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dat", ticket]];

    if([data writeToFile:dataFilePath atomically:TRUE]) {
        return dataFilePath;
    } else {
        MobeelizerException(@"Get sync data failure.", @"Cannot save file.");
        return nil;
    }    
}

- (void)confirmTask:(NSString *)ticket {
    MobeelizerLog(@"Confirm task: %@", ticket);
    
    int statusCode;
    
    NSData *data = [self requestPath:@"confirm" withMethod:@"POST" withParams:[NSDictionary dictionaryWithObject:ticket forKey:@"ticket"] returningStatusCode:&statusCode];
    
    if(statusCode != 200) {
        MobeelizerException(@"Confirm task failure.", @"Confirm task failure. Connection failure with status %d.", statusCode);
    }
    
    NSError* error = nil;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if(error != nil) {
        MobeelizerLog(@"JSON parser has failed: %@ for data: %@", [error localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    }
    
    NSString *status = [json objectForKey:@"status"];
    
    if([status isEqualToString:@"OK"]) {
        return;
    } else if([status isEqualToString:@"ERROR"]) {
        MobeelizerException(@"Confirm task failure.", @"Confirm task with message: %@.", [[json objectForKey:@"content"] objectForKey:@"message"]);
    } else {
        MobeelizerException(@"Confirm task failure.", @"Confirm task failure: %@.", [json objectForKey:@"content"]);
    }
}

- (NSData *)requestPath:(NSString *)path withFile:(NSData *)file returningStatusCode:(int *)statusCode {    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.mobeelizer.url URLByAppendingPathComponent:path] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];

    [request setValue:self.mobeelizer.vendor forHTTPHeaderField:@"mas-vendor-name"];
    [request setValue:self.mobeelizer.application forHTTPHeaderField:@"mas-application-name"];    
    [request setValue:self.mobeelizer.versionDigest forHTTPHeaderField:@"mas-definition-digest"];
    [request setValue:self.mobeelizer.device forHTTPHeaderField:@"mas-device-name"];
    [request setValue:self.mobeelizer.deviceIdentifier forHTTPHeaderField:@"mas-device-identifier"];
    [request setValue:self.user forHTTPHeaderField:@"mas-user-name"];
    [request setValue:self.password forHTTPHeaderField:@"mas-user-password"];
    [request setValue:self.instance forHTTPHeaderField:@"mas-application-instance-name"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    [request addValue:contentType forHTTPHeaderField: @"content-type"];
    
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSASCIIStringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"content-disposition: form-data; name=\"file\"; filename=\"file\"\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
    [postbody appendData:[[NSString stringWithString:@"content-type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
    [postbody appendData:[NSData dataWithData:file]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSASCIIStringEncoding]];
    
    [request setHTTPBody:postbody];
    
    [request setHTTPMethod:@"POST"];
    
    NSError* error = nil;
    NSURLResponse* response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    *statusCode = [(NSHTTPURLResponse *)response statusCode]; 
    
    if(error != nil) {
        MobeelizerLog(@"Request has failed: %@", [error localizedDescription]);
    }
    
    return data;
}

- (NSData *)requestPath:(NSString *)path withMethod:(NSString *)method withParams:(NSDictionary *)params returningStatusCode:(int *)statusCode {
    if([params count] > 1) {
        MobeelizerException(@"Multiple params not supported", @"Multiple params not supported");
        return nil;
    }
       
    NSURL *url = [self.mobeelizer.url URLByAppendingPathComponent:path];
    
    if([params count] > 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?ticket=%@", url, [params valueForKey:@"ticket"]]];
    }    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    [request setValue:self.mobeelizer.vendor forHTTPHeaderField:@"mas-vendor-name"];
    [request setValue:self.mobeelizer.application forHTTPHeaderField:@"mas-application-name"];    
    [request setValue:self.mobeelizer.versionDigest forHTTPHeaderField:@"mas-definition-digest"];
    [request setValue:self.mobeelizer.device forHTTPHeaderField:@"mas-device-name"];
    [request setValue:self.mobeelizer.deviceIdentifier forHTTPHeaderField:@"mas-device-identifier"];
    [request setValue:self.user forHTTPHeaderField:@"mas-user-name"];
    [request setValue:self.password forHTTPHeaderField:@"mas-user-password"];
    [request setValue:self.instance forHTTPHeaderField:@"mas-application-instance-name"];
    [request setValue:[NSString stringWithFormat:@"ios-sdk-%@", [Mobeelizer version]] forHTTPHeaderField:@"mas-sdk-version"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    [request setHTTPMethod:method];
    
    NSError* error = nil;
    NSURLResponse* response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    *statusCode = [(NSHTTPURLResponse *)response statusCode]; 
    
    if(error != nil) {
        MobeelizerLog(@"Request has failed: %@", [error localizedDescription]);
    }
    
    return data;
}

@end

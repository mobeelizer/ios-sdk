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
#import "MobeelizerOperationError+Internal.h"

#define MobeelizerOperationError(code, fmt, ...) \
    MobeelizerLog(fmt, ##__VA_ARGS__); \
    *error = [[MobeelizerOperationError alloc] initWithCode:code andMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]; \
    return;

#define MobeelizerOperationErrorWithReturn(rtn, code, fmt, ...) \
    MobeelizerLog(fmt, ##__VA_ARGS__); \
    *error = [[MobeelizerOperationError alloc] initWithCode:code andMessage:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]; \
    return rtn;

#define MobeelizerOperationJsonError(json) \
    MobeelizerLog(@"Operation failure with message: %@.", [json objectForKey:@"message"]); \
    *error = [[MobeelizerOperationError alloc] initWithJson:json]; \
    return;

#define MobeelizerOperationJsonErrorWithReturn(rtn, json) \
    MobeelizerLog(@"Operation failure with message: %@.", [json objectForKey:@"message"]); \
    *error = [[MobeelizerOperationError alloc] initWithJson:json]; \
    return rtn;

@interface MobeelizerRealConnectionManager ()

@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, weak) Mobeelizer *mobeelizer;

- (NSData *)requestPath:(NSString *)path withMethod:(NSString *)method withParams:(NSDictionary *)params returningStatusCode:(int *)statusCode returningError:(MobeelizerOperationError **)error;
- (NSData *)requestPath:(NSString *)path withJson:(NSData *)json returningStatusCode:(int *)statusCode returningError:(MobeelizerOperationError **)error;
- (NSData *)requestPath:(NSString *)path withFile:(NSData *)file returningStatusCode:(int *)statusCode returningError:(MobeelizerOperationError **)error;

@end

@implementation MobeelizerRealConnectionManager

@synthesize mobeelizer=_mobeelizer, password=_password, deviceToken=_deviceToken;

- (id)initWithMobeelizer:(Mobeelizer *)mobeelizer {
    if(self = [super init]) {
        _mobeelizer = mobeelizer;
    }
    return self;
}

- (BOOL) networkConnected {
    return [MobeelizerNetworkUtil checkNetworkStatus] != MobeelizerNetworkStatusNone;
}

- (void)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password returningError:(MobeelizerOperationError **)error {
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
            
            MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_MISSING_CONNECTION, @"Login failure. Internet connection required.")
        } else {
            MobeelizerLog(@"Login with role '%@' from database successful.", self.role);
            self.role = [roleAndInstanceGuid objectForKey:@"role"];
            self.group = [[self.role componentsSeparatedByString:@"-"] objectAtIndex:0];
            self.instanceGuid = [roleAndInstanceGuid objectForKey:@"instanceGuid"];
            return;
        }
    }
    
    int statusCode;
    
    NSData *data;
    
    if(self.deviceToken == nil) {
        data = [self requestPath:@"authenticate" withMethod:@"GET" withParams:[NSDictionary dictionary] returningStatusCode:&statusCode returningError:error];
    } else {
        data = [self requestPath:@"authenticate" withMethod:@"GET" withParams:[NSDictionary dictionaryWithObjectsAndKeys:self.deviceToken, @"deviceToken", @"ios", @"deviceType", nil] returningStatusCode:&statusCode returningError:error];
    }
    
    if(*error != nil) {
        return;
    }
    
    if(data == nil || (statusCode != 200 && statusCode != 500)) {
        NSDictionary *roleAndInstanceGuid = [self.mobeelizer.internalDatabase getRoleAndInstanceGuidForInstance:self.instance andUser:self.user andPassword:self.password];
        
        if (roleAndInstanceGuid == nil) {
            MobeelizerLog(@"Login failure. Connection failure with status %d.", statusCode);
            self.instance = nil;
            self.user = nil;
            self.password = nil;
            MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Login failure. Connection failure with status %d.", statusCode);
        } else {
            MobeelizerLog(@"Login with role '%@' from database successful.", self.role);
            self.role = [roleAndInstanceGuid objectForKey:@"role"];
            self.group = [[self.role componentsSeparatedByString:@"-"] objectAtIndex:0];
            self.instanceGuid = [roleAndInstanceGuid objectForKey:@"instanceGuid"];
            return;
        }
    }
    
    NSError* jsonError = nil;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    
    if(jsonError != nil) {
        MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_OTHER, @"JSON parser has failed: %@ for data: %@", [jsonError localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    }
    
    if(statusCode == 500) {
        [self.mobeelizer.internalDatabase clearRoleAndInstanceGuidForInstance:self.instance andUser:self.user];
        
        self.instance = nil;
        self.user = nil;
        self.password = nil;
        
        MobeelizerOperationJsonError(json);
    }
    
    self.role = [json objectForKey:@"role"];
    self.group = [[self.role componentsSeparatedByString:@"-"] objectAtIndex:0];
    self.instanceGuid = [json objectForKey:@"instanceGuid"];
    self.initialSyncRequired = [self.mobeelizer.internalDatabase isInitialSyncRequiredForInstance:self.instance andInstanceGuid:self.instanceGuid andUser:self.user];
        
    [self.mobeelizer.internalDatabase setRole:self.role andInstanceGuid:self.instanceGuid forInstance:self.instance andUser:self.user andPassword:self.password];
        
    MobeelizerLog(@"Login with role '%@', instanceGuid '%@' and initial sync required %@", self.role, self.instanceGuid, self.initialSyncRequired ? @"TRUE" : @"FALSE");
}

- (NSString *)requestSyncAllReturningError:(MobeelizerOperationError **)error {
    MobeelizerLog(@"Request sync all");
    
    int statusCode;
    
    NSData *data = [self requestPath:@"synchronizeAll" withMethod:@"POST" withParams:[NSDictionary dictionary] returningStatusCode:&statusCode returningError:error];
    
    if(*error != nil) {
        return nil;
    }
    
    if(data == nil || (statusCode != 200 && statusCode != 500)) {
        MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Request sync all failure. Connection failure with status %d.", statusCode);
    }
    
    if(statusCode == 500) {
        NSError* jsonError = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        if(jsonError != nil) {
            MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_OTHER, @"JSON parser has failed: %@ for data: %@", [jsonError localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        } else {
            MobeelizerOperationJsonErrorWithReturn(nil, json);
        }
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)requestSyncDiff:(NSString *)dataPath returningError:(MobeelizerOperationError **)error {
    MobeelizerLog(@"Request Sync Diff");
    
    int statusCode;
    
    NSData *data = [self requestPath:@"synchronize" withFile:[NSData dataWithContentsOfFile:dataPath] returningStatusCode:&statusCode returningError:error];
    
    if(*error != nil) {
        return nil;
    }
    
    if(data == nil || (statusCode != 200 && statusCode != 500)) {
        MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Request sync diff failure. Connection failure with status %d.", statusCode);
    }

    if(statusCode == 500) {
        NSError* jsonError = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        if(jsonError != nil) {
            MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_OTHER, @"JSON parser has failed: %@ for data: %@", [jsonError localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        } else {
            MobeelizerOperationJsonErrorWithReturn(nil, json);
        }
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)waitUntilSyncRequestComplete:(NSString *)ticket returningError:(MobeelizerOperationError **)error {
    for(int i = 0; i < 100; i++) {
        MobeelizerLog(@"Check task status: %@", ticket);
        
        int statusCode;
        
        NSData *data = [self requestPath:@"checkStatus" withMethod:@"GET" withParams:[NSDictionary dictionaryWithObject:ticket forKey:@"ticket"]  returningStatusCode:&statusCode returningError:error];
        
        if(*error != nil) {
            return;
        }
        
        if(data == nil || (statusCode != 200 && statusCode != 500)) {
            MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Check task status failure. Connection failure with status %d.", statusCode);
        }
        
        NSError* jsonError = nil;
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        if(jsonError != nil) {
            MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_OTHER, @"JSON parser has failed: %@ for data: %@", [jsonError localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        }
        
        if(statusCode == 500) {
            MobeelizerOperationJsonError(json);
        }
        
        NSString *taskStatus = [json objectForKey:@"status"];
        
        MobeelizerLog(@"Check task status: %@ = %@", ticket, taskStatus);
            
        if([taskStatus isEqualToString:@"REJECTED"]) {
            MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_SYNC_REJECTED, @"Synchronization rejected with result %@ and message: %@", [json objectForKey:@"result"], [json objectForKey:@"message"]);
        } else if([taskStatus isEqualToString:@"FINISHED"]) {
            return;
        }
        
        [NSThread sleepForTimeInterval:pow(6.0, log(i+1.0))];
    }
    
    return MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_SYNC_REJECTED, @"Synchronization rejected with result: timeout.");
}

- (NSString *)getSyncData:(NSString *)ticket returningError:(MobeelizerOperationError **)error {
    MobeelizerLog(@"Get sync data: %@", ticket);
    
    int statusCode;
    
    NSData *data = [self requestPath:@"data" withMethod:@"GET" withParams:[NSDictionary dictionaryWithObject:ticket forKey:@"ticket"] returningStatusCode:&statusCode returningError:error];
    
    if(*error != nil) {
        return nil;
    }
    
    if(data == nil || (statusCode != 200 && statusCode != 500)) {
        MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Get sync data failure. Connection failure with status %d.", statusCode);
    }
    
    if(statusCode == 500) {
        NSError* jsonError = nil;        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        if(jsonError != nil) {
            MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_OTHER, @"JSON parser has failed: %@ for data: %@", [jsonError localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        } else {
            MobeelizerOperationJsonErrorWithReturn(nil, json);
        }
    }
    
    NSString *dataFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dat", ticket]];

    if([data writeToFile:dataFilePath atomically:TRUE]) {
        return dataFilePath;
    } else {
        MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_OTHER, @"Get sync data failure. Cannot save file.");
    }    
}

- (void)confirmTask:(NSString *)ticket returningError:(MobeelizerOperationError **)error {
    MobeelizerLog(@"Confirm task: %@", ticket);
    
    int statusCode;
    
    NSData *data = [self requestPath:@"confirm" withMethod:@"POST" withParams:[NSDictionary dictionaryWithObject:ticket forKey:@"ticket"] returningStatusCode:&statusCode returningError:error];
    
    if(*error != nil) {
        return;
    }
    
    if(statusCode == 200) {
        return;
    }
    
    if(data == nil || statusCode != 500) {
        MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Confirm task failure. Connection failure with status %d.", statusCode);
    }

    NSError* jsonError = nil;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    
    if(jsonError != nil) {
        MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_OTHER, @"JSON parser has failed: %@ for data: %@", [jsonError localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    } else {
        MobeelizerOperationJsonError(json);
    }
}

- (void)registerDeviceToken:(NSString *)token returningError:(MobeelizerOperationError **)error {
    MobeelizerLog(@"Register push token: %@", token);
    
    self.deviceToken = token;
    
    if([Mobeelizer isLoggedIn]) {    
        int statusCode;
        
        NSData *data = [self requestPath:@"registerPushToken" withMethod:@"POST" withParams:[NSDictionary dictionaryWithObjectsAndKeys:self.deviceToken, @"deviceToken", @"ios", @"deviceType", nil] returningStatusCode:&statusCode returningError:error];

        if(*error != nil) {
            return;
        }
        
        if(statusCode == 200) {
            self.deviceToken = nil;
            return;
        }
        
        if(data == nil || statusCode != 500) {
            MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Register push token failure. Connection failure with status %d.", statusCode);
        }
        
        NSError* jsonError = nil;
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        if(jsonError != nil) {
            MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_OTHER, @"JSON parser has failed: %@ for data: %@", [jsonError localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        } else {
            MobeelizerOperationJsonError(json);
        }
    } else {
        MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_AUTHENTICATION_FAILURE, @"Register push token failure. User is not logged in.");
    }
}

- (void)unregisterForRemoteNotificationsReturningError:(MobeelizerOperationError **)error {
    MobeelizerLog(@"Unregister push token: %@", self.deviceToken);
    
    if(self.deviceToken == nil) {
        return;
    }
    
    if([Mobeelizer isLoggedIn]) {    
        int statusCode;
        
        NSData *data = [self requestPath:@"unregisterPushToken" withMethod:@"POST" withParams:[NSDictionary dictionaryWithObjectsAndKeys:self.deviceToken, @"deviceToken", @"ios", @"deviceType", nil] returningStatusCode:&statusCode returningError:error];
        
        if(*error != nil) {
            return;
        }
        
        if(statusCode == 200) {
            self.deviceToken = nil;
            return;
        }
        
        if(data == nil || statusCode != 500) {
            MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Unregister push token failure. Connection failure with status %d.", statusCode);
        }
        
        NSError* jsonError = nil;
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        if(jsonError != nil) {
            MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_OTHER, @"JSON parser has failed: %@ for data: %@", [jsonError localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        } else {
            MobeelizerOperationJsonError(json);
        }
    } else {
        MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_AUTHENTICATION_FAILURE, @"Unregister push token failure. User is not logged in.");
    }
}

- (void)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users toGroup:(NSString *)group onDevice:(NSString *)device returningError:(MobeelizerOperationError **)error {
    MobeelizerLog(@"Send remote notification: %@", notification);
    
    int statusCode;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:(users == nil ? [NSNull null] : users) forKey:@"users"];
    [params setObject:(group == nil ? [NSNull null] : group) forKey:@"group"];
    [params setObject:(device == nil ? [NSNull null] : device) forKey:@"device"];
    [params setObject:notification forKey:@"notification"];
    
    NSError* jsonError = nil;
    
    NSData *request = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&jsonError];
    
    if(jsonError != nil) {
        MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_OTHER, @"JSON creation has failed: %@ for dictionary: %@", [jsonError localizedDescription], params);
    }
    
    NSData *data = [self requestPath:@"push" withJson:request returningStatusCode:&statusCode returningError:error];
    
    if(*error != nil) {
        return;
    }
    
    if(statusCode == 200) {
        return;
    }
    
    if(data == nil || statusCode != 500) {
        MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Unregister push token failure. Connection failure with status %d.", statusCode);
    }
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    
    if(jsonError != nil) {
        MobeelizerOperationError(MOBEELIZER_OPERATION_CODE_OTHER, @"JSON parser has failed: %@ for data: %@", [jsonError localizedDescription], [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    } else {
        MobeelizerOperationJsonError(json);
    }
}

- (NSData *)requestPath:(NSString *)path withFile:(NSData *)file returningStatusCode:(int *)statusCode returningError:(MobeelizerOperationError **)error {    
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
    [postbody appendData:[@"content-type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [postbody appendData:[NSData dataWithData:file]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSASCIIStringEncoding]];
    
    [request setHTTPBody:postbody];
    
    [request setHTTPMethod:@"POST"];
    
    NSError* connectionError = nil;
    NSURLResponse* response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    *statusCode = [(NSHTTPURLResponse *)response statusCode]; 
    
    if(connectionError != nil) {
        MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Request has failed: %@", [connectionError localizedDescription]);
    }
    
    return data;
}

- (NSData *)requestPath:(NSString *)path withJson:(NSData *)json returningStatusCode:(int *)statusCode returningError:(MobeelizerOperationError **)error {
    NSURL *url = [self.mobeelizer.url URLByAppendingPathComponent:path];
    
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
    [request setHTTPBody:json];
    
    [request setHTTPMethod:@"POST"];
    
    NSError* connectionError = nil;
    NSURLResponse* response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    *statusCode = [(NSHTTPURLResponse *)response statusCode]; 
    
    if(connectionError != nil) {
        MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Request has failed: %@", [connectionError localizedDescription]);
    }
    
    return data;
}

- (NSData *)requestPath:(NSString *)path withMethod:(NSString *)method withParams:(NSDictionary *)params returningStatusCode:(int *)statusCode returningError:(MobeelizerOperationError **)error {
    NSURL *url = [self.mobeelizer.url URLByAppendingPathComponent:path];
    
    if([params count] > 0) {
        NSMutableArray *parts = [NSMutableArray array];
        
        for (NSString *key in params.keyEnumerator) {
            NSString *value = [params objectForKey: key];
            [parts addObject:[NSString stringWithFormat: @"%@=%@", [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding], [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
        }
        
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", url, [parts componentsJoinedByString: @"&"]]];
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
    
    NSError* connectionError = nil;
    NSURLResponse* response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    *statusCode = [(NSHTTPURLResponse *)response statusCode]; 
    
    if(connectionError != nil) {
        MobeelizerOperationErrorWithReturn(nil, MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE, @"Request has failed: %@", [connectionError localizedDescription]);
    }
    
    return data;
}

@end

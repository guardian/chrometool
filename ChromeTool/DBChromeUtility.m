//
//  DBChromeUtility.m
//  ChromeTool
//
//  Created by David Blishen on 27/04/2015.
//  Copyright (c) 2015 David Blishen. All rights reserved.
//

#import "DBChromeUtility.h"

@implementation DBChromeUtility


-(int)allowDomain:(NSString *)allowedDomain forPath:(NSString *)preferencePath {
    
    SBJsonParser *jsonParser;
    NSDictionary *chromeDict;
    
    NSString *preferenceBackupPath = [NSString stringWithFormat:@"%@.backup", preferencePath];
    
    if (allowedDomain==nil){
        NSLog(@"No new domain to allow has been provided");
        return 1;
    } else if (preferencePath==nil) {
        NSLog(@"No preference file path supplied");
        return 1;
    }
    
    // Check the file exists
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:preferencePath]){
        NSLog(@"No file found at path: %@", preferencePath);
        return 1;
    }
    
    NSError *fileReadError;
    NSString *preferenceFile = [NSString stringWithContentsOfFile:preferencePath encoding:NSUTF8StringEncoding error:&fileReadError];
    
    // Using SBJSon to parse the JSON from thefile
    
    jsonParser = [[SBJsonParser alloc] init];
    chromeDict = [jsonParser objectWithString:preferenceFile];
    [jsonParser release];
    
    // Test the format of the file, at least as far as we care. We may add further tests later.
    BOOL validFile = YES;
    
    // Is there a profile section?
    if ([[chromeDict objectForKey:@"profile"] objectForKey:@"content_settings"]==nil){
        validFile = NO;
    };
    
    if (validFile==NO){
        NSLog(@"We don't consider this a valid Chrome Preferences JSON file: %@", preferencePath);
        return 1;
    }
    
    // Backup the original file
    [fm removeItemAtPath:preferenceBackupPath error:nil];
    [fm copyItemAtPath:preferencePath toPath:preferenceBackupPath error:nil];
    
    
    // Get the object to update
    NSMutableDictionary *patternDict = [[[chromeDict objectForKey:@"profile"] objectForKey:@"content_settings"] objectForKey:@"pattern_pairs"];
    
    // Manufacture the dict to insert
    NSString *keyName = [NSString stringWithFormat:@"%@,*", allowedDomain];
    NSDictionary *cookieDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"cookies"];
    NSDictionary *insertionDict = [NSDictionary dictionaryWithObject:cookieDict forKey:keyName];
    
    // Insert the dictionary into the pattern pairs
    [patternDict addEntriesFromDictionary:insertionDict];
    
    // Write the updated file replacing the original. We've made a backup so we should be good.
    NSLog(@"Allowing cookies for: %@", allowedDomain);
    NSLog(@"File path: %@", preferencePath);
    [[chromeDict JSONRepresentation] writeToFile:preferencePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    return 0;
}

@end





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
    BOOL updateFile = NO;
    
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
    
    // Backup the original file
    [fm removeItemAtPath:preferenceBackupPath error:nil];
    [fm copyItemAtPath:preferencePath toPath:preferenceBackupPath error:nil];
    
    
    // We are going to check for a couple of variations to cover different chrome versions
    
    
    NSMutableDictionary *patternDict = [[[chromeDict objectForKey:@"profile"]
                                         objectForKey:@"content_settings"]
                                        objectForKey:@"pattern_pairs"];
    
    if (patternDict!=nil){
        
        NSLog(@"Located pattern_pairs in: %@", preferencePath);
        NSLog(@"Allowing cookies for: %@", allowedDomain);

        // Manufacture the dict to insert
        NSString *keyName = [NSString stringWithFormat:@"%@,*", allowedDomain];
        NSDictionary *exceptionDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"cookies"];
        NSDictionary *insertionDict = [NSDictionary dictionaryWithObject:exceptionDict forKey:keyName];
        
        // Insert the dictionary into the pattern pairs
        [patternDict addEntriesFromDictionary:insertionDict];
        
        // Trigger a file write later
        updateFile = YES;
    
    } else {

        NSLog(@"No pattern_pairs to update in: %@", preferencePath);
    
    };
    
    NSMutableDictionary *cookieDict = [[[[chromeDict objectForKey:@"profile"]
                                         objectForKey:@"content_settings"]
                                        objectForKey:@"exceptions"]
                                       objectForKey:@"cookies"];
 
    if (cookieDict!=nil){
        
        NSLog(@"Updating exceptions/cookies");
        NSLog(@"Allowing cookies for: %@", allowedDomain);

        // Manufacture the dict to insert
        NSString *keyName = [NSString stringWithFormat:@"%@,*", allowedDomain];
        NSDictionary *exceptionDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"setting"];
        NSDictionary *insertionDict = [NSDictionary dictionaryWithObject:exceptionDict forKey:keyName];
        
        // Insert the dictionary into the pattern pairs
        [cookieDict addEntriesFromDictionary:insertionDict];
        
        // Trigger a file write later
        updateFile = YES;
        
    } else {
        
        NSLog(@"No exceptions/cookies to update in: %@", preferencePath);
        
    };

    
    // Write the updated file replacing the original. We've made a backup so we should be good.
    
    if (updateFile){
        NSLog(@"Updating file path: %@", preferencePath);
        [[chromeDict JSONRepresentation] writeToFile:preferencePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }

    return 0;
}

@end

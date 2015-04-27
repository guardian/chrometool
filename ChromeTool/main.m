//
//  main.m
//  ChromeTool
//
//  Created by David Blishen on 09/03/2015.
//  Copyright (c) 2015 David Blishen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include "SBJson.h"
#include "DBChromeUtility.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        //SBJsonParser *jsonParser;
        //NSDictionary	*chromeDict;

        //Grab the arguements from the command line
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        
        NSString *allowedDomain = [args stringForKey:@"allow"];
        NSString *preferencePath = [args stringForKey:@"path"];
        
        // We've got the args for allowing domains in the cookies exceptions
        
        if (allowedDomain && preferencePath) {
            DBChromeUtility *chromeUtil = [[DBChromeUtility alloc] init];
            [chromeUtil allowDomain:allowedDomain forPath:preferencePath];
        };
        

    return 0;
    
    }
}


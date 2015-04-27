//
//  DBChromeUtility.h
//  ChromeTool
//
//  Created by David Blishen on 27/04/2015.
//  Copyright (c) 2015 David Blishen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include "SBJson.h"

@interface DBChromeUtility : NSObject {
    
}


-(int)allowDomain:(NSString *)allowedDomain forPath:(NSString *)preferencePath;

@end




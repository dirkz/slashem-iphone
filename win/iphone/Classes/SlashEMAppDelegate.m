//
//  SlashEMAppDelegate.m
//  SlashEM
//
//  Created by Dirk Zimmermann on 3/16/10.
//  Copyright Dirk Zimmermann 2010. All rights reserved.
//

#import "SlashEMAppDelegate.h"

@implementation SlashEMAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end

//
//  SlashEMAppDelegate.m
//  SlashEM
//
//  Created by Dirk Zimmermann on 3/16/10.
//  Copyright Dirk Zimmermann 2010. All rights reserved.
//

/*
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation, version 2
 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "SlashEMAppDelegate.h"
#import "MainViewController.h"
#import "winiphone.h"
#import "TileSet.h"

#include <sys/stat.h>

extern int unixmain(int argc, char **argv);

@implementation SlashEMAppDelegate

@synthesize window;
@synthesize mainViewController;

- (BOOL)isGameWorthSaving {
	return !program_state.gameover && program_state.something_worth_saving;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[window addSubview:mainViewController.view];
    [window makeKeyAndVisible];
	
	netHackThread = [[NSThread alloc] initWithTarget:self selector:@selector(netHackMainLoop:) object:nil];
	[netHackThread start];
}

- (void)cleanUpLocks {
	// clean up locks / levelfiles
	delete_levelfile(ledger_no(&u.uz));
	delete_levelfile(0);
}

- (void)saveAndQuitGame {
	if (self.isGameWorthSaving) {
		dosave0();
	} else {
		[self cleanUpLocks];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveAndQuitGame];
}

- (void) netHackMainLoop:(id)arg {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	char *argv[] = {
		"SlashEM",
	};
	int argc = sizeof(argv)/sizeof(char *);
	
	// create necessary directories
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *baseDirectory = [paths objectAtIndex:0];
	DLog(@"baseDir %@", baseDirectory);
	setenv("NETHACKDIR", [baseDirectory cStringUsingEncoding:NSASCIIStringEncoding], 1);
	//setenv("SHOPTYPE", "G", 1); // force general stores on every level in wizard mode
	NSString *saveDirectory = [baseDirectory stringByAppendingPathComponent:@"save"];
	mkdir([saveDirectory cStringUsingEncoding:NSASCIIStringEncoding], 0777);
	
	// show directory (for debugging)
#if 0	
	for (NSString *filename in [[NSFileManager defaultManager] enumeratorAtPath:baseDirectory]) {
		DLog(@"%@", filename);
	}
#endif
	
	// set plname (very important for save files and getlock)
	[[NSUserName() capitalizedString] getCString:plname maxLength:PL_NSIZ encoding:NSASCIIStringEncoding];
	
	// call Slash'EM
	unixmain(argc, argv);
	
	// clean up thread pool
	[pool drain];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end

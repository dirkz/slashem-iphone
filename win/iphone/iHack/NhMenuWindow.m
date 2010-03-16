//
//  NhMenuWindow.m
//  SlashEM
//
//  Created by dirk on 1/4/10.
//  Copyright 2010 Dirk Zimmermann. All rights reserved.
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

#import "NhMenuWindow.h"
#import "NhItemGroup.h"

@implementation NhMenuWindow

@synthesize how;
@synthesize itemGroups;
@synthesize selected;
@synthesize prompt;

- (id) initWithType:(int)t {
	if (self = [super initWithType:t]) {
	}
	return self;
}

- (void) addItemGroup:(NhItemGroup *)g {
	[itemGroups addObject:g];
	currentItemGroup = g;
}

- (NhItemGroup *) currentItemGroup {
	if (!currentItemGroup) {
		NhItemGroup *g = [[NhItemGroup alloc] initWithTitle:@"All" dummy:YES];
		[itemGroups addObject:g];
		currentItemGroup = g;
		[g release];
	}
	return currentItemGroup;
}

- (NhItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
	NhItemGroup *g = [itemGroups objectAtIndex:[indexPath section]];
	NhItem *i = [g.items objectAtIndex:[indexPath row]];
	return i;
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
	NhItemGroup *g = [itemGroups objectAtIndex:[indexPath section]];
	[g removeItemAtIndex:[indexPath row]];
}

- (void)startMenu {
	[itemGroups release];
	[selected release];
	currentItemGroup = nil;
	itemGroups = [[NSMutableArray alloc] init];
	selected = [[NSMutableArray alloc] init];
}

- (void) dealloc {
	[itemGroups release];
	[selected release];
	[super dealloc];
}

@end

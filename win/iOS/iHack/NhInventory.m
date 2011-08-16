//
//  NhInventory.m
//  NetHack
//
//  Created by dirk on 2/8/10.
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

#import "NhInventory.h"
#import "NhObject.h"
#import "NhGoldObject.h"

@implementation NhInventory

@synthesize objectClasses;
@synthesize numberOfPutOnItems;
@synthesize numberOfWornArmor;

+ (id)inventory {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	if (self = [super init]) {
		objectClasses = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSMutableArray *)arrayForClass:(char)class {
	if (!classArray[class]) {
		classArray[class] = [NSMutableArray array];
	}
	return classArray[class];
}

- (void)update {
	[objectClasses removeAllObjects];
	numberOfPutOnItems = 0;
	numberOfWornArmor = 0;
	memset(classArray, (int) nil, sizeof(classArray));
	for (struct obj *otmp = invent; otmp; otmp = otmp->nobj) {
		NSMutableArray *array = [self arrayForClass:otmp->oclass];
		[array addObject:[NhObject objectWithObject:otmp]];
		if ((otmp->oclass == RING_CLASS || otmp->oclass == AMULET_CLASS || otmp->oclass == TOOL_CLASS) &&
			(otmp->owornmask & W_RING || otmp->owornmask & W_AMUL || otmp->owornmask & W_TOOL)) {
			numberOfPutOnItems++;
		} else if (otmp->oclass == ARMOR_CLASS &&
				   otmp->owornmask & (W_ARM | W_ARMC | W_ARMH | W_ARMS | W_ARMG | W_ARMF | W_ARMU)) {
			numberOfWornArmor++;
		}
	}
	char *invlet = flags.inv_order;
	while (*invlet) {
		NSArray *items = classArray[*invlet++];
		if (items) {
			[objectClasses addObject:items];
		}
	}
	
	// Hands / Gold
	NSArray *specialObjects = nil;
	if (u.ugold > 0) {
		specialObjects = [NSArray arrayWithObjects:[NhGoldObject object],
						  [NhObject objectWithTitle:@"Hands" inventoryLetter:'-'], nil];
	} else {
		specialObjects = [NSArray arrayWithObject:[NhObject objectWithTitle:@"Hands" inventoryLetter:'-']];
	}
	[objectClasses addObject:specialObjects];
}

- (NhObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [[objectClasses objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
}

- (BOOL)containsObjectClass:(char)oclass {
	return classArray[oclass] != nil;
}

- (void)dealloc {
	[objectClasses release];
	[super dealloc];
}

@end

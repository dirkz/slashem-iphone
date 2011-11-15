//
//  NhObject.m
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

#import "NhObject.h"
#import "NSString+NetHack.h"

@implementation NhObject

@synthesize object;
@synthesize title;
@synthesize detail;
@synthesize inventoryLetter;
@synthesize glyph;
@synthesize amount;

+ (id)objectWithTitle:(NSString *)t inventoryLetter:(char)invLet {
	return [[[self alloc] initWithTitle:t inventoryLetter:invLet] autorelease];
}

+ (id)objectWithObject:(struct obj *)obj {
	return [[[self alloc] initWithObject:obj] autorelease];
}

- (id)initWithTitle:(NSString *)t inventoryLetter:(char)invLet {
	if (self = [super init]) {
		title = [t copy];
		inventoryLetter = invLet;
		amount = 1;
	}
	return self;
}

- (id)initWithObject:(struct obj *)obj {
	NSString *tmp = [NSString stringWithFormat:@"%s", doname(obj)];
	NSArray *lines = [tmp splitNetHackDetails];
	if (self = [self initWithTitle:[lines objectAtIndex:0] inventoryLetter:obj->invlet]) {
		object = obj;
		inventoryLetter = object->invlet;
		if (lines.count == 2) {
			detail = [[lines objectAtIndex:1] copy];
		}
		glyph = obj_to_glyph(obj);
		amount = obj->quan;
	}
	return self;
}

- (void)dealloc {
	[title release];
	[detail release];
	[super dealloc];
}

@end

//
//  NhItem.m
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

#import "NhItem.h"
#import "NSString+NetHack.h"

@implementation NhItem

@synthesize identifier;
@synthesize selected;
@synthesize maxAmount;

- (id)initWithTitle:(NSString *)t identifier:(ANY_P)ident inventoryLetter:(char)invLet glyph:(int)g selected:(BOOL)s {
	NSArray *lines = [t splitNetHackDetails];
	if (self = [super initWithTitle:[lines objectAtIndex:0] inventoryLetter:invLet]) {
		if (lines.count == 2) {
			detail = [[lines objectAtIndex:1] copy];
		} else {
			title = [t copy];
		}
		identifier = ident;
		glyph = g;
		selected = s;
		amount = -1; // all is default
		maxAmount = [title parseNetHackAmount];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

@end

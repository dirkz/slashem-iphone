//
//  Event.m
//  SlashEM
//
//  Created by dirk on 12/31/09.
//  Copyright 2009 Dirk Zimmermann. All rights reserved.
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

#import "NhEvent.h"

#include "hack.h"

@implementation NhEvent

@synthesize key, mod, x, y;

+ (id) eventWithKey:(int)k mod:(int)m x:(int)i y:(int)j {
	return [[[self alloc] initWithKey:k mod:m x:i y:j] autorelease];
}

+ (id) eventWithX:(int)i y:(int)j {
	return [[[self alloc] initWithX:i y:j] autorelease];
}

+ (id) eventWithKey:(int)k {
	return [[[self alloc] initWithKey:k] autorelease];
}

- (id) initWithKey:(int)k mod:(int)m x:(int)i y:(int)j {
	if (self = [super init]) {
		key = k;
		mod = m;
		x = i;
		y = j;
	}
	return self;
}

- (id) initWithX:(int)i y:(int)j {
	return [self initWithKey:0 mod:CLICK_1 x:i y:j];
}

- (id) initWithKey:(int)k {
	return [self initWithKey:k mod:-1 x:-1 y:-1];
}

- (BOOL) isKeyEvent {
	return key != 0;
}

- (void) dealloc {
	//DLog(@"%@ dealloc", self);
	[super dealloc];
}

@end

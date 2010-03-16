//
//  NhOption.m
//  NetHack
//
//  Created by Dirk Zimmermann on 2/19/10.
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

#import "NhOption.h"

#include "hack.h"

@implementation NhOption

@synthesize title, index;

+ (id)optionWithTitle:(const char *)t index:(int)i type:(e_option_type)typ {
	return [[[self alloc] initWithTitle:t index:i type:typ] autorelease];
}

- (id)initWithTitle:(const char *)t index:(int)i type:(e_option_type)typ {
	if (self = [super init]) {
		title = [[NSString alloc] initWithCString:t encoding:NSASCIIStringEncoding];
		index = i;
		type = typ;
	}
	return self;
}

- (BOOL)simple {
	return type == simple;
}

- (BOOL)simpleValue {
	return *boolopt[index].addr;
}

- (void)setSimpleValue:(BOOL)b {
	*boolopt[index].addr = b;
}

- (void)dealloc {
	[title release];
	[super dealloc];
}

@end

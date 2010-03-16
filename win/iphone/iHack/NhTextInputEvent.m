//
//  NhTextInputEvent.m
//  SlashEM
//
//  Created by dirk on 1/13/10.
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

#import "NhTextInputEvent.h"

@implementation NhTextInputEvent

@synthesize text;

+ (id)eventWithText:(NSString *)t {
	return [[[self alloc] initWithText:t] autorelease];
}

- (id)initWithText:(NSString *)t {
	if (self = [super initWithKey:-1]) {
		text = [t copy];
	}
	return self;
}

- (void)dealloc {
	[text release];
	[super dealloc];
}

@end

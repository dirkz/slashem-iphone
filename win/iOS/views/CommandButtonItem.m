//
//  CommandButtonItem.m
//  NetHack
//
//  Created by dirk on 2/4/10.
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

#import "CommandButtonItem.h"

@implementation CommandButtonItem

+ (id)buttonWithAction:(Action *)action {
	return [[[self alloc] initWithAction:action] autorelease];
}

- (id)initWithAction:(Action *)action {
	if (self = [super initWithTitle:action.title style:UIBarButtonItemStyleBordered target:self action:@selector(invoke:)]) {
		myAction = [action retain];
	}
	return self;
}

- (void)invoke:(id)sender {
	[myAction invoke:sender];
}

- (void)dealloc {
	[myAction release];
	[super dealloc];
}

@end

//
//  TouchInfo.m
//  SlashEM
//
//  Created by dirk on 8/6/09.
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

#import "ZTouchInfo.h"

@implementation ZTouchInfo

@synthesize pinched, moved, initialLocation, currentLocation, doubleTap;

- (id) initWithTouch:(UITouch *)t {
	if (self = [super init]) {
		self.initialLocation = self.currentLocation = [t locationInView:t.view];
	}
	return self;
}

@end

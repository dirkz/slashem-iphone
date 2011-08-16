//
//  NSString+NetHack.m
//  iNetHack
//
//  Created by dirk on 8/22/09.
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

#import "NSString+NetHack.h"
#import "NSString+Z.h"

@implementation NSString (NetHack)

- (NSArray *) splitNetHackDetails {
	NSArray *strings = [NSArray arrayWithObjects:self, nil];
	NSString *ws = [self substringBetweenDelimiters:@"()"];
	if (ws && ws.length > 1) {
		NSRange r = [self rangeOfString:ws];
		if (r.location > 3) {
			// there should be at least one char and a space before '('
			strings = [NSArray arrayWithObjects:[self substringToIndex:r.location-2], ws, nil];
		}
	}
	return strings;
}

- (int) parseNetHackAmount {
	int amount = -1;
	NSRange r = [self rangeOfString:@" "];
	if (r.location != NSNotFound) {
		NSString *amountString = [self substringToIndex:r.location];
		if (amountString.length > 0) {
			amount = [amountString intValue];
			if (amount == 0) {
				amount = -1;
			}
		}
	}
	return amount;
}

@end

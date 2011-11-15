//
//  NhMapWindow.m
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

#import "NhMapWindow.h"

#include "hack.h"

@implementation NhMapWindow

@synthesize glyphs;

- (id) initWithType:(int)t {
	if (self = [super initWithType:t]) {
		size_t numBytes = COLNO * ROWNO * sizeof(int);
		glyphs = malloc(numBytes);
		memset(glyphs, kNoGlyph, numBytes);
	}
	return self;
}

- (void) printGlyph:(int)glyph atX:(XCHAR_P)x y:(XCHAR_P)y {
	glyphs[y * COLNO + x] = glyph;
}

- (int) glyphAtX:(XCHAR_P)x y:(XCHAR_P)y {
	return glyphAt(glyphs, x, y);
}

- (void) clear {
	[super clear];
	size_t numBytes = COLNO * ROWNO * sizeof(int);
	memset(glyphs, kNoGlyph, numBytes);
}

- (void) dealloc {
	free(glyphs);
	[super dealloc];
}

@end

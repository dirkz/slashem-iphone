//
//  TileSet.m
//  SlashEM
//
//  Created by dirk on 1/17/10.
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

#import "TileSet.h"
#include "hack.h"

static TileSet *s_instance = nil;

@implementation TileSet

@synthesize title;

+ (TileSet *)instance {
	return s_instance;
}

+ (void)setInstance:(TileSet *)ts {
	[s_instance release];
	s_instance = ts;
}

- (id)initWithImage:(UIImage *)img tileSize:(CGSize)ts title:(NSString *)t {
	if (self = [super init]) {
		image = [img retain];
		tileSize = ts;
		rows = image.size.height / tileSize.height;
		columns = image.size.width / tileSize.width;
		numberOfCachedImages = rows*columns;
		cachedImages = calloc(numberOfCachedImages, sizeof(CGImageRef));
		memset(cachedImages, 0, numberOfCachedImages*sizeof(CGImageRef));
		title = [t copy];
	}
	return self;
}

- (CGImageRef)imageForGlyph:(int)glyph {
	int tile = glyph2tile[glyph];
	return [self imageForTile:tile];
}

- (CGImageRef)imageForTile:(int)tile {
	if (!cachedImages[tile]) {
		switch (tile) {
			case PM_BULL:
				NSLog(@"PM_BULL %d", tile);
				break;
			default:
				break;
		}
		int row = tile/columns;
		int col = row ? tile % columns : tile;
		CGRect r = { col * tileSize.width, row * tileSize.height };
		r.size = tileSize;
		cachedImages[tile] = CGImageCreateWithImageInRect(image.CGImage, r);
	}
	return cachedImages[tile];
}

- (void)dealloc {
	for (int i = 0; i < numberOfCachedImages; ++i) {
		if (cachedImages[i]) {
			CGImageRelease(cachedImages[i]);
		}
	}
	free(cachedImages);
	[image release];
	[title release];
	[super dealloc];
}

@end

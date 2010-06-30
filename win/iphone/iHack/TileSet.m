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
#import "AsciiTileSet.h"
#import "NSString+Z.h"
#import "winiphone.h" // kNetHackTileSet

#include "hack.h"

static TileSet *s_instance = nil;
static const CGSize defaultTileSize = {32.0f, 32.0f};

@implementation TileSet

@synthesize title;
@synthesize supportsTransparency;

+ (TileSet *)instance {
	if (!s_instance) {
		NSString *filename = [[NSUserDefaults standardUserDefaults] objectForKey:kNetHackTileSet];
		TileSet *tileSet = [TileSet tileSetFromTitleOrFilename:filename];
		s_instance = tileSet;
	}
	return s_instance;
}

+ (void)setInstance:(TileSet *)ts {
	[s_instance release];
	s_instance = ts;
}

+ (NSString *)titleForTilesetDictionary:(NSDictionary *)dict {
	NSString *title = [dict objectForKey:@"title"];
	if (!title) {
		title = [dict objectForKey:@"filename"];
	}
	return title;
}

+ (TileSet *)tileSetFromDictionary:(NSDictionary *)dict {
	NSString *filename = [dict objectForKey:@"filename"];
	if (!filename) {
		filename = [dict objectForKey:@"title"];
	}
	TileSet *tileSet = [self tileSetFromTitleOrFilename:filename];;
	return tileSet;
}

+ (TileSet *)tileSetFromTitleOrFilename:(NSString *)title {
	TileSet *tileSet = nil;
	if ([title endsWithString:@".png"]) {
		UIImage *tilesetImage = [UIImage imageNamed:title];
		tileSet = [[self alloc] initWithImage:tilesetImage tileSize:defaultTileSize title:title];
		if ([title containsString:@"absurd"]) {
			tileSet.supportsTransparency = YES;
		}
	} else {
		tileSet = [[AsciiTileSet alloc] initWithTileSize:defaultTileSize title:title];
	}
	return tileSet;
}

+ (void)dumpTiles {
	NSMutableDictionary *uniqueACIITiles = [NSMutableDictionary dictionary];
	int monsters = 0, other = 0;
	for (int glyph = 0; glyph < MAX_GLYPH; ++glyph) {
		int ochar, ocolor;
		unsigned special;
		mapglyph(glyph, &ochar, &ocolor, &special, 1, 1);
		int64_t all = ochar + ((int64_t) ocolor) << 32;
		NSNumber *entry = [NSNumber numberWithLongLong:all];
		[uniqueACIITiles setObject:entry forKey:entry];
		if (glyph_is_monster(glyph)) {
			monsters++;
		} else {
			other++;
		}
	}
	DLog(@"%d glyphs, %d monsters, %d other, %d unique ascii", MAX_GLYPH, monsters, other, uniqueACIITiles.count);
}	

//- (id)init {
//	if (self = [super init]) {
//		[TileSet dumpTiles];
//	}
//	return self;
//}

- (id)initWithImage:(UIImage *)img tileSize:(CGSize)ts title:(NSString *)t {
//	[TileSet dumpTiles];
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

- (id)initWithImage:(UIImage *)img title:(NSString *)t {
	[TileSet dumpTiles];
	return [self initWithImage:img tileSize:defaultTileSize title:t];
}

- (CGImageRef)imageForTile:(int)tile atX:(int)x y:(int)y {
	if (!cachedImages[tile]) {
		int row = tile/columns;
		int col = row ? tile % columns : tile;
		CGRect r = { col * tileSize.width, row * tileSize.height };
		r.size = tileSize;
		cachedImages[tile] = CGImageCreateWithImageInRect(image.CGImage, r);
	}
	return cachedImages[tile];
}

- (CGImageRef)imageForGlyph:(int)glyph atX:(int)x y:(int)y {
	int tile = glyph2tile[glyph];
	return [self imageForTile:tile atX:x y:y];
}

- (CGImageRef)imageForGlyph:(int)glyph {
	return [self imageForGlyph:glyph atX:0 y:0];
}

- (void)dealloc {
	for (int i = 0; i < numberOfCachedImages; ++i) {
		if (cachedImages[i]) {
			CGImageRelease(cachedImages[i]);
		}
	}
	if (cachedImages) {
		free(cachedImages);
	}
	[image release];
	[title release];
	[super dealloc];
}

@end

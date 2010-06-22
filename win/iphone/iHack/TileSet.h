//
//  TileSet.h
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

#import <Foundation/Foundation.h>

extern short glyph2tile[];

@interface TileSet : NSObject {
	
	UIImage *image;
	CGSize tileSize;
	int rows;
	int columns;
	int numberOfCachedImages;
	CGImageRef *cachedImages;
	NSString *title;
	BOOL supportsTransparency;

}

@property (nonatomic, readonly) NSString *title;

// whether tilesets supports backglyphs with transparent foreground tiles
@property (nonatomic, assign) BOOL supportsTransparency;

+ (TileSet *)instance;
+ (void)setInstance:(TileSet *)ts;
+ (NSString *)titleForTilesetDictionary:(NSDictionary *)dict;
+ (TileSet *)tileSetFromDictionary:(NSDictionary *)dict;
+ (TileSet *)tileSetFromTitleOrFilename:(NSString *)title;

- (id)initWithImage:(UIImage *)img tileSize:(CGSize)ts title:(NSString *)t;
- (id)initWithImage:(UIImage *)img title:(NSString *)t;

- (CGImageRef)imageForGlyph:(int)glyph atX:(int)x y:(int)y;
- (CGImageRef)imageForGlyph:(int)glyph;

@end

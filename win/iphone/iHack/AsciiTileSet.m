//
//  AsciiTileSet.m
//  SlashEM
//
//  Created by Dirk Zimmermann on 3/19/10.
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

#import "AsciiTileSet.h"

#import "hack.h"
#import "display.h"

@implementation AsciiTileSet

- (id)initWithTileSize:(CGSize)ts title:(NSString *)t {
	if (self = [super init]) {
		tileSize = ts;
		
		numberOfCachedImages = MAX_GLYPH;
		cachedImages = calloc(numberOfCachedImages, sizeof(CGImageRef));
		memset(cachedImages, 0, numberOfCachedImages*sizeof(CGImageRef));
		title = [t copy];

		UIColor *brightGreenColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
		UIColor *brightBlueColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
		UIColor *brightMagentaColor = [UIColor colorWithRed:0.2f green:0 blue:0.2f alpha:1];
		UIColor *brightCyanColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
		colorTable = [[NSArray alloc] initWithObjects:
					  [UIColor grayColor], // "bright black"
					  [UIColor redColor],
					  [UIColor greenColor],
					  [UIColor brownColor],
					  [UIColor blueColor],
					  [UIColor magentaColor],
					  [UIColor cyanColor],
					  [UIColor grayColor],
					  [UIColor redColor], // NO_COLOR
					  [UIColor orangeColor],
					  brightGreenColor,
					  [UIColor yellowColor],
					  brightBlueColor,
					  brightMagentaColor,
					  brightCyanColor,
					  [UIColor whiteColor],
					  nil];

		encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatinUS);
	}
	return self;
}

- (UIColor *)mapNetHackColor:(int)ocolor {
	return [colorTable objectAtIndex:ocolor];
}

- (CGImageRef)imageForGlyph:(int)glyph atX:(int)x y:(int)y {
	if (!cachedImages[glyph]) {
		UIFont *font = [UIFont boldSystemFontOfSize:28];
		int ochar, ocolor;
		unsigned special;
		mapglyph(glyph, &ochar, &ocolor, &special, x, y);
		char glyphString[] = {ochar, 0};
		NSString *s = [NSString stringWithCString:glyphString encoding:encoding];
		//DLog(@"glyph %4d, tile %4d %2d %3d %c %@", glyph, tile, ocolor, ochar, ochar, s);

		// center in rectangle
		CGSize size = [s sizeWithFont:font];
		CGPoint p = CGPointMake((tileSize.width-size.width)/2, (tileSize.height-size.height)/2);
		
		UIGraphicsBeginImageContext(tileSize);
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSetBlendMode(ctx, kCGBlendModeNormal);

		// black background, needed for display in menu
		CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
		CGRect r = CGRectZero;
		r.size = tileSize;
		CGContextFillRect(ctx, r);

		UIColor *color = [self mapNetHackColor:ocolor];
		CGContextSetFillColorWithColor(ctx, color.CGColor);
		[s drawAtPoint:p withFont:font];
		UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
		cachedImages[glyph] = CGImageRetain(img.CGImage);
		UIGraphicsEndImageContext();
	}
	return cachedImages[glyph];
}

@end

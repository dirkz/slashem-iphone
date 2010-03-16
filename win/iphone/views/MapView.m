//
//  MapView.m
//  SlashEM
//
//  Created by dirk on 1/18/10.
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

#import "MapView.h"
#import "NhMapWindow.h"
#import "TileSet.h"
#import "MainViewController.h"
#import "winipad.h"

@implementation MapView

@synthesize tileSize;

- (void)setup {
	self.multipleTouchEnabled = YES;
	tileSize = CGSizeMake(32.0f, 32.0f);
	maxTileSize = CGSizeMake(32.0f, 32.0f);
	minTileSize = CGSizeMake(8.0f, 8.0f);
	
	// load gfx
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *filename = [defaults objectForKey:kNetHackTileSet];

	UIImage *tilesetImage = [UIImage imageNamed:filename];
	TileSet *tileSet = [[TileSet alloc] initWithImage:tilesetImage tileSize:CGSizeMake(32.0f, 32.0f) title:filename];
	[TileSet setInstance:tileSet];
	NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
	petMark = CGImageRetain([UIImage imageWithContentsOfFile:[bundlePath
															  stringByAppendingPathComponent:@"petmark.png"]].CGImage);
	
	self.frame = CGRectMake(0.0f, 0.0f, tileSize.width*COLNO, tileSize.height*ROWNO);
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
										 initWithTarget:self action:@selector(handleSingleTap:)];
	[self addGestureRecognizer:singleTap];
	[singleTap release];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setup];
	}
    return self;
}

- (void)drawRect:(CGRect)rect {
	NhMapWindow *map = (NhMapWindow *) [NhWindow mapWindow];
	if (map) {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
	
		// indicate map bounds
		float boundsColor[] = { 0.4f, 0.4f, 0.4f, 1.0f };
		CGContextSetStrokeColor(ctx, boundsColor);
		CGRect boundsRect = self.bounds;
		CGContextStrokeRectWithWidth(ctx, boundsRect, 3.0f);
		
		// switch to right-handed coordinate system (quartz)
		CGContextTranslateCTM(ctx, 0.0f, self.bounds.size.height);
		CGContextScaleCTM(ctx, 1.0f, -1.0f);
		
		// since this coordinate system is right-handed, each tile starts above left
		// and draws the area below to the right, so we have to be one tile height off
		CGPoint start = CGPointMake(0.0f, self.bounds.size.height-tileSize.height);
		
		// erase background
		float backgroundColor[] = { 0.0f, 0.0f, 0.0f, 1.0f };
		CGContextSetFillColor(ctx, backgroundColor);
		CGContextFillRect(ctx, rect);

		for (int j = 0; j < ROWNO; ++j) {
			for (int i = 0; i < COLNO; ++i) {
				CGPoint p = CGPointMake(start.x+i*tileSize.width,
										start.y-j*tileSize.height);
				CGRect r = CGRectMake(p.x, p.y, tileSize.width, tileSize.height);
				if (CGRectIntersectsRect(r, rect)) {
					int ochar, ocolor;
					unsigned int special;
					int glyph = [map glyphAtX:i y:j];
					if (glyph != kNoGlyph) {
						mapglyph(glyph, &ochar, &ocolor, &special, i, j);
						CGImageRef tileImg = [[TileSet instance] imageForGlyph:glyph];
						CGContextDrawImage(ctx, r, tileImg);
						if (u.ux == i && u.uy == j) {
							// hp100 calculation from qt_win.cpp
							int hp100;
							if (u.mtimedone) {
								hp100 = u.mhmax ? u.mh*100/u.mhmax : 100;
							} else {
								hp100 = u.uhpmax ? u.uhp*100/u.uhpmax : 100;
							}
							const static float colorValue = 0.7f;
							float playerRectColor[] = {colorValue, 0, 0, 0.5f};
							if (hp100 > 75) {
								playerRectColor[0] = 0;
								playerRectColor[1] = colorValue;
							} else if (hp100 > 50) {
								playerRectColor[2] = 0;
								playerRectColor[0] = playerRectColor[1] = colorValue;
							}
							CGContextSetStrokeColor(ctx, playerRectColor);
							CGContextStrokeRect(ctx, r);
						} else if (glyph_is_pet(glyph)) {
							CGContextDrawImage(ctx, r, petMark);
						}
					}
				}
			}
		}
	}
}

- (CGRect)rectForCoord:(coord)tp {
	return CGRectMake(tp.x * tileSize.width, tp.y * tileSize.height, tileSize.width, tileSize.height);
}

#pragma mark touch handling

- (void)handleSingleTap:(UIGestureRecognizer *)sender {
	CGPoint p = [sender locationInView:self];
	int tileX = p.x/tileSize.width;
	int tileY = p.y/tileSize.height;
	[[MainViewController instance] handleMapTapTileX:tileX y:tileY forLocation:p inView:self];
}

#pragma mark misc

- (void)dealloc {
	CGImageRelease(petMark);
	[[TileSet instance] release];
    [super dealloc];
}

@end

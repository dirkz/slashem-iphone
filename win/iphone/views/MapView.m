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
#import "winiphone.h"
#import "ZTouchInfo.h"
#import "ZTouchInfoStore.h"

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
	
	touchInfoStore = [[ZTouchInfoStore alloc] init];
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
		CGPoint start = CGPointMake(clipOffset.x+panOffset.x,
									self.bounds.size.height-tileSize.height-clipOffset.y-panOffset.y);
		
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

- (void)clipAroundX:(int)x y:(int)y {
	CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	CGPoint playerPos = CGPointMake(x*tileSize.width, y*tileSize.height);
	
	// offset is the translation to get player to the center
	// note how this gets corrected about tileSize/2 to center player tile
	clipOffset = CGPointMake(center.x-playerPos.x-tileSize.width/2, center.y-playerPos.y-tileSize.height/2);
}

#pragma mark touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchInfoStore storeTouches:touches];
	if (touches.count == 1) {
		UITouch *touch = [touches anyObject];
		if (touch.tapCount == 2) {
			ZTouchInfo *ti = [touchInfoStore touchInfoForTouch:touch];
			NSTimeInterval touchDuration = touch.timestamp - touchInfoStore.singleTapTimestamp;
			if (touchDuration < [ZTouchInfoStore doubleTapDuration]) {
				ti.doubleTap = YES;
			}
		} else {
			touchInfoStore.singleTapTimestamp = touch.timestamp;
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touches.count == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint p = [touch locationInView:self];
		CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		CGPoint delta = CGPointMake(p.x-center.x, center.y-p.y);
		if (fabs(delta.x) < tileSize.width && fabs(delta.y) < tileSize.height) {
			[[MainViewController instance] handleMapTapTileX:u.ux y:u.uy forLocation:p inView:self];
		} else {
			e_direction direction = [ZDirection directionFromEuclideanPointDelta:&delta];
			ZTouchInfo *ti = [touchInfoStore touchInfoForTouch:touch];
			if (ti.doubleTap) {
				[[MainViewController instance] handleDirectionDoubleTap:direction];
			} else {
				[[MainViewController instance] handleDirectionTap:direction];
			}
		}
	}
	[touchInfoStore removeTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchInfoStore removeTouches:touches];
}

#pragma mark misc

- (void)dealloc {
	CGImageRelease(petMark);
	[[TileSet instance] release];
	[touchInfoStore release];
    [super dealloc];
}

@end

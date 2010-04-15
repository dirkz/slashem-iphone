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

#define kMinimumPinchDelta (0.0f)
#define kMinimumPanDelta (20.0f)

static BOOL s_doubleTapsEnabled = NO;

@implementation MapView

@synthesize tileSize;

+ (void)load {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
								@"YES", kDoubleTapsEnabled,
								nil]];
	s_doubleTapsEnabled = [defaults boolForKey:kDoubleTapsEnabled];
	[pool drain];
}

- (void)setup {
	self.multipleTouchEnabled = YES;
	tileSize = CGSizeMake(32.0f, 32.0f);
	maxTileSize = CGSizeMake(32.0f, 32.0f);
	minTileSize = CGSizeMake(8.0f, 8.0f);
	selfTapRectSize = CGSizeMake(40.0f, 40.0f);
	
	// load gfx
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *filename = [defaults objectForKey:kNetHackTileSet];

	TileSet *tileSet = [TileSet tileSetFromTitleOrFilename:filename];
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

		int *glyphs = map.glyphs;
		for (int j = 0; j < ROWNO; ++j) {
			for (int i = 0; i < COLNO; ++i) {
				CGPoint p = CGPointMake(start.x+i*tileSize.width,
										start.y-j*tileSize.height);
				CGRect r = CGRectMake(p.x, p.y, tileSize.width, tileSize.height);
				if (CGRectIntersectsRect(r, rect)) {
					int glyph = glyphAt(glyphs, i, j);
					if (glyph != kNoGlyph) {
						// draw background
						int backGlyph = back_to_glyph(i, j);
						if (backGlyph != kNoGlyph && backGlyph != glyph) {
							// tile 1184, glyph 3627 is dark floor
							//NSLog(@"back %d in %d,%d (player %d,%d)", glyph2tile[backGlyph], i, j, u.ux, u.uy);
							CGImageRef tileImg = [[TileSet instance] imageForGlyph:backGlyph atX:i y:j];
							CGContextDrawImage(ctx, r, tileImg);
						}
						// draw front
						CGImageRef tileImg = [[TileSet instance] imageForGlyph:glyph atX:i y:j];
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
	clipX = x;
	clipY = y;
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
		if (s_doubleTapsEnabled && touch.tapCount == 2 &&
			touch.timestamp - touchInfoStore.singleTapTimestamp < 0.2f) {
			ZTouchInfo *ti = [touchInfoStore touchInfoForTouch:touch];
			ti.doubleTap = YES;
		} else {
			touchInfoStore.singleTapTimestamp = touch.timestamp;
		}
	} else if (touches.count == 2) {
		NSArray *allTouches = [touches allObjects];
		UITouch *t1 = [allTouches objectAtIndex:0];
		UITouch *t2 = [allTouches objectAtIndex:1];
		CGPoint p1 = [t1 locationInView:self];
		CGPoint p2 = [t2 locationInView:self];
		CGPoint d = CGPointMake(p2.x-p1.x, p2.y-p1.y);
		initialDistance = sqrt(d.x*d.x + d.y*d.y);
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touches.count == 1) {
		UITouch *touch = [touches anyObject];
		ZTouchInfo *ti = [touchInfoStore touchInfoForTouch:[touches anyObject]];
		if (!ti.pinched) {
			CGPoint p = [touch locationInView:self];
			CGPoint delta = CGPointMake(p.x-ti.currentLocation.x, p.y-ti.currentLocation.y);
			BOOL move = NO;
			if (!ti.moved && (abs(delta.x) > kMinimumPanDelta || abs(delta.y) > kMinimumPanDelta)) {
				ti.moved = YES;
				move = YES;
			} else if (ti.moved) {
				move = YES;
			}
			if (move) {
				[self moveAlongVector:delta];
				ti.currentLocation = p;
				[self setNeedsDisplay];
			}
		}
	} else if (touches.count == 2) {
		for (UITouch *t in touches) {
			ZTouchInfo *ti = [touchInfoStore touchInfoForTouch:t];
			ti.pinched = YES;
		}
		NSArray *allTouches = [touches allObjects];
		UITouch *t1 = [allTouches objectAtIndex:0];
		UITouch *t2 = [allTouches objectAtIndex:1];
		CGPoint p1 = [t1 locationInView:self];
		CGPoint p2 = [t2 locationInView:self];
		CGPoint d = CGPointMake(p2.x-p1.x, p2.y-p1.y);
		CGFloat currentDistance = sqrt(d.x*d.x + d.y*d.y);
		if (initialDistance == 0) {
			initialDistance = currentDistance;
		} else if (currentDistance-initialDistance > kMinimumPinchDelta) {
			// zoom (in)
			CGFloat zoom = currentDistance-initialDistance;
			[self zoom:zoom];
			initialDistance = currentDistance;
			[self setNeedsDisplay];
		} else if (initialDistance-currentDistance > kMinimumPinchDelta) {
			// zoom (out)
			CGFloat zoom = currentDistance-initialDistance;
			[self zoom:zoom];
			initialDistance = currentDistance;
			[self setNeedsDisplay];
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touches.count == 1) {
		UITouch *touch = [touches anyObject];
		ZTouchInfo *ti = [touchInfoStore touchInfoForTouch:touch];
		if (!ti.moved && !ti.pinched) {
			CGPoint p = [touch locationInView:self];
			if (!self.panned && !iphone_getpos) {
				CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
				CGPoint delta = CGPointMake(p.x-center.x, center.y-p.y);
				if (fabs(delta.x) < selfTapRectSize.width/2 && fabs(delta.y) < selfTapRectSize.height/2) {
					[[MainViewController instance] handleMapTapTileX:u.ux y:u.uy forLocation:p inView:self];
				} else {
					e_direction direction = [ZDirection directionFromEuclideanPointDelta:&delta];
					if (ti.doubleTap) {
						[[MainViewController instance] handleDirectionDoubleTap:direction];
					} else {
						[[MainViewController instance] handleDirectionTap:direction];
					}
				}
			} else {
				// travel to
				int tx, ty; // for travel to and getpos
				[self tilePositionX:&tx y:&ty fromPoint:p];
				[[MainViewController instance] handleMapTapTileX:tx y:ty forLocation:p inView:self];
				[self resetPanOffset];
			}
		}
	}
	initialDistance = 0;
	[touchInfoStore removeTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchInfoStore removeTouches:touches];
}

- (void) moveAlongVector:(CGPoint)d {
	panOffset.x += d.x;
	panOffset.y += d.y;
}

- (void) resetPanOffset {
	panOffset = CGPointMake(0.0f, 0.0f);
}

- (void) zoom:(CGFloat)d {
	d /= 5;
	CGSize originalSize = tileSize;
	tileSize.width += d;
	tileSize.width = round(tileSize.width);
	tileSize.height = tileSize.width;
	if (tileSize.width > maxTileSize.width) {
		tileSize = maxTileSize;
	} else if (tileSize.width < minTileSize.width) {
		tileSize = minTileSize;
	}
	CGFloat aspect = tileSize.width / originalSize.width;
	panOffset.x *= aspect;
	panOffset.y *= aspect;
	[self clipAroundX:clipX y:clipY];
	[self setNeedsDisplay];
}

- (BOOL)panned {
	return panOffset.x != 0 || panOffset.y != 0;
}

- (void)tilePositionX:(int *)px y:(int *)py fromPoint:(CGPoint)p {
	p.x -= panOffset.x;
	p.y -= panOffset.y;
	p.x -= clipOffset.x;
	p.y -= clipOffset.y;
	p.x -= tileSize.width/2;
	p.y -= tileSize.height/2;
	*px = roundf(p.x / tileSize.width);
	*py = roundf(p.y / tileSize.height);
}

#pragma mark misc

- (void)dealloc {
	CGImageRelease(petMark);
	[[TileSet instance] release];
	[touchInfoStore release];
    [super dealloc];
}

@end

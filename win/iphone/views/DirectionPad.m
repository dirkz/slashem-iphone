//
//  DirectionPad.m
//  NetHack
//
//  Created by dirk on 2/3/10.
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

#import "DirectionPad.h"
#import "MainViewController.h"
#import "ZTouchInfoStore.h"
#import "ZTouchInfo.h"

@implementation DirectionPad

- (void)setup {
	currentDirection = kDirectionMax;
	touchInfoStore = [[ZTouchInfoStore alloc] init];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
		[self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddEllipseInRect(path, NULL, self.bounds);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	
	// drawCircle
	float fillColor[] = {1.0f,1.0f,1.0f,1.0f};
	CGContextSetFillColor(ctx, fillColor);
	CGContextFillEllipseInRect(ctx, self.bounds);
	
	// draw direction wedge (sort of)
	if (currentDirection != kDirectionMax) {
		// base angles (must be in same order as e_direction!)
		float baseAngles[kDirectionMax] = {
			M_PI/2,
			M_PI/4,
			0.0f,
			7*M_PI/4,
			3*M_PI/2,
			5*M_PI/4,
			M_PI,
			3*M_PI/4
		};
		float dRad = 2*M_PI/8; // size of every direction wedge in rad
		float dRad2 = dRad/2;
		float baseAngle = baseAngles[currentDirection];
		float angles[] = { baseAngle+dRad2, baseAngle-dRad2 };
		float radius = self.bounds.size.width/2;
		CGContextTranslateCTM(ctx, radius, radius);
		CGContextScaleCTM(ctx, 1.0f, -1.0f);
		CGContextMoveToPoint(ctx, 0.0f, 0.0f);
		CGContextAddLineToPoint(ctx, cosf(angles[0])*radius, sinf(angles[0])*radius);
		CGContextMoveToPoint(ctx, 0.0f, 0.0f);
		CGContextAddLineToPoint(ctx, cosf(angles[1])*radius, sinf(angles[1])*radius);
		CGContextDrawPath(ctx, kCGPathStroke);
	}
	
	CFRelease(path);
}

- (void)resetCurrentDirection:(NSTimer *)timer {
	currentDirection = kDirectionMax;
	[self setNeedsDisplay];
}

- (void)displayTouch:(UITouch *)touch {
	CGPoint p = [touch locationInView:self];
	CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	CGPoint delta = CGPointMake(p.x-center.x, center.y-p.y);
	currentDirection = [ZDirection directionFromEuclideanPointDelta:&delta];
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchInfoStore storeTouches:touches];
	if (touches.count == 1) {
		UITouch *touch = [touches anyObject];
		[self displayTouch:touch];
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
	if (touches.count == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint p = [touch locationInView:self];
		UIView *hitView = [self hitTest:p withEvent:event];
		if (hitView == self) {
			[self displayTouch:touch];
		} else {
			[self resetCurrentDirection:nil];
		}
	}	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touches.count == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint p = [touch locationInView:self];
		CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		CGPoint delta = CGPointMake(p.x-center.x, center.y-p.y);
		e_direction direction = [ZDirection directionFromEuclideanPointDelta:&delta];
		ZTouchInfo *ti = [touchInfoStore touchInfoForTouch:touch];
		if (ti.doubleTap) {
			[[MainViewController instance] handleDirectionDoubleTap:direction];
		} else {
			[[MainViewController instance] handleDirectionTap:direction];
		}
	}
	[touchInfoStore removeTouches:touches];
	[self resetCurrentDirection:nil];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[touchInfoStore removeTouches:touches];
	[self resetCurrentDirection:nil];
}

- (void)dealloc {
	[touchInfoStore release];
    [super dealloc];
}

@end

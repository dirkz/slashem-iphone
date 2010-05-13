//
//  MapViewGL.m
//  SlashEM
//
//  Created by Dirk Zimmermann on 5/13/10.
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

#import "MapViewGL.h"
#import "MapRenderer.h"

@implementation MapViewGL

@synthesize zoomFactor;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder*)coder {    
    if ((self = [super initWithCoder:coder])) {
		zoomFactor = 1.0f;

        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *) self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE],
										kEAGLDrawablePropertyRetainedBacking,
										kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		renderer = [[MapRenderer alloc] init];
		
		if (!renderer) {
			[self release];
			return nil;
		}

		renderer.view = self;
	}
	
    return self;
}

// probably not needed at all
- (void)drawView:(id)sender {
     [renderer render];
}

#pragma mark UIView compatibility

- (void)layoutSubviews {
	[renderer resizeFromLayer:(CAEAGLLayer*) self.layer];
    [self drawView:nil];
}

- (void)setNeedsDisplay {
    [renderer render];
}

#pragma mark MainViewController support

- (void)zoom:(CGFloat)d {
	d /= 100.0f;
	zoomFactor += d;

	if (zoomFactor > 1.0f) {
		zoomFactor = 1.0f;
	} else if (zoomFactor < 0.25f) {
		zoomFactor = 0.25f;
	}
	
	[renderer render];
}

#pragma mark memory

- (void)dealloc {
    [renderer release];
    [super dealloc];
}

@end

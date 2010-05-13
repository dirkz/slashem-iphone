//
//  MapRenderer.m
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

#import "MapRenderer.h"
#import "NhMapWindow.h"
#import "TileSetGL.h"
#import "MapViewGL.h"

#define TILE_WIDTH (32.0f)
#define TILE_HEIGHT (32.0f)

typedef struct _vertex {
	GLfloat x;
	GLfloat y;
	GLshort s;
	GLshort t;
	
} vertex;

@implementation MapRenderer

@synthesize view;

// Create an ES 1.1 context
- (id)init {
	if (self = [super init]) {
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffersOES(1, &defaultFramebuffer);
		glGenRenderbuffersOES(1, &colorRenderbuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
	}
	
	return self;
}

#pragma mark rendering

- (void)render {
	NhMapWindow *map = (NhMapWindow *) [NhWindow mapWindow];
	if (map) {
		TileSetGL *tileSet = (TileSetGL *) [TileSet instance];
		glEnable(GL_TEXTURE_2D);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);

		glViewport(0, 0, backingWidth, backingHeight);
		
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		
		glOrthof(0.0f, backingWidth, backingHeight, 0.0f, 1.0f, -1.0f);
		
		static vertex triangles[4] = {
			{ 0.0f,  0.0f, 0, 0 },
			{ TILE_WIDTH,  0.0f, 1, 0 },
			{ 0.0f,   TILE_HEIGHT, 0, 1 },
			{ TILE_WIDTH, TILE_HEIGHT, 1, 1}
		};
		
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);
		
		glPushMatrix();
		
		glScalef(view.zoomFactor, view.zoomFactor, 0.0f);
		GLfloat tileWidth = TILE_WIDTH * view.zoomFactor;
		GLfloat tileHeight = TILE_HEIGHT * view.zoomFactor;
		glTranslatef(backingWidth/2-tileWidth/2 - view.clipX * tileWidth + view.panOffset.x,
					 backingHeight/2-tileHeight/2 - view.clipY * tileHeight + view.panOffset.y,
					 0.0f);
		
		int *glyphs = map.glyphs;
		//BOOL supportsTransparency = [[TileSet instance] supportsTransparency];
		for (int j = 0; j < ROWNO; ++j) {
			for (int i = 0; i < COLNO; ++i) {
				int glyph = glyphAt(glyphs, i, j);
				if (glyph != kNoGlyph) {
					glPushMatrix();
					glTranslatef(i * TILE_WIDTH, j * TILE_HEIGHT, 0.0f);
					
					glVertexPointer(2, GL_FLOAT, sizeof(vertex), triangles);
					glEnableClientState(GL_VERTEX_ARRAY);
					
					glTexCoordPointer(2, GL_SHORT, sizeof(vertex), &triangles[0].s);
					glEnableClientState(GL_TEXTURE_COORD_ARRAY);
					
					glBindTexture(GL_TEXTURE_2D, [tileSet textureForGlyph:glyph atX:i y:j]);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

					glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
					glPopMatrix();
				}
			}
		}

		glDisable(GL_TEXTURE_2D);
		
		glPopMatrix();
		
		// draw HUD
		
		[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	}
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer {
	// Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
	
	return YES;
}

#pragma mark memory management

- (void)dealloc {
	if (defaultFramebuffer)	{
		glDeleteFramebuffersOES(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}
	
	if (colorRenderbuffer) {
		glDeleteRenderbuffersOES(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
	}
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end

//
//  MapRenderer.h
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

#import <Foundation/Foundation.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "ESRenderer.h"

@class MapViewGL;

@interface MapRenderer : NSObject <ESRenderer> {

	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer;
	
	// the parent MapView object (for accessing nh clip coordinates, panning etc.)
	MapViewGL *view;
	
}

@property (nonatomic, assign) MapViewGL *view;

@end

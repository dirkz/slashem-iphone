//
//  TileSetGL.h
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

#import "TileSet.h"

/**
 * Real subclass from TileSet since we still have to support showing UIKit tiles
 * in menus anyway.
 */
@interface TileSetGL : TileSet {

	GLuint *textures;
	BOOL *textureCreated;

}

- (GLuint)textureForGlyph:(int)glyph atX:(int)x y:(int)y;

@end

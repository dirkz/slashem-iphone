//
//  TileSetGL.m
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

#import "TileSetGL.h"

// as defined in tile.c
extern int total_tiles_used;

void glCheckError() {
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		NSLog(@"Error uploading texture. glError: 0x%04X", err);
	}
}

void glCreateTexture(CGImageRef cgImage, GLuint name) {
	GLenum internalFormat = GL_RGBA;
	uint width = CGImageGetWidth(cgImage);
	uint height = CGImageGetHeight(cgImage);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	GLubyte *data = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
	CGContextRef cgContext = CGBitmapContextCreate(data, width, height, 8, width * 4,
												   colorSpace, kCGImageAlphaPremultipliedLast);
	if (cgContext != NULL)
	{
		// Set the blend mode to copy. We don't care about the previous contents.
		CGContextSetBlendMode(cgContext, kCGBlendModeCopy);
		CGContextDrawImage(cgContext, CGRectMake(0.0f, 0.0f, width, height), cgImage);
		
		glBindTexture(GL_TEXTURE_2D, name);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		
		glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);

		glCheckError();
		
		CGContextRelease(cgContext);
	}
	
	free(data);
	CGColorSpaceRelease(colorSpace);
}

@implementation TileSetGL

- (id)initWithImage:(UIImage *)img tileSize:(CGSize)ts title:(NSString *)t {
	if (self = [super initWithImage:img tileSize:ts title:title]) {
		assert(total_tiles_used > 0);

		textures = calloc(total_tiles_used, sizeof(GLuint));
		glGenTextures(total_tiles_used, textures);
		glCheckError();

		textureCreated = calloc(total_tiles_used, sizeof(BOOL));
		for (int i = 0; i < total_tiles_used; ++i) {
			textureCreated[i] = NO;
		}
	}
	return self;
}

- (GLuint)textureForGlyph:(int)glyph atX:(int)x y:(int)y {
	int tile = glyph2tile[glyph];
	if (!textureCreated[tile]) {
		glCreateTexture([self imageForTile:tile], textures[tile]);
	}
	return textures[tile];
}

#pragma mark memory management

- (void)dealloc {
	glDeleteTextures(total_tiles_used, textures);
	glCheckError();
	if (textures) {
		free(textures);
	}
	if (textureCreated) {
		free(textureCreated);
	}
	[super dealloc];
}

@end

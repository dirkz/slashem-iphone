//
//  MapView.h
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

#import <UIKit/UIKit.h>

#include "hack.h"

#define kDoubleTapsEnabled (@"kDoubleTapsEnabled")

@class ZTouchInfoStore;

@interface MapView : UIView {

	CGSize tileSize;
	
	CGSize maxTileSize;
	CGSize minTileSize;

	CGImageRef petMark;
	
	ZTouchInfoStore *touchInfoStore;
	
	int clipX;
	int clipY;

	// the translation needed to center player, based on clip
	CGPoint clipOffset;

	// created by panning around
	CGPoint panOffset;
	
	// for zooming
	CGFloat initialDistance;
	
	// the hit box to hit for detecting tap on self
	CGSize selfTapRectSize;
}

@property (nonatomic, readonly) CGSize tileSize;
@property (nonatomic, readonly) BOOL panned;

- (void)clipAroundX:(int)x y:(int)y;

- (void)moveAlongVector:(CGPoint)d;
- (void)resetPanOffset;
- (void)zoom:(CGFloat)d;
- (void)tilePositionX:(int *)px y:(int *)py fromPoint:(CGPoint)p;

@end

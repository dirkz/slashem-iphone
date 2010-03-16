//
//  ZDirection.m
//  SlashEM
//
//  Created by dirk on 1/1/10.
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

#include <math.h>

#import "ZDirection.h"

#define kCos45 (0.707106829f)
#define kCos30 (0.866025404f)

CGPoint s_directionVectors[kDirectionMax] = {
	{ 0.0f, 1.0f },
	{ kCos45, kCos45 },
	{ 1.0f, 0.0f },
	{ kCos45, -kCos45 },
	{ 0.0f, -1.0f },
	{ -kCos45, -kCos45 },
	{ -1.0f, 0.0f },
	{ -kCos45, kCos45 },
};

static float vectorLength(const CGPoint *v) {
	return sqrtf(v->x*v->x + v->y*v->y);
}

static float dotProduct(const CGPoint *v1, const CGPoint *v2) {
	return v1->x*v2->x + v1->y*v2->y;
}

static void normalize(CGPoint *v) {
	float l = vectorLength(v);
	v->x /= l;
	v->y /= l;
}

@implementation ZDirection

+ (e_direction) directionFromEuclideanPointDelta:(CGPoint *)delta {
	normalize(delta);
	for (int i = 0; i < kDirectionMax; ++i) {
		float dotP = dotProduct(delta, &s_directionVectors[i]);
		if (dotP >= kCos30) {
			return i;
		}
	}
	return kDirectionMax;
}

@end

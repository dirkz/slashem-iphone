//
//  StatusView.m
//  SlashEM
//
//  Created by Dirk Zimmermann on 4/24/10.
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

#import "StatusView.h"
#import "NhStatus.h"

@implementation StatusView

- (void)setup {
	status = [[NhStatus alloc] init];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		[self setup];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	float space = 5.0f;
	UIFont *font = [UIFont systemFontOfSize:13.0f];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	NSString *bot1 = [NSString stringWithFormat:@"Str:%s Dx:%u Con:%u Int:%u Wis:%u Cha:%u %s",
					  status.strength, status.dexterity, status.constitution, status.intelligence,
					  status.wisdom, status.charisma, status.alignment];
	CGPoint p = CGPointMake(5.0f, 0.0f);
	CGSize size = [bot1 drawAtPoint:p withFont:font];
	NSString *bot2 = [NSString stringWithFormat:@"%s $%d Hp:%u/%u Pw:%u/%u AC:%d XP:%u T:%u",
					  status.level, status.money, status.hitpoints, status.maxHitpoints, status.power,
					  status.maxPower, status.ac, status.xlvl, status.turn];
	p.y += size.height;
	
	// make font smaller if a lot to display
	if (self.bounds.size.width <= 320.0f && (status.hungryState != 1 || strlen(status.status))) {
		font = [UIFont systemFontOfSize:10.0f];
	}
	
	size = [bot2 drawAtPoint:p withFont:font];

	p.x += size.width + space;
	if (status.hungryState != 1) {
		if (status.hungryState > 1) {
			CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
			CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
		}
		NSString *hunger = [NSString stringWithCString:status.hunger encoding:NSASCIIStringEncoding];
		size = [hunger drawAtPoint:p withFont:font];
		p.x += size.width + space;
	}
	
	if (strlen(status.status)) {
		CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
		CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
		NSString *info = [NSString stringWithCString:status.status encoding:NSASCIIStringEncoding];
		size = [info drawAtPoint:p withFont:font];
	}
}

- (void)update {
	[status update];
	[self setNeedsDisplay];
}

- (void)dealloc {
	[status release];
    [super dealloc];
}

@end

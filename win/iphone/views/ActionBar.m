//
//  ActionBar.m
//  SlashEM
//
//  Created by dirk on 1/6/10.
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

#import "ActionBar.h"
#import "Action.h"
#import "MainViewController.h"

@implementation ActionBar

@synthesize actions;

- (void)setup {
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

- (void)layoutSubviews {
	[super layoutSubviews];
	float width = self.contentSize.width;
	float parentWidth = self.bounds.size.width;
	if (width < parentWidth) {
		[self setContentOffset:CGPointMake(-(parentWidth-width)/2, 0.0f) animated:NO];
	}
}

- (UIControl *)buttonForAction:(Action *)action {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:action.title forState:UIControlStateNormal];
	[button addTarget:action action:@selector(invoke:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)setActions:(NSArray *)as {
	if (actions != as) {
		[actions release];
	}
	actions = [as retain];
	[self update];
}

- (void)update {
	if (actions && actions.count > 0) {
		CGRect frame = CGRectZero;
		for (Action *a in actions) {
			UIView *button = [self buttonForAction:a];
			CGSize buttonSize = [button sizeThatFits:self.bounds.size];
			frame.size = buttonSize;
			button.frame = frame;
			frame.origin.x += buttonSize.width;
			[self addSubview:button];
		}
		frame.size.width = frame.origin.x;
		self.contentSize = frame.size;
		float width = frame.size.width;
		float parentWidth = self.bounds.size.width;
		if (width < parentWidth) {
			[self setContentOffset:CGPointMake(-(parentWidth-width)/2, 0.0f) animated:YES];
		}
	}
}

- (void)dealloc {
	[actions release];
    [super dealloc];
}

@end

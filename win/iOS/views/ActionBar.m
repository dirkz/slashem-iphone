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

- (UIControl *)buttonForAction:(Action *)action {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.titleLabel.font = [button.titleLabel.font fontWithSize:12.0f];
	[button setBackgroundImage:[UIImage imageNamed:@"actionButton.png"] forState:UIControlStateNormal];
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
	CGRect scrollFrame = CGRectZero;
	scrollFrame.size.width = 0;
	if (actions && actions.count > 0) {
		CGRect controlFrame = CGRectZero;
		for (Action *a in actions) {
			UIView *button = [self buttonForAction:a];
			CGSize buttonSize = [button sizeThatFits:self.bounds.size];
			controlFrame.size = buttonSize;
			button.frame = controlFrame;
			[self addSubview:button];
			controlFrame.origin.x += buttonSize.width;
			scrollFrame.size.height = buttonSize.height;
			scrollFrame.size.width += buttonSize.width;
		}
		self.frame = scrollFrame;
	}
}

- (void)dealloc {
	[actions release];
    [super dealloc];
}

@end

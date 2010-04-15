//
//  MessageView.m
//  NetHack
//
//  Created by dirk on 2/6/10.
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

#import <QuartzCore/CALayer.h>

#import "MessageView.h"
#import "NhWindow.h"

@implementation MessageView

@synthesize messageWindow;

- (void)setup {
	self.font = [self.font fontWithSize:14.0f];
	displayState = eNormal;
	originalHeight = self.frame.size.height;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}

- (void)enlargeContentSize:(CGSize)contentSize bounds:(CGSize)bounds {
	switch (displayState) {
		case eNormal:
		case eEnlarged: {
			CGRect frame = self.frame;
			CGRect superBounds = self.superview.bounds;
			frame.size.height = superBounds.size.height/3;
			if (frame.size.height > contentSize.height) {
				frame.size.height = contentSize.height;
			}
			self.frame = frame;
			[self setContentOffset:CGPointMake(0.0f, -(self.bounds.size.height-contentSize.height)) animated:NO];
			displayState = eEnlarged;
		}
			break;
		default:
			break;
	}
}

- (void)shrinkBack {
	CGRect frame = self.frame;
	frame.size.height = originalHeight;
	self.frame = frame;
	[self scrollToBottomResize:NO];
}

- (void)scrollToBottomResize:(BOOL)enlarge {
	CGSize contentSize = self.contentSize;
	CGSize bounds = self.bounds.size;
	if (contentSize.height > bounds.height) {
		if (enlarge) {
			[self enlargeContentSize:contentSize bounds:bounds];
		} else {
			[self setContentOffset:CGPointMake(0.0f, -(self.bounds.size.height-contentSize.height)) animated:NO];
		}
	} else {
		[self setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
	}
}

- (void)setText:(NSString *)s {
	[super setText:s];
	[self scrollToBottomResize:YES];
}

- (IBAction)toggleMessageHistory:(id)sender {
	//NSLog(@"toggleMessageHistory");
	if (historyDisplayed) {
		[self shrinkBack];
		historyDisplayed = NO;
	} else if (messageWindow) {
		[self setText:messageWindow.text];
		historyDisplayed = YES;
	}
}

#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
	if (displayState == eEnlarged) {
		[self shrinkBack];
		displayState = eNormal;
	}
	return NO;
}

@end

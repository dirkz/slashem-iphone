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
	originalHeight = self.frame.size.height;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}

- (BOOL)enlarged {
	return self.frame.size.height > originalHeight;
}

- (void)resize {
	CGSize contentSize = self.contentSize;
	CGRect frame = self.frame;
	frame.size.height = contentSize.height;
	if (frame.size.height > self.superview.bounds.size.height/3) {
		frame.size.height = self.superview.bounds.size.height/3;
	}
	self.frame = frame;
}

- (void)shrinkBack {
	CGRect frame = self.frame;
	frame.size.height = originalHeight;
	self.frame = frame;
	[self scrollToBottom];
}

- (void)scrollToBottom {
	CGSize contentSize = self.contentSize;
	if (contentSize.height > self.bounds.size.height) {
		[self setContentOffset:CGPointMake(0.0f, -(self.bounds.size.height-contentSize.height)) animated:NO];
	} else {
		[self setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
	}
}

- (void)setText:(NSString *)s {
	[super setText:s];
	if (!s) {
		[self setContentSize:CGSizeZero];
	}
	[self resize];
	[self scrollToBottom];
	historyDisplayed = NO; // assume it didn't originate from toggleMessageHistory
}

- (IBAction)toggleMessageHistory:(id)sender {
	if (historyDisplayed) {
		[self shrinkBack];
		historyDisplayed = NO;
	} else if (messageWindow) {
		[self setText:messageWindow.historyText];
		historyDisplayed = YES;
	}
}

#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
	if (self.enlarged) {
		[self shrinkBack];
		historyDisplayed = NO;
	}
	return NO;
}

@end

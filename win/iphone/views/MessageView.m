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

#import "MessageView.h"
#import "NhWindow.h"

@implementation MessageView

@synthesize messageWindow;

- (void)setup {
	self.font = [self.font fontWithSize:14.0f];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}

- (void)scrollToBottom {
	CGSize content = self.contentSize;
	CGSize bounds = self.bounds.size;
	//NSLog(@"%3.2f (%3.2f / %3.2f)", self.contentOffset.y, content.height, bounds.height);
	if (content.height > bounds.height) {
		[self setContentOffset:CGPointMake(0.0f, -(bounds.height-content.height)) animated:YES];
	} else {
		[self setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
	}
}

- (void)setText:(NSString *)s {
	[super setText:s];
	[self scrollToBottom];
}

#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
	return NO;
}

- (IBAction)toggleView:(id)sender {
	if (messageWindow) {
		if (!historyDisplayed) {
			CGRect frame = originalFrame = self.frame;
			CGRect superBounds = self.superview.bounds;
			frame.size.height = superBounds.size.height/3;
			[UIView beginAnimations:@"enlarge" context:NULL];
			self.frame = frame;
			[self setText:messageWindow.historyText];
			[UIView commitAnimations];
			historyDisplayed = YES;
		} else {
			[UIView beginAnimations:@"downsize" context:NULL];
			self.frame = originalFrame;
			[UIView commitAnimations];
			historyDisplayed = NO;
		}
	}
	[self scrollToBottom];
}

@end

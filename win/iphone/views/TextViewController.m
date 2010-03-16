//
//  TextViewController.m
//  NetHack
//
//  Created by Dirk Zimmermann on 2/18/10.
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

#import "TextViewController.h"
#import "NhEventQueue.h"

@implementation TextViewController

@synthesize text;
@synthesize blocking;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	textView.text = text;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	if (blocking) {
		[[NhEventQueue instance] addKey:-1];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dismissViewAction:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
}

- (void)dealloc {
    [super dealloc];
}

@end

//
//  QuestionViewController.m
//  SlashEM
//
//  Created by Dirk Zimmermann on 3/23/10.
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

#import "QuestionViewController.h"
#import "NhYnQuestion.h"
#import "NhEventQueue.h"
#import "NhWindow.h"

@implementation QuestionViewController

@synthesize tableView = tv;
@synthesize question;

- (void)scrollToBottom {
	CGSize content = textView.contentSize;
	CGSize bounds = textView.bounds.size;
	//DLog(@"%3.2f (%3.2f / %3.2f)", self.contentOffset.y, content.height, bounds.height);
	if (content.height > bounds.height) {
		[textView setContentOffset:CGPointMake(0.0f, -(bounds.height-content.height)) animated:YES];
	} else {
		[textView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	textView.text = [[NhWindow messageWindow] text];
	[self scrollToBottom];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return strlen(question.choices);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSString *title = nil;
	if (question.choices[indexPath.row] == '\033') {
		title = @"Cancel";
	} else {
		title = [NSString stringWithFormat:@"%c", question.choices[indexPath.row]];
	}

	cell.textLabel.text = title;

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	char c = question.choices[indexPath.row];
	[[NhEventQueue instance] addKey:c];
	[self dismissModalViewControllerAnimated:NO];
}

#pragma mark memory handling

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end

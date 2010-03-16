//
//  OptionsViewController.m
//  NetHack
//
//  Created by Dirk Zimmermann on 2/19/10.
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

#import "OptionsViewController.h"
#import "NhOption.h"

#include "hack.h"

@implementation OptionsViewController

#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
		options = [[NSMutableArray alloc] init];
		[options addObject:[NSMutableArray array]];
		[options addObject:[NSMutableArray array]];
    }
    return self;
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	int i = 0;

	NSMutableArray *elements = [options objectAtIndex:0];
	[elements removeAllObjects];
	while (boolopt[i].name) {
		if (boolopt[i].optflags == SET_IN_GAME && boolopt[i].addr) {
			[elements addObject:[NhOption optionWithTitle:boolopt[i].name index:i type:simple]];
		}
		i++;
	}

	i = 0;
	elements = [options objectAtIndex:1];
	[elements removeAllObjects];
	while (compopt[i].name) {
		if (compopt[i].optflags == SET_IN_GAME) {
			[elements addObject:[NhOption optionWithTitle:compopt[i].name index:i type:compound]];
		}
		i++;
	}
	
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[[options objectAtIndex:0] removeAllObjects];
	[[options objectAtIndex:1] removeAllObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return options.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[options objectAtIndex:section] count];
}

- (void)updateCell:(UITableViewCell *)cell withOption:(NhOption *)option {
    cell.textLabel.text = option.title;
	if (option.simple) {
		if (option.simpleValue) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else {
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NhOption *option = [[options objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[self updateCell:cell withOption:option];
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NhOption *option = [[options objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if (option.simple) {
		option.simpleValue = !option.simpleValue;
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[self updateCell:cell withOption:option];
	} else {
		if (special_handling([option.title cStringUsingEncoding:NSASCIIStringEncoding], FALSE, FALSE)) {
		} else {
			NSLog(@"NO special_handling for %@", option.title);
		}
	}
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	[options release];
    [super dealloc];
}

@end


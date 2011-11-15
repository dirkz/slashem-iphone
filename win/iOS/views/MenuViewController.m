//
//  MenuViewController.m
//  NetHack
//
//  Created by dirk on 2/5/10.
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

#import "MenuViewController.h"
#import "NhMenuWindow.h"
#import "NhItemGroup.h"
#import "NhItem.h"
#import "NhEventQueue.h"
#import "TileSet.h"
#import "ZObjectCache.h"

@implementation MenuViewController

@synthesize menuWindow;
@synthesize tableView = tv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		sliderItems = [[ZObjectCache alloc] init];
	}
	return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	if (self.menuWindow.how == PICK_ONE || self.menuWindow.how == PICK_NONE) {
		okButton.enabled = NO;
		invertSelectionButton.enabled = NO;
		selectAllButton.enabled = NO;
		selectNoneButton.enabled = NO;
	} else if (self.menuWindow.how == PICK_ANY) {
		okButton.enabled = YES;
		invertSelectionButton.enabled = YES;
		selectAllButton.enabled = YES;
		selectNoneButton.enabled = YES;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[sliderItems removeAllObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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

- (void)setMenuWindow:(NhMenuWindow *)w {
	if (w != menuWindow) {
		[menuWindow release];
		menuWindow = [w retain];
	}
	// same window can change content, so do this in any case
	[self.tableView reloadData];
}

#pragma mark button actions

- (IBAction)cancelButton:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
	[[NhEventQueue instance] addKey:-1]; // cancel
}

- (IBAction)invertSelectionButton:(id)sender {
	// PICK_ANY
	for (NhItemGroup *group in self.menuWindow.itemGroups) {
		for (NhItem *item in group.items) {
			item.selected = !item.selected;
		}
	}
	[self.tableView reloadData];
}

- (IBAction)selectAllButton:(id)sender {
	// PICK_ANY
	for (NhItemGroup *group in self.menuWindow.itemGroups) {
		for (NhItem *item in group.items) {
			item.selected = YES;
		}
	}
	[self.tableView reloadData];
}

- (IBAction)selectNoneButton:(id)sender {
	// PICK_ANY
	for (NhItemGroup *group in self.menuWindow.itemGroups) {
		for (NhItem *item in group.items) {
			item.selected = NO;
		}
	}
	[self.tableView reloadData];
}

- (IBAction)okButton:(id)sender {
	// PICK_ANY
	[self dismissModalViewControllerAnimated:NO];
	[self.menuWindow.selected removeAllObjects];
	for (NhItemGroup *group in self.menuWindow.itemGroups) {
		for (NhItem *item in group.items) {
			if (item.selected) {
				[self.menuWindow.selected addObject:item];
			}
		}
	}
	[[NhEventQueue instance] addKey:self.menuWindow.selected.count]; // number of items
}

- (IBAction)sliderValueChanged:(id)sender {
	NSIndexPath *indexPath = [sliderItems objectForKey:sender];
	NhItem *item = [self.menuWindow itemAtIndexPath:indexPath];
	item.amount = roundf(((UISlider *) sender).value);
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if (self.menuWindow.how == PICK_ANY) {
		item.selected = YES;
	}
	[self updateCell:cell withItem:item atIndexPath:indexPath];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.menuWindow.itemGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NhItemGroup *g = [self.menuWindow.itemGroups objectAtIndex:section];
    return g.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NhItemGroup *g = [self.menuWindow.itemGroups objectAtIndex:section];
	return g.title;
}

- (void)updateCell:(UITableViewCell *)cell withItem:(NhItem *)item atIndexPath:(NSIndexPath *)indexPath {
	if (self.menuWindow.how != PICK_NONE && item.maxAmount > 1) {
		if (item.amount == -1) {
			item.amount = item.maxAmount;
		}
		UILabel *textLabel = (UILabel *) [cell viewWithTag:1];
		if (isalpha(item.inventoryLetter)) {
			textLabel.text = [NSString stringWithFormat:@"%c - %d/%@", item.inventoryLetter, item.amount, item.title];
		} else {
			textLabel.text = [NSString stringWithFormat:@"%d/%@", item.amount, item.title];
		}

		UISlider *slider = (UISlider *) [cell viewWithTag:2];
		slider.hidden = NO;
		slider.maximumValue = item.maxAmount;
		slider.value = item.amount;
		slider.minimumValue = 1;
		[sliderItems setObject:indexPath forKey:slider];
		[slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	} else {
		if (isalpha(item.inventoryLetter)) {
			cell.textLabel.text = [NSString stringWithFormat:@"%c - %@", item.inventoryLetter, item.title];
		} else {
			cell.textLabel.text = item.title;
		}
		cell.detailTextLabel.text = item.detail;
	}

	if (item.glyph && item.glyph != NO_GLYPH) {
		CGImageRef img = [[TileSet instance] imageForGlyph:item.glyph];
		cell.imageView.image = [UIImage imageWithCGImage:img];
	} else {
		cell.imageView.image = nil;
	}
	
	if (self.menuWindow.how == PICK_ANY) {
		cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MenuViewCell = @"MenuViewCell";
    static NSString *MenuViewCellWithSlider = @"MenuViewCellWithSlider";
	NSString *CellIdentifier = MenuViewCell;
    
	NhItem *item = [self.menuWindow itemAtIndexPath:indexPath];
	if (self.menuWindow.how != PICK_NONE && item.maxAmount > 1) {
		CellIdentifier = MenuViewCellWithSlider;
	}

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:CellIdentifier] autorelease];
		if (CellIdentifier == MenuViewCellWithSlider) {
			static const float cellHeight = 44.0f;
			static const float marginY = 1.0f;
			static const float startY = 3.0f;
			static const float sliderHeight = 23.0f;
			float textLabelHeight = cellHeight-marginY-startY-sliderHeight;
			static const float imageViewWidth = 45.0f;
			static const float paddingRight = 5.0f;

			// textLabel
			CGRect frame = cell.contentView.bounds;
			frame.size.height = textLabelHeight;
			frame.origin.y = startY;
			frame.origin.x = imageViewWidth;
			frame.size.width -= imageViewWidth + paddingRight;
			UILabel *textLabel = [[UILabel alloc] initWithFrame:frame];
			textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			textLabel.tag = 1;
			textLabel.font = [cell.textLabel.font fontWithSize:14.0f];
			[cell.contentView addSubview:textLabel];
			[textLabel release];
			
			// slider
			frame.origin.y += frame.size.height + marginY;
			frame.size.height = sliderHeight;
			frame.size.width /= 2.0f;
			UISlider *slider = [[UISlider alloc] initWithFrame:frame];
			slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			slider.tag = 2;
			[cell.contentView addSubview:slider];
			[slider release];
		} else {
			cell.textLabel.font = [cell.textLabel.font fontWithSize:14.0f];
		}

	}
    
	[self updateCell:cell withItem:item atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NhItem *item = [self.menuWindow itemAtIndexPath:indexPath];
	if (menuWindow.how == PICK_ANY) {
		item.selected = !item.selected;
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = item.selected ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
	} else if (self.menuWindow.how == PICK_ONE) {
		item.selected = YES;
		if (item.amount == item.maxAmount) { // throw doesn't allow item amounts
			item.amount = -1;
		}
		[self.menuWindow.selected removeAllObjects];
		[self.menuWindow.selected addObject:item];
		[self dismissModalViewControllerAnimated:NO];
		[[NhEventQueue instance] addKey:1]; // one item
	}
}

- (void)dealloc {
	[sliderItems release];
    [super dealloc];
}

@end


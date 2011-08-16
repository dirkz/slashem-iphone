//
//  ObjectViewController.m
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

#import "InventoryViewController.h"
#import "NhObject.h"
#import "NhEventQueue.h"
#import "ItemViewController.h"
#import "NhInventory.h"
#import "TileSet.h"
#import "MainViewController.h"
#import "NhCommand.h"

#include "hack.h"

@implementation InventoryViewController

@synthesize tableView = tv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		inventory = [[NhInventory alloc] init];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self updateInventory];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)updateInventory {
	[inventory update];
	[self.tableView reloadData];
	struct obj *object = level.objects[u.ux][u.uy];
	if (object) {
		pickupButton.enabled = YES;
	} else {
		pickupButton.enabled = NO;
	}
}

- (IBAction)editModeAction:(id)sender {
	self.tableView.editing = ! self.tableView.editing;
}

- (IBAction)dropAction:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
	[[NhEventQueue instance] addKey:'D'];
}

- (IBAction)pickupAction:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
	[[NhEventQueue instance] addKey:','];
}

- (IBAction)whatsHereAction:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
	[[NhEventQueue instance] addKey:':'];
}

- (IBAction)disrobeAction:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
	[[NhEventQueue instance] addKey:'A'];
}

- (IBAction)cancelAction:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
}

#pragma mark memory management

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

- (void)dealloc {
	[inventory release];
    [super dealloc];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return inventory.objectClasses.count;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[inventory.objectClasses objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [cell.textLabel.font fontWithSize:14.0f];
    }
    
	NhObject *item = [inventory objectAtIndexPath:indexPath];
	if (item.inventoryLetter != '-') {
		cell.textLabel.text = [NSString stringWithFormat:@"%c - %@", item.inventoryLetter, item.title];
	} else {
		cell.textLabel.text = item.title;
	}
	cell.detailTextLabel.text = item.detail;
	
	if (item.glyph && item.glyph != NO_GLYPH) {
		CGImageRef img = [[TileSet instance] imageForGlyph:item.glyph];
		cell.imageView.image = [UIImage imageWithCGImage:img];
	} else {
		cell.imageView.image = nil;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
	NhObject *item = [inventory objectAtIndexPath:indexPath];
	NhCommand *cmd = [NhCommand commandWithObject:item title:"Drop" key:'d'];
	if (item.object) {
		if (item.object->owornmask) {
			if (item.object->owornmask & W_RING || item.object->owornmask & W_AMUL || item.object->owornmask & W_TOOL) {
				if (inventory.numberOfPutOnItems > 1) {
					cmd = [NhCommand commandWithObject:item title:"Remove" key:'R'];
				} else {
					cmd = [NhCommand commandWithTitle:"Remove" key:'R'];
				}
			} else if (item.object->owornmask & W_ARMOR) {
					if (inventory.numberOfWornArmor > 1) {
						cmd = [NhCommand commandWithObject:item title:"Take off" key:'T'];
					} else {
						cmd = [NhCommand commandWithTitle:"Take off" key:'T'];
					}
			}
		}
	}
	[cmd invoke:nil];
	
	// we have to dismiss inventory, b/c there are cases where a question occurs
	// (e.g. when dropping stuff for sale in a shop)
	[self dismissModalViewControllerAnimated:NO];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
	  toIndexPath:(NSIndexPath *)toIndexPath {
	NhObject *fromItem = [inventory objectAtIndexPath:fromIndexPath];
	NhObject *toItem = [inventory objectAtIndexPath:toIndexPath];
	char cmd[] = { M('a'), fromItem.inventoryLetter, toItem.inventoryLetter, '\0' };
	[[NhEventQueue instance] addKeys:cmd];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NhObject *item = [inventory objectAtIndexPath:indexPath];
    ItemViewController *itemViewController = [[ItemViewController alloc] initWithNibName:@"ItemViewController" bundle:nil];
	itemViewController.inventory = inventory;
	itemViewController.item = item;
    [self.navigationController pushViewController:itemViewController animated:YES];
    [itemViewController release];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Drop";
}

@end


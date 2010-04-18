//
//  ItemViewController.m
//  NetHack
//
//  Created by dirk on 2/8/10.
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

#import "ItemViewController.h"
#import "NhObject.h"
#import "NhCommand.h"
#import "Action.h"
#import "NhInventory.h"
#import "MainViewController.h"

@implementation ItemViewController

@synthesize item;
@synthesize inventory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		actions = [[NSMutableArray alloc] init];
    }
    return self;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (item.inventoryLetter != '-') {
		titleLabel.text = [NSString stringWithFormat:@"%c - %@", item.inventoryLetter, item.title];
	} else {
		titleLabel.text = item.title;
	}
	detailLabel.text = item.detail;
}

- (NhCommand *)dropOneCommand {
	return [NhCommand commandWithObject:item title:"Drop 1" keys:"d1"];
}

- (NhCommand *)dropExceptOneCommand {
	if (item.amount > 2) {
		int dropAmount = item.amount-1;
		char cmd[10];
		sprintf(cmd, "d%d", dropAmount);
		char title[15];
		sprintf(title, "Drop %d", dropAmount);
		return [NhCommand commandWithObject:item title:title keys:cmd];
	}
	return nil;
}

- (void)addAction:(NhCommand *)cmd {
	if (cmd) {
		[actions addObject:cmd];
	}
}

- (void)setItem:(NhObject *)i {
	if (i != item) {
		[item release];
		item = [i retain];
	}
	
	if (item.object) {
		// worn items can't be dropped except for wielded or alternative weapons
		// so drop is only allowed on items not worn, except for wielded/alternate/quivered ...
		if (!item.object->owornmask || item.object->owornmask & W_WEP || item.object->owornmask & W_SWAPWEP ||
			item.object->owornmask & W_QUIVER) {
			[self addAction:[self dropOneCommand]];
			[self addAction:[self dropExceptOneCommand]];
			[actions addObject:[NhCommand commandWithObject:item title:"Throw" key:'t']];
		}

		switch (item.object->oclass) {
			case WEAPON_CLASS:
				if (item.object->owornmask & W_WEP) {
					[actions addObject:[NhCommand commandWithTitle:"Unwield" keys:"w-"]];
					[actions addObject:[NhCommand commandWithTitle:"Force" key:M('f')]];
					[actions addObject:[NhCommand commandWithTitle:"Set as alternative Weapon" key:'x']];
				} else {
					[actions addObject:[NhCommand commandWithObject:item title:"Wield" key:'w']];
					[actions addObject:[NhCommand commandWithObject:item title:"Quiver" key:'Q']];
				}
				[actions addObject:[NhCommand commandWithObject:item title:"Apply" key:'a']];
				if ([inventory containsObjectClass:POTION_CLASS] ||
					IS_FOUNTAIN(levl[u.ux][u.uy].typ) || IS_SINK(levl[u.ux][u.uy].typ)) {
					[actions addObject:[NhCommand commandWithObject:item title:"Dip" key:M('d')]];
				}
				[actions addObject:[NhCommand commandWithObject:item title:"Engrave" key:'E']];
				break;
			case ARMOR_CLASS:
				if (item.object->owornmask & W_ARMOR) {
					if (inventory.numberOfWornArmor > 1) {
						[actions addObject:[NhCommand commandWithObject:item title:"Take off" key:'T']];
					} else {
						[actions addObject:[NhCommand commandWithTitle:"Take off" key:'T']];
					}
				} else {
					//todo this might clash if not possible to wear (e.g., cloak)
					[actions addObject:[NhCommand commandWithObject:item title:"Wear" key:'W']];
				}
				break;
			case WAND_CLASS:
				[actions addObject:[NhCommand commandWithObject:item title:"Apply" key:'a']];
				[actions addObject:[NhCommand commandWithObject:item title:"Zap" key:'z']];
				[actions addObject:[NhCommand commandWithObject:item title:"Engrave" key:'E']];
				break;
			case TOOL_CLASS:
				[actions addObject:[NhCommand commandWithObject:item title:"Apply" key:'a']];
				if ([inventory containsObjectClass:POTION_CLASS]) {
					[actions addObject:[NhCommand commandWithObject:item title:"Dip" key:M('d')]];
				}
				switch (item.object->otyp) {
					case MAGIC_MARKER:
						[actions addObject:[NhCommand commandWithObject:item title:"Engrave" key:'E']];
						break;
					case BRASS_LANTERN:
					case OIL_LAMP:
					case MAGIC_LAMP:
						[actions addObject:[NhCommand commandWithObject:item title:"Rub" key:M('r')]];
						break;
					case TOWEL:
						if (item.object->owornmask & W_TOOL) {
							if (inventory.numberOfPutOnItems > 1) {
								[actions addObject:[NhCommand commandWithObject:item title:"Remove" key:'R']];
							} else {
								[actions addObject:[NhCommand commandWithTitle:"Remove" key:'R']];
							}
						} else {
							[actions addObject:[NhCommand commandWithObject:item title:"Put on" key:'P']];
						}
						break;
				}
				if (item.object->owornmask & W_WEP) {
					[actions addObject:[NhCommand commandWithTitle:"Unwield" keys:"w-"]];
				} else {
					[actions addObject:[NhCommand commandWithObject:item title:"Wield" key:'w']];
				}
				break;
			case FOOD_CLASS:
				[actions addObject:[NhCommand commandWithObject:item title:"Eat" key:'e']];
				if (item.object->otyp == CORPSE) {
					if (item.object->owornmask & W_WEP) {
						[actions addObject:[NhCommand commandWithTitle:"Unwield" keys:"w-"]];
					} else {
						[actions addObject:[NhCommand commandWithObject:item title:"Wield" key:'w']];
					}
				}
				break;
			case RING_CLASS:
			case AMULET_CLASS:
				if (item.object->owornmask & W_RING || item.object->owornmask & W_AMUL) {
					if (inventory.numberOfPutOnItems > 1) {
						[actions addObject:[NhCommand commandWithObject:item title:"Remove" key:'R']];
					} else {
						[actions addObject:[NhCommand commandWithTitle:"Remove" key:'R']];
					}
				} else {
					[actions addObject:[NhCommand commandWithObject:item title:"Put on" key:'P']];
				}
				[actions addObject:[NhCommand commandWithObject:item title:"Engrave" key:'E']];
				break;
			case SPBOOK_CLASS:
			case SCROLL_CLASS:
				[actions addObject:[NhCommand commandWithObject:item title:"Read" key:'r']];
				if ([inventory containsObjectClass:POTION_CLASS] ||
					IS_FOUNTAIN(levl[u.ux][u.uy].typ) || IS_SINK(levl[u.ux][u.uy].typ)) {
					[actions addObject:[NhCommand commandWithObject:item title:"Dip" key:M('d')]];
				}
				break;
			case POTION_CLASS:
				[actions addObject:[NhCommand commandWithObject:item title:"Quaff" key:'q']];
				if ([inventory containsObjectClass:TOOL_CLASS] || [inventory containsObjectClass:WAND_CLASS]) {
					[actions addObject:[NhCommand commandWithObject:item title:"Apply" key:'a']];
				}
				if (IS_FOUNTAIN(levl[u.ux][u.uy].typ) || IS_SINK(levl[u.ux][u.uy].typ)) {
					[actions addObject:[NhCommand commandWithObject:item title:"Dip" key:M('d')]];
				}
				break;
			case GEM_CLASS:
				if (is_graystone(item.object)) {
					[actions addObject:[NhCommand commandWithObject:item title:"Rub" key:M('r')]];
				}
				[actions addObject:[NhCommand commandWithObject:item title:"Engrave" key:'E']];
				[actions addObject:[NhCommand commandWithObject:item title:"Quiver" key:'Q']];
				break;
		}
		char cmd[BUFSZ];
		sprintf(cmd, "%cn%c", M('n'), item.inventoryLetter);
		[actions addObject:[NhCommand commandWithTitle:"Name Class" keys:cmd]];
		sprintf(cmd, "%cy%c", M('n'), item.inventoryLetter);
		[actions addObject:[NhCommand commandWithTitle:"Name Item" keys:cmd]];
	} else {
		// special objects
		switch (item.inventoryLetter) {
			case '$':
				[self addAction:[self dropOneCommand]];
				[self addAction:[self dropExceptOneCommand]];
				[actions addObject:[NhCommand commandWithTitle:"Pay" key:'p']];
				break;
			case '-':
				[actions addObject:[NhCommand commandWithObject:item title:"Engrave" key:'E']];
				[actions addObject:[NhCommand commandWithObject:item title:"Wield" key:'w']];
				break;
			default:
				break;
		}
	}
}

- (void)dealloc {
	[actions release];
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:CellIdentifier] autorelease];
    }
    
	Action *action = [actions objectAtIndex:[indexPath row]];
	cell.textLabel.text = action.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Action *action = [actions objectAtIndex:[indexPath row]];
	[action invoke:nil];
	[self dismissModalViewControllerAnimated:NO];
}

@end

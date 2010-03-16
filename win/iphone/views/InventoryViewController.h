//
//  ObjectViewController.h
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

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "NhInventory.h"

@interface InventoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	
	IBOutlet UITableView *tv;
	NhInventory *inventory;
	IBOutlet UIBarButtonItem *pickupButton;
	
}

@property (nonatomic, readonly) UITableView *tableView;

- (void)updateInventory;
- (IBAction)editModeAction:(id)sender;
- (IBAction)dropAction:(id)sender;
- (IBAction)pickupAction:(id)sender;
- (IBAction)whatsHereAction:(id)sender;
- (IBAction)disrobeAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

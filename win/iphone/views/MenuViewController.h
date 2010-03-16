//
//  MenuViewController.h
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

@class NhMenuWindow;
@class ZObjectCache;
@class NhItem;

@interface MenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource> {

	NhMenuWindow *menuWindow;
	IBOutlet UITableView *tv;
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIBarItem *cancelButton;
	IBOutlet UIBarItem *invertSelectionButton;
	IBOutlet UIBarItem *selectAllButton;
	IBOutlet UIBarItem *selectNoneButton;
	IBOutlet UIBarItem *okButton;
	
	ZObjectCache *sliderItems;

}

@property (nonatomic, retain) NhMenuWindow *menuWindow;
@property (nonatomic, readonly) UITableView *tableView;

- (void)updateCell:(UITableViewCell *)cell withItem:(NhItem *)item atIndexPath:(NSIndexPath *)indexPath ;

// button actions

- (IBAction)cancelButton:(id)sender;
- (IBAction)invertSelectionButton:(id)sender;
- (IBAction)selectAllButton:(id)sender;
- (IBAction)selectNoneButton:(id)sender;
- (IBAction)okButton:(id)sender;

@end

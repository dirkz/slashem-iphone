//
//  TileSetViewController.m
//  NetHack
//
//  Created by Dirk Zimmermann on 2/24/10.
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

#import "TileSetViewController.h"
#import "TileSet.h"
#import "AsciiTileSet.h"
#import "MainViewController.h"
#import "NhWindow.h"
#import "NhMapWindow.h"
#import "winiphone.h"

@implementation TileSetViewController

@synthesize tableView = tv;

#pragma mark -
#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		NSString *filename = [[NSBundle mainBundle] pathForResource:@"tilesets" ofType:@"plist"];
		tilesets = [[NSArray alloc] initWithContentsOfFile:filename];
    }
    return self;
}

- (IBAction)cancelAction:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return tilesets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *dict = [tilesets objectAtIndex:indexPath.row];
	NSString *title = [TileSet titleForTilesetDictionary:dict];
	NSString *author = [dict objectForKey:@"author"];
	cell.textLabel.text = title;
	if (author) {
		cell.detailTextLabel.text = author;
	}
	
	if ([title isEqual:[[TileSet instance] title]]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [tilesets objectAtIndex:indexPath.row];
	TileSet *tileSet = [TileSet tileSetFromDictionary:dict];
	[TileSet setInstance:tileSet];
	[[MainViewController instance] displayWindow:[NhWindow mapWindow]];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[TileSet titleForTilesetDictionary:dict] forKey:kNetHackTileSet];
	[self dismissModalViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[tilesets release];
    [super dealloc];
}

@end


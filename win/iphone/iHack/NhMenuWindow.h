//
//  NhMenuWindow.h
//  SlashEM
//
//  Created by dirk on 1/4/10.
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

#import "hack.h"

#import <Foundation/Foundation.h>
#import "NhWindow.h"

@class NhItemGroup;
@class NhItem;

@interface NhMenuWindow : NhWindow {
	
	NSMutableArray *itemGroups;
	NhItemGroup *currentItemGroup;
	int how;
	NSMutableArray *selected;
	NSString *prompt;
	
}

@property (nonatomic, readonly) NSArray *itemGroups;
@property (nonatomic, readonly) NhItemGroup *currentItemGroup;
@property (nonatomic, assign) int how;
@property (nonatomic, readonly) NSMutableArray *selected;
@property (nonatomic, copy) NSString *prompt;

- (void) addItemGroup:(NhItemGroup *)g;
- (NhItem *)itemAtIndexPath:(NSIndexPath *)indexPath;
// for UI
- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)startMenu;

@end

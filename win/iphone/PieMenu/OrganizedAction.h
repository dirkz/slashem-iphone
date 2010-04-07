//
//  OrganizedAction.h
//  SlashEM
//
//  Created by Jeremy Lyman on 3/12/10.
//  Copyright 2010 Jeremy Lyman. All rights reserved.
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

#import <Foundation/Foundation.h>

#define kMaxNumberOfItems   7

@interface OrganizedAction : NSObject {
	NSMutableDictionary *allActions;
	NSMutableDictionary *doorActions;
	NSMutableDictionary *mainActions;
	NSMutableDictionary *magicActions;
	NSMutableDictionary *objectActions;
	NSMutableDictionary *otherActions;
	NSMutableDictionary *restActions;
}

@property (nonatomic, retain) NSMutableDictionary *allActions;
@property (nonatomic, retain) NSMutableDictionary *doorActions;
@property (nonatomic, retain) NSMutableDictionary *mainActions;
@property (nonatomic, retain) NSMutableDictionary *magicActions;
@property (nonatomic, retain) NSMutableDictionary *objectActions;
@property (nonatomic, retain) NSMutableDictionary *otherActions;
@property (nonatomic, retain) NSMutableDictionary *restActions;

- (id) init;
- (void) organizeDict:(NSDictionary *)unsortedDict;

@end

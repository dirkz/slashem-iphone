//
//  NhCommand.h
//  SlashEM
//
//  Created by dirk on 1/13/10.
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

#import <Foundation/Foundation.h>
#import "Action.h"
#import "winiphone.h"

#ifndef M
# ifndef NHSTDC
#  define M(c)		(0x80 | (c))
# else
#  define M(c)		((c) - 128)
# endif /* NHSTDC */
#endif
#ifndef C
#define C(c)		(0x1f & (c))
#endif

#define kDungeon (@"Dungeon")
#define kFloor (@"Floor")
#define kMisc (@"Misc")
#define kInventory (@"Inventory")
#define kInternal (@"Internal")

@class NhObject;

@interface NhCommand : Action {
	
	char *keys;

}

@property (nonatomic, readonly) const char *keys;

+ (id)commandWithTitle:(const char *)t keys:(const char *)c;
+ (id)commandWithTitle:(const char *)t key:(char)c;
+ (id)commandWithObject:(NhObject *)object title:(const char *)t key:(char)c;
+ (id)commandWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds;
+ (id)commandWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds direction:(const char *)dir;

// the possible categories of actions/commands
+ (NSArray *)categories;

+ (void)addCommand:(NhCommand *)cmd toCommands:(NSMutableDictionary *)commands key:(NSString *)key;

// all commands possible at this stage, sorted by category
+ (NSDictionary *)currentCommands;

// all commands possible at this stage, flat array
+ (NSArray *)allCurrentCommands;

// all commands possible for an adjacent position, flat array
+ (NSArray *)allCommandsForAdjacentTile:(coord)tp;

// direction commands
+ (NSArray *)directionCommands;

- (id)initWithTitle:(const char *)t keys:(const char *)c;
- (id)initWithTitle:(const char *)t key:(char)c;
- (id)initWithObject:(NhObject *)object title:(const char *)t key:(char)c;
- (id)initWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds;
- (id)initWithObject:(NhObject *)object title:(const char *)t keys:(const char *)cmds direction:(const char *)dir;

@end

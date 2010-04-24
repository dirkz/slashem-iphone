//
//  NhCharInfo.h
//  NetHack
//
//  Created by Dirk Zimmermann on 2/22/10.
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

@interface NhStatus : NSObject {
	
	char strength[5];
	int dexterity;
	int constitution;
	int intelligence;
	int wisdom;
	int charisma;
	char alignment[10];
	int dlvl; // dungeon level
	int money;
	int hitpoints;
	int maxHitpoints;
	int power;
	int maxPower;
	int ac;
	int xlvl; // experience level
	char status[20];
	int turn;
	
	/** flag whether status has even updated once */
	BOOL updated;

}

@property (nonatomic, readonly) char *strength;
@property (nonatomic, readonly) int dexterity;
@property (nonatomic, readonly) int constitution;
@property (nonatomic, readonly) int intelligence;
@property (nonatomic, readonly) int wisdom;
@property (nonatomic, readonly) int charisma;
@property (nonatomic, readonly) char *alignment;
@property (nonatomic, readonly) int dlvl;
@property (nonatomic, readonly) int money;
@property (nonatomic, readonly) int hitpoints;
@property (nonatomic, readonly) int maxHitpoints;
@property (nonatomic, readonly) int power;
@property (nonatomic, readonly) int maxPower;
@property (nonatomic, readonly) int ac;
@property (nonatomic, readonly) int xlvl;
@property (nonatomic, readonly) char *status;
@property (nonatomic, readonly) int turn;
@property (nonatomic, readonly) NSArray *messages;

+ (id)status;

- (void)update;

@end

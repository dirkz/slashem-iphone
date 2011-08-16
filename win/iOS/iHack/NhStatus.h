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
	uint dexterity;
	uint constitution;
	uint intelligence;
	uint wisdom;
	uint charisma;
	char alignment[10];
	uint dlvl; // dungeon level
	uint money;
	uint hitpoints;
	uint maxHitpoints;
	uint power;
	uint maxPower;
	int ac;
	uint xlvl; // experience level
	char status[20];
	uint turn;
	char level[10];
	uint hungryState;
	char hunger[10];
	
	/** flag whether status has updated at least once */
	BOOL updatedOnce;

}

@property (nonatomic, readonly) char *strength;
@property (nonatomic, readonly) uint dexterity;
@property (nonatomic, readonly) uint constitution;
@property (nonatomic, readonly) uint intelligence;
@property (nonatomic, readonly) uint wisdom;
@property (nonatomic, readonly) uint charisma;
@property (nonatomic, readonly) char *alignment;
@property (nonatomic, readonly) uint dlvl;
@property (nonatomic, readonly) uint money;
@property (nonatomic, readonly) uint hitpoints;
@property (nonatomic, readonly) uint maxHitpoints;
@property (nonatomic, readonly) uint power;
@property (nonatomic, readonly) uint maxPower;
@property (nonatomic, readonly) int ac;
@property (nonatomic, readonly) uint xlvl;
@property (nonatomic, readonly) char *status;
@property (nonatomic, readonly) uint turn;
@property (nonatomic, readonly) NSArray *messages;
@property (nonatomic, readonly) BOOL updatedOnce;
@property (nonatomic, readonly) char *level;
@property (nonatomic, readonly) char *hunger;
@property (nonatomic, readonly) uint hungryState;

+ (id)status;

- (void)update;

@end

//
//  NhCharInfo.m
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

#import "NhCharInfo.h"

#include "hack.h"

extern const char *hu_stat[];	/* defined in eat.c */

extern const char * const enc_stat[];

@implementation NhCharInfo

@synthesize strength;
@synthesize dexterity;
@synthesize constitution;
@synthesize intelligence;
@synthesize wisdom;
@synthesize charisma;
@synthesize alignment;
@synthesize dlvl;
@synthesize money;
@synthesize hitpoints;
@synthesize maxHitpoints;
@synthesize power;
@synthesize maxPower;
@synthesize ac;
@synthesize xlvl;
@synthesize status;
@synthesize turn;

+ (id)info {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	if (self = [super init]) {
		if (ACURR(A_STR) > 18) {
			if (ACURR(A_STR) > STR18(100)) {
				strength = ACURR(A_STR)-100; //Sprintf(nb = eos(nb),"St:%2d ",ACURR(A_STR)-100);
			} else if (ACURR(A_STR) < STR18(100)) {
				strength = 18 + (ACURR(A_STR)-18)/100; //Sprintf(nb = eos(nb), "St:18/%02d ",ACURR(A_STR)-18);
			} else {
				strength = 18.99f; //Sprintf(nb = eos(nb),"St:18/** ");
			}
		} else {
			strength = ACURR(A_STR); //Sprintf(nb = eos(nb), "St:%-1d ",ACURR(A_STR));
		}
		dexterity = ACURR(A_DEX);
		constitution = ACURR(A_CON);
		intelligence = ACURR(A_INT);
		wisdom = ACURR(A_WIS);
		charisma = ACURR(A_CHA);
		alignment = (u.ualign.type == A_CHAOTIC) ? @"Chaotic" : (u.ualign.type == A_NEUTRAL) ? @"Neutral" : @"Lawful";
		dlvl = depth(&u.uz);
		money = u.ugold;
		hitpoints = Upolyd ? u.mh : u.uhp;
		maxHitpoints = Upolyd ? u.mhmax : u.uhpmax;
		power = u.uen;
		maxPower = u.uenmax;
		ac = u.uac;
		if (Upolyd) {
			xlvl = mons[u.umonnum].mlevel;
		} else {
			xlvl = u.ulevel;
		}
		turn = moves;
		
		char cStatus[80];
		strcpy(cStatus, hu_stat[u.uhs]);
		if (Confusion) {
			strcat(cStatus, " Conf");
		}
		if (Sick) {
			if (u.usick_type & SICK_VOMITABLE) {
				strcat(cStatus, " FoodPois");
			}
			if (u.usick_type & SICK_NONVOMITABLE) {
				strcat(cStatus, " Ill");
			}
		}
		if (Blind) {
			strcat(cStatus, " Blind");
		}
		if (Stunned) {
			strcat(cStatus, " Stun");
		}
		if (Hallucination) {
			strcat(cStatus, " Hallu");
		}
		if (Slimed) {
			strcat(cStatus, " Slime");
		}
		int cap = near_capacity();
		if (cap > UNENCUMBERED) {
			strcat(cStatus, enc_stat[cap]);
		}
		status = [[NSString alloc] initWithCString:cStatus encoding:NSASCIIStringEncoding];
	}
	return self;
}

- (NSString *)description {
	NSString *bot1 = [NSString stringWithFormat:@"Str:%3.2f Dx:%d Con:%d Int:%d Wis:%d Cha:%d %@ Dlvl:%d",
					  strength, dexterity, constitution, intelligence, wisdom, charisma, alignment, dlvl];
	NSString *bot2 = [NSString stringWithFormat:@"$%d Hp:%d/%d Pw:%d/%d AC:%d XP:%d T:%d %@",
					  money, hitpoints, maxHitpoints, power, maxPower, ac, xlvl, turn, status];
	return [NSString stringWithFormat:@"%@\n%@", bot1, bot2];
}

- (void)dealloc {
	[status release];
	[super dealloc];
}

@end

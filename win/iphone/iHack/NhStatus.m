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

#import "NhStatus.h"

#include "hack.h"

extern const char *hu_stat[];	/* defined in eat.c */

extern const char * const enc_stat[];

@implementation NhStatus

@synthesize dexterity;
@synthesize constitution;
@synthesize intelligence;
@synthesize wisdom;
@synthesize charisma;
@synthesize dlvl;
@synthesize money;
@synthesize hitpoints;
@synthesize maxHitpoints;
@synthesize power;
@synthesize maxPower;
@synthesize ac;
@synthesize xlvl;
@synthesize turn;

+ (id)status {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (char *)strength {
	return strength;
}

- (char *)alignment {
	return alignment;
}

- (char *)status {
	return status;
}

- (NSString *)description {
	return [[self messages] componentsJoinedByString:@"\n"];
}

- (NSArray *)messages {
	if (!updated) {
		return nil;
	}
	char level[10];
	describe_level(level, false);
	size_t last = strlen(level)-1;
	while (level[last] == ' ') {
		level[last] = '\0';
		last = strlen(level)-1;
	}
	NSString *bot1 = [NSString stringWithFormat:@"Str:%s Dx:%d Con:%d Int:%d Wis:%d Cha:%d %s",
					  strength, dexterity, constitution, intelligence, wisdom, charisma, alignment];
	NSString *bot2 = [NSString stringWithFormat:@"%s $%d Hp:%d/%d Pw:%d/%d AC:%d XP:%d T:%d %s",
					  level, money, hitpoints, maxHitpoints, power, maxPower, ac, xlvl, turn, status];
	return [NSArray arrayWithObjects:bot1, bot2, nil];
}

- (void)update {
	if (program_state.gameover || !program_state.something_worth_saving) {
		return;
	}
	updated = YES;
	if (ACURR(A_STR) > 18) {
		if (ACURR(A_STR) > STR18(100)) {
			sprintf(strength, "%2d", ACURR(A_STR)-100); //Sprintf(nb = eos(nb),"St:%2d ",ACURR(A_STR)-100);
		} else if (ACURR(A_STR) < STR18(100)) {
			sprintf(strength, "18/%2d", ACURR(A_STR)-18/100); //Sprintf(nb = eos(nb), "St:18/%02d ",ACURR(A_STR)-18);
		} else {
			sprintf(strength, "18/**"); //Sprintf(nb = eos(nb),"St:18/** ");
		}
	} else {
		sprintf(strength, "%-1d", ACURR(A_STR)); //Sprintf(nb = eos(nb), "St:%-1d ",ACURR(A_STR));
	}
	dexterity = ACURR(A_DEX);
	constitution = ACURR(A_CON);
	intelligence = ACURR(A_INT);
	wisdom = ACURR(A_WIS);
	charisma = ACURR(A_CHA);
	strcpy(alignment,  (u.ualign.type == A_CHAOTIC) ? "Chaotic" : (u.ualign.type == A_NEUTRAL) ? "Neutral" : "Lawful");
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
	
	strcpy(status, hu_stat[u.uhs]);
	// if first char is space this is empty
	if (status[0] == ' ') {
		status[0] = '\0';
	}
	if (Confusion) {
		strcat(status, " Conf");
	}
	if (Sick) {
		if (u.usick_type & SICK_VOMITABLE) {
			strcat(status, " FoodPois");
		}
		if (u.usick_type & SICK_NONVOMITABLE) {
			strcat(status, " Ill");
		}
	}
	if (Blind) {
		strcat(status, " Blind");
	}
	if (Stunned) {
		strcat(status, " Stun");
	}
	if (Hallucination) {
		strcat(status, " Hallu");
	}
	if (Slimed) {
		strcat(status, " Slime");
	}
	int cap = near_capacity();
	if (cap > UNENCUMBERED) {
		strcat(status, enc_stat[cap]);
	}

	if (status[0] == ' ') {
		char tmp[strlen(status)+1];
		strcpy(tmp, status+1);
		strcpy(status, tmp);
	}
}

- (void)dealloc {
	[super dealloc];
}

@end

//
//  PieMenuItemOrganization.m
//  SlashEM
//
//  Created by Jeremy Lyman on 3/12/10.
//  Copyright 2010 Lost Creatures. All rights reserved.
//

#import "OrganizedAction.h"
#import "NhCommand.h"
#import "CmdKeyEnum.h"


@implementation OrganizedAction

@synthesize allActions;
@synthesize doorActions;
@synthesize mainActions;
@synthesize magicActions;
@synthesize objectActions;
@synthesize	otherActions;
@synthesize restActions;

- (NSString*) description {
	return [NSString stringWithFormat:@"allActions: %@\ndoorActions: %@\nmainActions: %@\nmagicActions: %@\nobjectActions: %@\notherActions: %@\nrestActions: %@",
			allActions, doorActions, mainActions, magicActions, objectActions, otherActions, restActions];
}

- (id) init {
	allActions = [[NSMutableDictionary alloc] initWithCapacity:kMaxNumberOfItems];
	doorActions = [[NSMutableDictionary alloc] initWithCapacity:kMaxNumberOfItems];
	mainActions = [[NSMutableDictionary alloc] initWithCapacity:kMaxNumberOfItems];
	magicActions = [[NSMutableDictionary alloc] initWithCapacity:kMaxNumberOfItems];
	objectActions = [[NSMutableDictionary alloc] initWithCapacity:kMaxNumberOfItems];
	otherActions = [[NSMutableDictionary alloc] initWithCapacity:kMaxNumberOfItems];
	restActions = [[NSMutableDictionary alloc] initWithCapacity:kMaxNumberOfItems];
	return self;
}

- (void)dealloc {
	[allActions release];
	[doorActions release];
	[mainActions release];
	[magicActions release];
	[objectActions release];
	[otherActions release];
	[restActions release];
    [super dealloc];
}

- (void) organizeDict:(NSDictionary *)unsortedDict {
	
	//	NSEnumerator *enumerator = [unsortedDict keyEnumerator];
	//	id key;
	
	
	//while ((key = [enumerator nextObject])) {
	for (id key in unsortedDict) {
		
		[allActions setObject:[unsortedDict objectForKey:key] forKey:key];
		
		if (![key isKindOfClass:[NSNumber class]]) {
			NSLog(@"Not a number!?!?");
			continue;
		}
		// Whats faster... enum casting to NSNumber or string comparison
		if ([key intValue] == kKick		|| 
			[key intValue] == kRest		||
			[key intValue] == kUp		|| 
			[key intValue] == kDown		||
			[key intValue] == kOffer	|| 
			[key intValue] == kQuaff	||
			[key intValue] == kDip		||
			[key intValue] == kSit		||
			[key intValue] == kFire)
			[mainActions setObject:[unsortedDict objectForKey:key] forKey:key];
		else if (
				 [key intValue] == kCast	|| 
				 [key intValue] == kEWord	||
				 [key intValue] == kRead)
			[magicActions setObject:[unsortedDict objectForKey:key] forKey:key];
		else if (
				 [key intValue] == kPickUp		|| 
				 [key intValue] == kEat			||
				 [key intValue] == kObjForce	|| 
				 [key intValue] == kObjApply	||
				 [key intValue] == kInvApply    ||
				 [key intValue] == kLoot)
			[objectActions setObject:[unsortedDict objectForKey:key] forKey:key];
		else if (
				 [key intValue] == kOpen		|| 
				 [key intValue] == kClose		||
				 [key intValue] == kDoorApply	|| 
				 [key intValue] == kDoorForce   ||
				 [key intValue] == kKickDoor)
			[doorActions setObject:[unsortedDict objectForKey:key] forKey:key];
		else if (
				 [key intValue] == kUntrap		||
				 [key intValue] == kIDTrap		||
				 [key intValue] == kObjChat		||
				 [key intValue] == kPay			||
				 [key intValue] == kReadHere	||
				 [key intValue] == kPray)
			[otherActions setObject:[unsortedDict objectForKey:key] forKey:key];
		else if (
				 [key intValue] == kRest19		||
				 [key intValue] == kRest99)
			[restActions setObject:[unsortedDict objectForKey:key] forKey:key];
	}
}

@end

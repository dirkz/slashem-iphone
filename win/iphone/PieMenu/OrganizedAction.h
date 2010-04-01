//
//  OrganizedAction.h
//  SlashEM
//
//  Created by Jeremy Lyman on 3/12/10.
//  Copyright 2010 Lost Creatures. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMaxNumberOfItems   7

@interface OrganizedAction : NSObject {
	NSMutableDictionary *allActions;
	NSMutableDictionary *doorActions;
	NSMutableDictionary *mainActions;
	NSMutableDictionary *magicActions;
	NSMutableDictionary *objectActions;
}

@property (nonatomic, retain) NSMutableDictionary *allActions;
@property (nonatomic, retain) NSMutableDictionary *doorActions;
@property (nonatomic, retain) NSMutableDictionary *mainActions;
@property (nonatomic, retain) NSMutableDictionary *magicActions;
@property (nonatomic, retain) NSMutableDictionary *objectActions;

- (id) init;
- (void) organizeDict:(NSDictionary *)unsortedDict;

@end

//
//  Action.h
//  NetHack
//
//  Created by dirk on 2/4/10.
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

@interface Action : NSObject {
	
	NSString *title;
	NSMutableArray *invocations;

}

@property (nonatomic, readonly) NSString *title;

+ (id)actionWithTitle:(NSString *)t target:(id)target action:(SEL)action arg:(id)arg;
+ (id)actionWithTitle:(NSString *)t target:(id)target action:(SEL)action;

- (id)initWithTitle:(NSString *)t;

- (void)invoke:(id)sender;
- (void)addTarget:(id)target action:(SEL)action arg:(id)arg;
- (void)addInvocation:(NSInvocation *)inv;

@end

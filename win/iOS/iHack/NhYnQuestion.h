//
//  NhYnQuestion.h
//  SlashEM
//
//  Created by dirk on 12/30/09.
//  Copyright 2009 Dirk Zimmermann. All rights reserved.
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

@interface NhYnQuestion : NSObject {
	
	NSString *question;
	const char *choices;
	NSString *overriddenChoices;

}

@property (nonatomic, readonly) NSString *question;
@property (nonatomic, readonly) const char *choices;

- (id)initWithQuestion:(const char *)q choices:(const char *)ch default:(int)def;
- (void)overrideChoices:(NSString *)ch;

@end

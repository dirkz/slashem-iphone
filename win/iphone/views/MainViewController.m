//
//  MainViewController.m
//  NetHack
//
//  Created by dirk on 2/1/10.
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

#import "MainViewController.h"
#import "NhYnQuestion.h"
#import "NSString+Z.h"
#import "NhEventQueue.h"
#import "NhWindow.h"
#import "NhMenuWindow.h"
#import "NhEvent.h"
#import "NhCommand.h"
#import "CommandButtonItem.h"
#import "ActionViewController.h"
#import "PopoverNhCommand.h"
#import "InventoryViewController.h"
#import "MenuViewController.h"
#import "TextInputController.h"
#import "TextViewController.h"
#import "OptionsViewController.h"
#import "ExtendedCommandsController.h"
#import "NhTextInputEvent.h"
#import "MessageView.h"
#import "MapView.h"
#import "TileSetViewController.h"
#import "ToolsViewController.h"

#import "winipad.h" // ipad_getpos etc.

#include "hack.h" // BUFSZ etc.

static MainViewController* instance;

@implementation MainViewController

+ (MainViewController *)instance {
	return instance;
}

- (void)awakeFromNib {
	[super awakeFromNib]; // responsible for viewDidLoad
	instance = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// no animation the first time
	static BOOL animated = NO;
	[self clipAroundAnimated:animated];
	if (!animated) {
		animated = YES;
	}
}

- (void)viewDidLoad {
	[mapScrollView setContentSize:mapView.bounds.size];
}

- (void)releaseIfDefined:(id *)thing {
	if (*thing) {
		[*thing release];
		*thing = nil;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark menus/actions

- (void)inventoryMenuAction:(id)sender {
	[self resizePopover:self.inventoryPopoverController];
	[self.inventoryPopoverController presentPopoverFromBarButtonItem:sender
											permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)infoMenuAction:(id)sender {
	NSArray *commands = [NSArray arrayWithObjects:
						 [NhCommand commandWithTitle:"What's here" key:':'],
						 [NhCommand commandWithTitle:"What is" key:';'],
						 [NhCommand commandWithTitle:"Discoveries" key:'\\'],
						 [NhCommand commandWithTitle:"Help" key:'?'],
						 [NhCommand commandWithTitle:"Options" key:'O'],
						 [NhCommand commandWithTitle:"Toggle Autopickup" key:'@'],
						 nil];
	self.actionViewController.actions = commands;

	// dismiss popover
	NSInvocation *inv = [self dismissPopoverInvocation:self.actionPopoverController];
	for (Action *a in commands) {
		[a addInvocation:inv];
	}

	[self resizePopover:self.actionPopoverController];
	[self.actionPopoverController presentPopoverFromBarButtonItem:sender
										 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)tilesetMenuAction:(id)sender {
	TileSetViewController *tilesetViewController = [[TileSetViewController alloc]
													initWithStyle:UITableViewStylePlain];
	UIPopoverController *tilesetPopoverController = [[UIPopoverController alloc]
													 initWithContentViewController:tilesetViewController];
	[self resizePopover:tilesetPopoverController];
	[tilesetPopoverController presentPopoverFromBarButtonItem:sender
									 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)toolsMenuAction:(id)sender {
	ToolsViewController *toolsViewController = [[ToolsViewController alloc]
												initWithStyle:UITableViewStylePlain];
	UIPopoverController *toolsPopoverController = [[UIPopoverController alloc]
												   initWithContentViewController:toolsViewController];
	toolsViewController.popover = toolsPopoverController;
	[self resizePopover:toolsPopoverController];
	[toolsPopoverController presentPopoverFromBarButtonItem:sender
									 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)wizardMenuAction:(id)sender {
	NSArray *commands = [NSArray arrayWithObjects:
						 [PopoverNhCommand commandWithTitle:"Magic Mapping" key:C('f') popover:self.actionPopoverController],
						 [PopoverNhCommand commandWithTitle:"Wish" key:C('w') popover:self.actionPopoverController],
						 nil];
	self.actionViewController.actions = commands;
	[self resizePopover:self.actionPopoverController];
	[self.actionPopoverController presentPopoverFromBarButtonItem:sender
										 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)optionsViewAction:(id)sender {
	[self resizePopover:self.optionsPopoverController];
	[self.optionsPopoverController presentPopoverFromBarButtonItem:sender
										  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)buyIdAction:(id)sender {
	NSLog(@"buying id");
}

- (void)shopMenuAction:(id)sender {
	NSArray *commands = [NSArray arrayWithObjects:
						 [Action actionWithTitle:@"Blessed scroll of ID" target:self action:@selector(buyIdAction:) arg:nil],
						 nil];
	self.actionViewController.actions = commands;

	// dismiss popover
	NSInvocation *inv = [self dismissPopoverInvocation:self.actionPopoverController];
	for (Action *a in commands) {
		[a addInvocation:inv];
	}
	[self resizePopover:self.actionPopoverController];
	[self.actionPopoverController presentPopoverFromBarButtonItem:sender
										 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (UIBarButtonItem *)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
	return [[[UIBarButtonItem alloc] initWithTitle:title
											 style:UIBarButtonItemStyleBordered target:target action:action] autorelease];
}

#pragma mark view controllers

- (UIPopoverController *)actionPopoverController {
	if (!actionPopoverController) {
		actionPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.actionViewController];
	}
	return actionPopoverController;
}

- (ActionViewController *)actionViewController {
	if (!actionViewController) {
		actionViewController = [[ActionViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	return actionViewController;
}

- (InventoryViewController *)inventoryViewController {
	if (!inventoryViewController) {
		inventoryViewController = [[InventoryViewController alloc] initWithNibName:@"InventoryViewController" bundle:nil];
	}
	return inventoryViewController;
}

- (UINavigationController *)inventoryNavigationController {
	return [[[UINavigationController alloc] initWithRootViewController:self.inventoryViewController] autorelease];
}

- (UIPopoverController *)inventoryPopoverController {
	if (!inventoryPopoverController) {
		inventoryPopoverController = [[UIPopoverController alloc]
									  initWithContentViewController:self.inventoryNavigationController];
	}
	return inventoryPopoverController;
}

- (MenuViewController *)menuViewController {
	if (!menuViewController) {
		menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
	}
	return menuViewController;
}

- (OptionsViewController *)optionsViewController {
	if (!optionsViewController) {
		optionsViewController = [[OptionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	}
	return optionsViewController;
}

- (UINavigationController *)optionsNavigationController {
	return [[[UINavigationController alloc] initWithRootViewController:self.optionsViewController] autorelease];
}

- (UIPopoverController *)optionsPopoverController {
	if (!optionsPopoverController) {
		optionsPopoverController = [[UIPopoverController alloc]
									initWithContentViewController:self.optionsNavigationController];
	}
	return optionsPopoverController;
}

#pragma mark window API

- (void)nhPoskey {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(nhPoskey) withObject:nil waitUntilDone:NO];
	} else {
		// build bottom toolbar
		UIBarButtonItem *spacer = nil;
		if (bottomToolbar.items.count == 1) {
			NSArray *items = bottomToolbar.items;
			spacer = [items objectAtIndex:0];
			NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:5];
			[toolbarItems addObject:[CommandButtonItem buttonWithAction:[NhCommand commandWithTitle:"Wait" key:'.']]];
			//[toolbarItems addObject:spacer];
			[toolbarItems addObject:[CommandButtonItem buttonWithAction:[NhCommand commandWithTitle:"Search" keys:"9s"]]];
			[toolbarItems addObject:[CommandButtonItem buttonWithAction:[NhCommand commandWithTitle:"Redo" key:C('a')]]];
			[toolbarItems addObject:[self buttonWithTitle:@"Inv" target:self action:@selector(inventoryMenuAction:)]];
			[toolbarItems addObject:[CommandButtonItem buttonWithAction:[NhCommand commandWithTitle:"Fire" key:'f']]];
			[toolbarItems addObject:[CommandButtonItem buttonWithAction:[NhCommand commandWithTitle:"Alt" key:'x']]];
			[toolbarItems addObject:[CommandButtonItem buttonWithAction:[NhCommand commandWithTitle:"Cast" key:'Z']]];
			[toolbarItems addObject:[CommandButtonItem buttonWithAction:[NhCommand commandWithTitle:"Ext" key:'#']]];
			[toolbarItems addObject:[self buttonWithTitle:@"Info" target:self action:@selector(infoMenuAction:)]];
			[toolbarItems addObject:[self buttonWithTitle:@"Tilesets" target:self action:@selector(tilesetMenuAction:)]];
			[toolbarItems addObject:[self buttonWithTitle:@"Tools" target:self action:@selector(toolsMenuAction:)]];
			
#if 0 // online shop
			[toolbarItems addObject:[self buttonWithTitle:@"Shop" target:self action:@selector(shopMenuAction:)]];
#endif
			
			if (wizard) { // wizard mode
				[toolbarItems addObject:[self buttonWithTitle:@"Wiz" target:self action:@selector(wizardMenuAction:)]];
			}

#if 0 // test
			[toolbarItems addObject:[CommandButtonItem buttonWithAction:[NhCommand commandWithTitle:"Drop" key:'D']]];
#endif
			
			[bottomToolbar setItems:toolbarItems animated:YES];
		}
		
		if (!dummyTextField) {
			dummyTextField = [[UITextField alloc] initWithFrame:CGRectZero];
			dummyTextField.delegate = self;
			dummyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
			dummyTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			[self.view addSubview:dummyTextField];
			[dummyTextField release];
		}
		[self refreshAllViews];
	}
}

- (void)refreshAllViews {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(refreshAllViews) withObject:nil waitUntilDone:NO];
	} else {
		// hardware keyboard
		[dummyTextField becomeFirstResponder];
		[self refreshMessages];
	}
}

- (void)refreshMessages {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(refreshMessages) withObject:nil waitUntilDone:NO];
	} else {
		messageView.text = [[NhWindow messageWindow] text];
		messageView.messageWindow = [NhWindow messageWindow];
		NSArray *messages = [[NhWindow statusWindow] messages];
		if (messages && messages.count == 2) {
			statusView1.text = [messages objectAtIndex:0];
			statusView2.text = [messages objectAtIndex:1];
		}
	}
}

- (void)handleDirectionQuestion:(NhYnQuestion *)q {
	directionQuestion = YES;
	if (inventoryPopoverController && inventoryPopoverController.popoverVisible) {
		[inventoryPopoverController dismissPopoverAnimated:NO];
	}
}

// Parses the stuff in [] and returns the special characters like $-?* etc.
// examples:
// [$abcdf or ?*]
// [a or ?*]
// [- ab or ?*]
// [- or or ?*]
// [- a or ?*]
// [- a-cw-z or ?*]
// [- a-cW-Z or ?*]
- (void)parseYnChoices:(NSString *)lets specials:(NSString **)specials items:(NSString **)items {
	char cSpecials[BUFSZ];
	char cItems[BUFSZ];
	char *pSpecials = cSpecials;
	char *pItems = cItems;
	const char *pStr = [lets cStringUsingEncoding:NSASCIIStringEncoding];
	enum eState { start, inv, invInterval, end } state = start;
	char c, lastInv = 0;
	while (c = *pStr++) {
		switch (state) {
			case start:
				if (isalpha(c)) {
					state = inv;
					*pItems++ = c;
				} else if (!isalpha(c)) {
					if (c == ' ') {
						state = inv;
					} else {
						*pSpecials++ = c;
					}
				}
				break;
			case inv:
				if (isalpha(c)) {
					*pItems++ = c;
					lastInv = c;
				} else if (c == ' ') {
					state = end;
				} else if (c == '-') {
					state = invInterval;
				}
				break;
			case invInterval:
				if (isalpha(c)) {
					for (char a = lastInv+1; a <= c; ++a) {
						*pItems++ = a;
					}
					state = inv;
					lastInv = 0;
				} else {
					// never lands here
					state = inv;
				}
				break;
			case end:
				if (!isalpha(c) && c != ' ') {
					*pSpecials++ = c;
				}
				break;
			default:
				break;
		}
	}
	*pSpecials = 0;
	*pItems = 0;
	
	*specials = [NSString stringWithCString:cSpecials encoding:NSASCIIStringEncoding];
	*items = [NSString stringWithCString:cItems encoding:NSASCIIStringEncoding];
}

- (void)showYnQuestion:(NhYnQuestion *)q {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(showYnQuestion:) withObject:q waitUntilDone:NO];
	} else {
		if ([q.question containsString:@"direction"]) {
			[self handleDirectionQuestion:q];
		} else if (q.choices) {
			// simple YN question
			NSString *text = q.question;
			if (text && text.length > 0) {
				currentYnQuestion = q;
				UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Question" message:q.question
															   delegate:self cancelButtonTitle:nil otherButtonTitles:nil]
									  autorelease];
				const char *pStr = q.choices;
				while (*pStr) {
					[alert addButtonWithTitle:[NSString stringWithFormat:@"%c", *pStr]];
					pStr++;
				}
				[alert show];
			}
		} else {
			// very general question, could be everything
			NSString *args = [q.question substringBetweenDelimiters:@"[]"];
			BOOL questionMark = NO;
			if (args) {
				const char *pStr = [args cStringUsingEncoding:NSASCIIStringEncoding];
				while (*pStr) {
					if (*pStr++ == '?') {
						questionMark = YES;
					}
				}
			}
			if (questionMark) {
				[[NhEventQueue instance] addKey:'?'];
			} else {
				NSLog(@"unknown question %@", q.question);
			}
		}
	}
}

- (void)displayText:(NSString *)text blocking:(BOOL)blocking {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(displayText:) withObject:text waitUntilDone:NO];
	} else {
		TextViewController *textViewController = [[[TextViewController alloc]
												   initWithNibName:@"TextViewController" bundle:nil] autorelease];
		textViewController.modalPresentationStyle = UIModalPresentationFormSheet;
		textViewController.text = text;
		textViewController.blocking = blocking;
		[self presentModalViewController:textViewController animated:YES];
	}
}

- (void)displayWindow:(NhWindow *)w {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(displayWindow:) withObject:w waitUntilDone:NO];
		if (w.blocking && w != [NhWindow messageWindow]) {
			// ignore blocking main message window
			[[NhEventQueue instance] nextEvent];
		}
	} else {
		if (w == [NhWindow messageWindow]) {
			[self refreshMessages];
		} else if (w.type == NHW_MAP) {
			if (w.blocking) {
				//todo (though it seems to work)
			}
			[mapView setNeedsDisplay];
			[self.view setNeedsDisplay];
		} else if (w.type == NHW_MESSAGE || w.type == NHW_MENU || w.type == NHW_TEXT) {
			// display text
			[self displayText:w.text blocking:w.blocking];
		}
	}
}

- (void)showMenuWindow:(NhMenuWindow *)w {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(showMenuWindow:) withObject:w waitUntilDone:NO];
	} else {
		self.menuViewController.menuWindow = w;
		self.menuViewController.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentModalViewController:menuViewController animated:YES];
	}
}

- (void)clipAroundAnimated:(BOOL)animated {
	CGSize tileSize = mapView.tileSize;
	CGSize scrollSize = mapScrollView.bounds.size;
	CGPoint playerOffset = CGPointMake(clipX*tileSize.width-scrollSize.width/2,
									   clipY*tileSize.height-scrollSize.height/2);
	[mapScrollView setContentOffset:playerOffset animated:animated];
}

- (void)clipAround {
	[self clipAroundAnimated:NO];
}

- (void)clipAroundX:(int)x y:(int)y {
	clipX = x;
	clipY = y;
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(clipAround) withObject:nil waitUntilDone:NO];
	} else {
		[self clipAroundAnimated:NO];
	}
}

- (void)updateInventory {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(updateInventory) withObject:nil waitUntilDone:NO];
	} else {
		if (inventoryViewController) {
			[self.inventoryViewController updateInventory];
		}
	}
}

- (void)getLine {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(getLine) withObject:nil waitUntilDone:NO];
	} else {
		TextInputController *textInputController = [[TextInputController alloc]
													initWithNibName:@"TextInputController" bundle:nil];
		textInputController.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentModalViewController:textInputController animated:YES];
		[textInputController release];
	}
}

- (void)showExtendedCommands {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(showExtendedCommands) withObject:nil waitUntilDone:NO];
	} else {
		ExtendedCommandsController *extendedCommandsController = [[ExtendedCommandsController alloc]
																  initWithNibName:@"ExtendedCommandsController" bundle:nil];
		extendedCommandsController.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentModalViewController:extendedCommandsController animated:YES];
		[extendedCommandsController release];
	}
}

#pragma mark touch handling

- (int)keyFromDirection:(e_direction)d {
	static char keys[] = "kulnjbhy\033";
	return keys[d];
}

- (BOOL)isMovementKey:(char)k {
	if (isalpha(k)) {
		static char directionKeys[] = "kulnjbhy";
		char *pStr = directionKeys;
		char c;
		while (c = *pStr++) {
			if (c == k) {
				return YES;
			}
		}
	}
	return NO;
}

- (e_direction)directionFromKey:(char)k {
	switch (k) {
		case 'k':
			return kDirectionUp;
		case 'u':
			return kDirectionUpRight;
		case 'l':
			return kDirectionRight;
		case 'n':
			return kDirectionDownRight;
		case 'j':
			return kDirectionDown;
		case 'b':
			return kDirectionDownLeft;
		case 'h':
			return kDirectionLeft;
		case 'y':
			return kDirectionUpLeft;
	}
	return kDirectionMax;
}

- (CGRect)rectForCoord:(coord)c {
	CGRect r = [mapView rectForCoord:c];
	r = [self.view convertRect:r fromView:mapView];
	return r;
}

- (void)endDirectionQuestion {
	directionQuestion = NO;
}

- (void)handleMapTapTileX:(int)x y:(int)y forLocation:(CGPoint)p inView:(UIView *)view {
	//NSLog(@"tap on %d,%d (u %d,%d)", x, y, u.ux, u.uy);
	if (directionQuestion) {
		if (u.ux == x && u.uy == y) {
			// tap on self
			CGRect tapRect = [self rectForCoord:CoordMake(x,y)];
			NSArray *commands = [NhCommand directionCommands];
			self.actionViewController.actions = commands;
			// dismiss popover
			NSInvocation *dismissInv = [self dismissPopoverInvocation:self.actionPopoverController];
			for (Action *action in commands) {
				[action addInvocation:dismissInv];
				[action addTarget:self action:@selector(endDirectionQuestion) arg:nil];
			}
			[self resizePopover:self.actionPopoverController];
			[self.actionPopoverController presentPopoverFromRect:tapRect inView:self.view
										permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		} else {
			directionQuestion = NO;
			CGPoint delta = CGPointMake(x*32.0f-u.ux*32.0f, y*32.0f-u.uy*32.0f);
			delta.y *= -1;
			//NSLog(@"delta %3.2f,%3.2f", delta.x, delta.y);
			e_direction direction = [ZDirection directionFromEuclideanPointDelta:&delta];
			int key = [self keyFromDirection:direction];
			//NSLog(@"key %c", key);
			[[NhEventQueue instance] addKey:key];
		}
	} else if (!ipad_getpos) {
		if (u.ux == x && u.uy == y) {
			// tap on self
			CGRect tapRect = [self rectForCoord:CoordMake(x,y)];

			NSArray *commands = [NhCommand currentCommands];
			self.actionViewController.actions = commands;
			// dismiss popover
			NSInvocation *dismissInv = [self dismissPopoverInvocation:self.actionPopoverController];
			for (Action *action in commands) {
				[action addInvocation:dismissInv];
			}
			[self resizePopover:self.actionPopoverController];
			[self.actionPopoverController presentPopoverFromRect:tapRect inView:self.view
												 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		} else {
			coord delta = CoordMake(u.ux-x, u.uy-y);
			if (abs(delta.x) <= 1 && abs(delta.y) <= 1 ) {
				// tap on adjacent tile
				NSArray *commands = [NhCommand commandsForAdjacentTile:CoordMake(x, y)];
				if (commands.count > 0) {
					self.actionViewController.actions = commands;
					// dismiss popover
					NSInvocation *dismissInv = [self dismissPopoverInvocation:self.actionPopoverController];
					for (Action *action in commands) {
						[action addInvocation:dismissInv];
					}
					CGRect tapRect = [self rectForCoord:CoordMake(x,y)];
					[self resizePopover:self.actionPopoverController];
					[self.actionPopoverController presentPopoverFromRect:tapRect inView:self.view
												permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				} else {
					// movement
					[[NhEventQueue instance] addEvent:[NhEvent eventWithX:x y:y]];
				}
			} else {
				// travel
				[[NhEventQueue instance] addEvent:[NhEvent eventWithX:x y:y]];
			}
		}
	} else {
		[[NhEventQueue instance] addEvent:[NhEvent eventWithX:x y:y]];
	}
}

- (void)handleDirectionTap:(e_direction)direction {
	if (!ipad_getpos) {
		if (directionQuestion) {
			directionQuestion = NO;
			int key = [self keyFromDirection:direction];
			[[NhEventQueue instance] addKey:key];
		} else {
			coord tp = CoordMake(u.ux, u.uy);
			switch (direction) {
				case kDirectionLeft:
					tp.x--;
					break;
				case kDirectionUpLeft:
					tp.x--;
					tp.y--;
					break;
				case kDirectionUp:
					tp.y--;
					break;
				case kDirectionUpRight:
					tp.x++;
					tp.y--;
					break;
				case kDirectionRight:
					tp.x++;
					break;
				case kDirectionDownRight:
					tp.x++;
					tp.y++;
					break;
				case kDirectionDownLeft:
					tp.x--;
					tp.y++;
					break;
				case kDirectionDown:
					tp.y++;
					break;
			}
			int key = [self keyFromDirection:direction];
			if (IS_DOOR(levl[tp.x][tp.y].typ)) {
				char cmd[3] = { ' ', key, '\0' };
				int mask = levl[tp.x][tp.y].doormask;
				if (mask & D_CLOSED) {
					cmd[0] = 'o';
					[[NhEventQueue instance] addKeys:cmd];
				} else if (mask & D_LOCKED) {
					NSArray *commands = [NhCommand commandsForAdjacentTile:tp];
					if (commands.count > 0) {
						self.actionViewController.actions = commands;
						// dismiss popover
						NSInvocation *dismissInv = [self dismissPopoverInvocation:self.actionPopoverController];
						for (Action *action in commands) {
							[action addInvocation:dismissInv];
						}
						CGRect tapRect = [self rectForCoord:tp];
						[self resizePopover:self.actionPopoverController];
						[self.actionPopoverController presentPopoverFromRect:tapRect inView:self.view
													permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
					}
				} else {
					[[NhEventQueue instance] addKey:key];
				}
			} else {
				[[NhEventQueue instance] addKey:key];
			}
		}
	}
}

- (void)handleDirectionDoubleTap:(e_direction)direction {
	if (!ipad_getpos) {
		int key = [self keyFromDirection:direction];
		[[NhEventQueue instance] addKey:'g'];
		[[NhEventQueue instance] addKey:key];
		directionQuestion = NO;
	}
}

#pragma mark utility

- (NSInvocation *)dismissPopoverInvocation:(UIPopoverController *)popover {
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
						 [popover methodSignatureForSelector:@selector(dismissPopoverAnimated:)]];
	[inv setTarget:popover];
	[inv setSelector:@selector(dismissPopoverAnimated:)];
	BOOL arg = YES;
	[inv setArgument:&arg atIndex:2];
	[inv retainArguments];
	return inv;
}

- (void)resizePopover:(UIPopoverController *)popover {
	[popover setPopoverContentSize:popover.contentViewController.contentSizeForViewInPopover];
}

- (CGRect)mapViewBounds {
	return mapScrollView.bounds;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.numberOfButtons > 1) {
		char c = currentYnQuestion.choices[buttonIndex];
		[[NhEventQueue instance] addKey:c];
		currentYnQuestion = nil;
	} else {
		// add no-event
		[[NhEventQueue instance] addKey:-1];
	}
}

#pragma mark UITextFieldDelegate for hardware keyboard

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField == dummyTextField) {
		const char *pStr = [string cStringUsingEncoding:NSASCIIStringEncoding];
		char c;
		while (c = *pStr++) {
			if ([self isMovementKey:c]) {
				e_direction direction = [self directionFromKey:c];
				[self handleDirectionTap:direction];
			} else {
				[[NhEventQueue instance] addKey:c];
			}
		}
	}
	return NO;
}

#pragma mark misc

- (void)dealloc {
    [super dealloc];
}

@end

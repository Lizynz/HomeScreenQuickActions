/* Home Screen Quick Actions - Control Home Screen Quick Actions on iOS/iPadOS
 * Copyright (C) 2020 Tomasz Poliszuk
 *
 * Home Screen Quick Actions is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * Home Screen Quick Actions is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Home Screen Quick Actions. If not, see <https://www.gnu.org/licenses/>.
 */


#import <dlfcn.h>
#include "HomeScreenQuickActions.h"

#define kIconController [%c(SBIconController) sharedInstance]
#define kIconManager [kIconController iconManager]
#define kFloatingDockController [kIconController floatingDockController]
#define kDismissFloatingDockIfPresented [kFloatingDockController _dismissFloatingDockIfPresentedAnimated:YES completionHandler:nil]
#define kPresentFloatingDockIfDismissed [kFloatingDockController _presentFloatingDockIfDismissedAnimated:YES completionHandler:nil]

NSMutableDictionary *tweakSettings;

static bool enableTweak;

//	Installed Applications (Native)
static bool appQuickActionDelete;
static bool appQuickActionAppProtection;
static bool appQuickActionEditHomeScreen;
static bool appQuickActionSendBetaFeedback;
static bool appQuickActionShare;
static bool widgetQuickActionResize;
static bool appQuickActionNewWindow;
static bool appQuickActionShowAllWindows;

//	Offloaded Applications (Native)
static bool offloadedAppQuickActionEditHomeScreen;

//	Folders (Native)
static bool folderQuickActionRemove;	//	iOS14
static bool folderQuickActionEditHomeScreen;
static bool folderQuickActionRename;
static bool folderQuickActionUnreadNotifications;

//	Widgets (Native)
static bool widgetQuickActionRemove;	//	iOS14
static bool widgetQuickActionEditHomeScreen;	//	iOS14
static bool widgetQuickActionConfigure;	//	iOS14
static bool widgetStackQuickActionConfigure;	//	iOS14
static bool widgetsInQuickActions;	//	iOS13

//	Bookmarks (Native)
static bool bookmarkQuickActionDelete;
static bool bookmarkQuickActionShare;
static bool bookmarkQuickActionEditHomeScreen;

//	Visible in App Library (Native)
static bool appQuickActionAddToHomeScreen;	//	iOS14

//	Visible during downloading app (Native)
static bool appQuickActionPrioritizeDownload;
static bool appQuickActionPauseDownload;
static bool appQuickActionCancelDownload;

//	visible in iPad Dock recents/suggestions (Native)
static bool appQuickActionHide;

void SettingsChanged() {
	CFArrayRef keyList = CFPreferencesCopyKeyList(
		CFSTR(packageName),
		kCFPreferencesCurrentUser,
		kCFPreferencesAnyHost
	);
	if(keyList) {
		tweakSettings = (
			NSMutableDictionary *)CFBridgingRelease(
			CFPreferencesCopyMultiple(
				keyList,
				CFSTR(packageName),
				kCFPreferencesCurrentUser,
				kCFPreferencesAnyHost
			)
		);
		CFRelease(keyList);
	} else {
		tweakSettings = nil;
	}
	if (!tweakSettings) {
		tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:userSettingsFile];
	}

	enableTweak = [([tweakSettings objectForKey:@"enableTweak"] ?: @(YES)) boolValue];

//	Installed Applications (Native)
	appQuickActionDelete = [([tweakSettings objectForKey:@"appQuickActionDelete"] ?: @(YES)) boolValue];
	appQuickActionAppProtection = [([tweakSettings objectForKey:@"appQuickActionAppProtection"] ?: @(YES)) boolValue];
	widgetQuickActionResize = [([tweakSettings objectForKey:@"widgetQuickActionResize"] ?: @(YES)) boolValue];
	appQuickActionEditHomeScreen = [([tweakSettings objectForKey:@"appQuickActionEditHomeScreen"] ?: @(YES)) boolValue];
	appQuickActionShare = [([tweakSettings objectForKey:@"appQuickActionShare"] ?: @(YES)) boolValue];
	appQuickActionSendBetaFeedback = [([tweakSettings objectForKey:@"appQuickActionSendBetaFeedback"] ?: @(YES)) boolValue];
	appQuickActionNewWindow = [([tweakSettings objectForKey:@"appQuickActionNewWindow"] ?: @(YES)) boolValue];
	appQuickActionShowAllWindows = [([tweakSettings objectForKey:@"appQuickActionShowAllWindows"] ?: @(YES)) boolValue];

//	Offloaded Applications (Native)
	offloadedAppQuickActionEditHomeScreen = [([tweakSettings objectForKey:@"offloadedAppQuickActionEditHomeScreen"] ?: @(YES)) boolValue]; // (Beta)

//	Folders (Native)
	folderQuickActionRemove = [([tweakSettings objectForKey:@"folderQuickActionRemove"] ?: @(YES)) boolValue];
	folderQuickActionEditHomeScreen = [([tweakSettings objectForKey:@"folderQuickActionEditHomeScreen"] ?: @(YES)) boolValue];
	folderQuickActionRename = [([tweakSettings objectForKey:@"folderQuickActionRename"] ?: @(YES)) boolValue];
	folderQuickActionUnreadNotifications = [([tweakSettings objectForKey:@"folderQuickActionUnreadNotifications"] ?: @(YES)) boolValue];

//	Widgets (Native)
	widgetQuickActionRemove = [([tweakSettings objectForKey:@"widgetQuickActionRemove"] ?: @(YES)) boolValue];
	widgetQuickActionEditHomeScreen = [([tweakSettings objectForKey:@"widgetQuickActionEditHomeScreen"] ?: @(YES)) boolValue];
	widgetQuickActionConfigure = [([tweakSettings objectForKey:@"widgetQuickActionConfigure"] ?: @(YES)) boolValue];
	widgetStackQuickActionConfigure = [([tweakSettings objectForKey:@"widgetStackQuickActionConfigure"] ?: @(YES)) boolValue];
	widgetsInQuickActions = [([tweakSettings objectForKey:@"widgetsInQuickActions"] ?: @(YES)) boolValue];

//	Bookmarks (Native)
	bookmarkQuickActionDelete = [([tweakSettings objectForKey:@"bookmarkQuickActionDelete"] ?: @(YES)) boolValue];
	bookmarkQuickActionShare = [([tweakSettings objectForKey:@"bookmarkQuickActionShare"] ?: @(NO)) boolValue];
	bookmarkQuickActionEditHomeScreen = [([tweakSettings objectForKey:@"bookmarkQuickActionEditHomeScreen"] ?: @(YES)) boolValue];

//	Visible in App Library (Native)
	appQuickActionAddToHomeScreen = [([tweakSettings objectForKey:@"appQuickActionAddToHomeScreen"] ?: @(YES)) boolValue];

//	Visible during downloading app (Native)
	appQuickActionPrioritizeDownload = [([tweakSettings objectForKey:@"appQuickActionPrioritizeDownload"] ?: @(YES)) boolValue];
	appQuickActionPauseDownload = [([tweakSettings objectForKey:@"appQuickActionPauseDownload"] ?: @(YES)) boolValue];
	appQuickActionCancelDownload = [([tweakSettings objectForKey:@"appQuickActionCancelDownload"] ?: @(YES)) boolValue];

//	visible in iPad Dock recents/suggestions (Native)
	appQuickActionHide = [([tweakSettings objectForKey:@"appQuickActionHide"] ?: @(YES)) boolValue];
}

static void receivedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	SettingsChanged();
}

%hook SBIconView
- (void)setApplicationShortcutItems:(NSArray *)arg1 {
	NSString* applicationBundleID;
	if( [[self icon] respondsToSelector:@selector(applicationBundleID)] ) {
		applicationBundleID = [[self icon] applicationBundleID];
	}
	if ( enableTweak ) {
		NSMutableArray *shortcutItems = [[NSMutableArray alloc] init];
		for (SBSApplicationShortcutItem *shortcutItem in arg1) {
//			NSLog(@"[HSQA] type: %@", shortcutItem.type);
			//	Apple uses both prefixes for system shortcuts:
			//	- com.apple.springboardhome.application-shotcut-item - with typo "shotcut" name
			//	- com.apple.springboardhome.application-shortcut-item - with correct "shortcut" name
			//	- so let's detect both of them in one run:
			if ( [shortcutItem.type hasPrefix:@"com.apple.springboardhome.application-"] ) {
				if ( [shortcutItem.type hasSuffix:@"delete-app"] ) {
					if ( appQuickActionDelete && [[self icon] isApplicationIcon] && !([self displayedLabelAccessoryType] == 3) ) {
						[shortcutItems addObject: shortcutItem];
						continue;
					}
					if ( bookmarkQuickActionDelete && [[self icon] isBookmarkIcon] ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"rearrange-icons"] ) {
					if ( appQuickActionEditHomeScreen && [[self icon] isApplicationIcon] && !([self displayedLabelAccessoryType] == 3) ) {
						[shortcutItems addObject: shortcutItem];
						continue;
					}
					if ( offloadedAppQuickActionEditHomeScreen && ([self displayedLabelAccessoryType] == 3) ) {
						[shortcutItems addObject: shortcutItem];
					}
					if ( folderQuickActionEditHomeScreen && [self isFolderIcon] ) {
						[shortcutItems addObject: shortcutItem];
					}
					if ( iOSversion.majorVersion > 13 ) {
						if ( widgetQuickActionEditHomeScreen && ( [[self icon] isWidgetIcon] || [[self icon] isWidgetStackIcon] ) ) {
							[shortcutItems addObject: shortcutItem];
						}
					}
					if ( bookmarkQuickActionEditHomeScreen && [[self icon] isBookmarkIcon] ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"item.share"] ) {
					if ( appQuickActionShare && [[self icon] isApplicationIcon] && !([self displayedLabelAccessoryType] == 3) ) {
						[shortcutItems addObject: shortcutItem];
						continue;
					}
					if ( bookmarkQuickActionShare && [[self icon] isBookmarkIcon] ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"rename-folder"] ) {
					if ( folderQuickActionRename ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"hide-folder"] ) {
					if ( folderQuickActionRemove ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"unread-notifications"] ) {
					if ( folderQuickActionUnreadNotifications ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"remove-app"] ) {
					if ( appQuickActionDelete && [[self icon] isApplicationIcon] && !([self displayedLabelAccessoryType] == 3) ) {
						[shortcutItems addObject: shortcutItem];
						continue;
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"remove-widget"] ) {
					if ( widgetQuickActionRemove ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"configure-widget"] ) {
					if ( widgetQuickActionConfigure ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"configure-stack"] ) {
					if ( widgetStackQuickActionConfigure ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"add-to-home-screen"] ) {
					if ( appQuickActionAddToHomeScreen ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"prioritize-download"] ) {
					if ( appQuickActionPrioritizeDownload ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"pause-download"] ) {
					if ( appQuickActionPauseDownload ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"cancel-download"] ) {
					if ( appQuickActionCancelDownload ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"hide-app"] || [shortcutItem.type hasSuffix:@"hide-app-suggestion"] ) {
					if ( appQuickActionHide ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"app-protection"] ) {
					if ( appQuickActionAppProtection && [[self icon] isApplicationIcon] ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type containsString:@"change-widget-size"] || [shortcutItem.type hasSuffix:@"change-widget-to-app-icon"] ) {
					if ( widgetQuickActionResize ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"show-all-windows"] ) {
					if ( appQuickActionShowAllWindows ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
				if ( [shortcutItem.type hasSuffix:@"new-window"] ) {
					if ( appQuickActionNewWindow ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
			}
			
			if ( [shortcutItem.type hasPrefix:@"com.apple.SpringBoardServices.application-shortcut-item-type."] ) {
				if ( [shortcutItem.type hasSuffix:@"send-beta-feedback"] ) {
					if ( appQuickActionSendBetaFeedback && [[self icon] isApplicationIcon] ) {
						[shortcutItems addObject: shortcutItem];
					}
					continue;
				}
			}
			
			bool appSpecificQuickActions = [([tweakSettings objectForKey:[NSString stringWithFormat:@"appSpecificQuickActions-%@", applicationBundleID]] ?: @(YES)) boolValue];
			if ( appSpecificQuickActions && [[self icon] isApplicationIcon] ) {
				[shortcutItems addObject: shortcutItem];
			}
		}
		%orig(shortcutItems);
	} else {
		%orig;
	}
}

%end

%hook SBBookmarkIcon
- (bool)displaysShareBookmarkShortcutItem {
	bool origValue = %orig;
	if ( enableTweak ) {
		return bookmarkQuickActionShare;
	}
	return origValue;
}
%end

%hook SBHHomeScreenSettings
-(bool)showWidgets {
	bool origValue = %orig;
	if ( enableTweak ) {
		return widgetsInQuickActions;
	}
	return origValue;
}
%end

%hook UIActivityContentViewController
- (void)viewWillAppear:(bool)arg1 {
	%orig;
	if ( enableTweak && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
		kDismissFloatingDockIfPresented;
	}
}
- (void)viewWillDisappear:(bool)arg1 {
	%orig;
	if ( enableTweak && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
		kPresentFloatingDockIfDismissed;
	}
}
%end

%hook SKRemoteProductActivityViewController
- (void)viewWillAppear:(bool)arg1 {
	%orig;
	if ( enableTweak && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad ) {
		kDismissFloatingDockIfPresented;
	}
}
- (void)viewWillDisappear:(bool)arg1 {
	%orig;
	if ( enableTweak && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad ) {
		kPresentFloatingDockIfDismissed;
	}
}
%end

%ctor {
	SettingsChanged();
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		receivedNotification,
		CFSTR("com.tomaszpoliszuk.homescreenquickactions.settingschanged"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately
	);
	%init;
}

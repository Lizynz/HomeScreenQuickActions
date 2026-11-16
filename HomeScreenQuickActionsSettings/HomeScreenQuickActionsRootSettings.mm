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


#include "Headers.h"

@implementation HomeScreenQuickActionsRootSettings
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

		for (PSSpecifier *specifier in _specifiers) {
			if (specifier.cellType == PSSwitchCell) {
				[specifier setProperty:@"" forKey:@"cellSubtitleText"];
			}
		}

		UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"trash"]
																	   style:UIBarButtonItemStylePlain
																	  target:self
																	  action:@selector(resetSettings)];
		resetItem.tintColor = [UIColor systemRedColor];
		self.navigationItem.rightBarButtonItem = resetItem;
		
		if (iOSversion.majorVersion == 13) {
			removeSpecifiers = [[NSMutableArray alloc]init];
			for(PSSpecifier* specifier in _specifiers) {
				NSString* key = [specifier propertyForKey:@"key"];
				if(
					[key hasPrefix:@"widgetQuickActionEditHomeScreen"]
					||
					[key hasPrefix:@"widgetQuickActionRemove"]
					||
					[key hasPrefix:@"widgetQuickActionConfigure"]
					||
					[key hasPrefix:@"widgetStackQuickActionConfigure"]
					||
					[key hasPrefix:@"visibleinAppLibrary"]
					||
					[key hasPrefix:@"appQuickActionAddToHomeScreen"]
					||
					[key hasPrefix:@"folderQuickActionRemove"]
				) {
					[removeSpecifiers addObject:specifier];
				}
			}
			[_specifiers removeObjectsInArray:removeSpecifiers];
		}
		if (iOSversion.majorVersion > 13) {
			removeSpecifiers = [[NSMutableArray alloc]init];
			for(PSSpecifier* specifier in _specifiers) {
				NSString* key = [specifier propertyForKey:@"key"];
				if( [key hasPrefix:@"widgetsInQuickActions"] ) {
					[removeSpecifiers addObject:specifier];
				}
			}
			[_specifiers removeObjectsInArray:removeSpecifiers];
		}
	}
	return _specifiers;
}

- (void)resetSettings {
	UIAlertController *resetSettingsAlert = [UIAlertController alertControllerWithTitle:@"Reset Home Screen Quick Actions Settings" message:@"Do you want to reset settings?" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];
		[tweakSettings removePersistentDomainForName:domainString];
		[tweakSettings synchronize];

		CFNotificationCenterPostNotification(
			CFNotificationCenterGetDarwinNotifyCenter(),
			CFSTR("com.tomaszpoliszuk.homescreenquickactions.settingschanged"),
			NULL, NULL, YES
		);

		[self reloadSpecifiers];
	}];
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	[resetSettingsAlert addAction:cancel];
	[resetSettingsAlert addAction:confirm];
	[self presentViewController:resetSettingsAlert animated:YES completion:nil];
}

- (void)sourceCode {
	NSURL *sourceCode = [NSURL URLWithString:@"https://github.com/Lizynz/HomeScreenQuickActions"];
	[[UIApplication sharedApplication] openURL:sourceCode options:@{} completionHandler:nil];
}

@end

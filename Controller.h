//
//  Controller.h
//
//  Created by Michael Barriault on 10-11-19.
//  Copyright 2010 MikBarr Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Controller : NSObject {
    IBOutlet id DVHOSTField;
    IBOutlet id infoBox;
    IBOutlet id statusBox;
	IBOutlet id runListTable;
	IBOutlet id fileListTable;
	IBOutlet id progressSpinner;
	NSURL *runsFolderPath;
	NSURL *runPath;
	NSMutableArray *runList;
	NSMutableArray *fileList;
	NSFileManager *manager;
	int animcount;
}
- (IBAction)chooseFolder:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)scanRun:(id)sender;
- (IBAction)sdftodv:(id)sender;
@end

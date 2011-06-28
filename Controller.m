//
//  Controller.m
//
//  Created by Michael Barriault on 10-11-19.
//  Copyright 2010 MikBarr Studios. All rights reserved.
//

#import "Controller.h"

@implementation Controller
-(id)init {
	if ( self = [super init] ) {
		runList = [[NSMutableArray alloc] initWithCapacity:0];
		fileList = [[NSMutableArray alloc] initWithCapacity:0];
		manager = [[NSFileManager alloc] init];
		animcount = 0;
		[runListTable setDelegate:self];
	}
	return self;
}
-(void)start {
	animcount++;
	if ( animcount > 0 )
		[progressSpinner startAnimation:self];
}
-(void)stop {
	animcount--;
	if ( animcount <= 0 )
		[progressSpinner stopAnimation:self];
}
- (IBAction)chooseFolder:(id)sender {
    NSOpenPanel *chooser = [NSOpenPanel openPanel];
	[chooser setTitle:@"Choose runs directory"];
	[chooser setCanChooseDirectories:YES];
	[chooser setCanChooseFiles:NO];
	if ( [chooser runModal] == NSOKButton ) {
		[progressSpinner startAnimation:self];
		runsFolderPath = [[[chooser URLs] objectAtIndex:0] retain];
		[statusBox setStringValue:[NSString stringWithFormat:@"Opened %@", runsFolderPath]];
		[progressSpinner stopAnimation:self];
		[self refresh:sender];
	}
}

- (IBAction)refresh:(id)sender {
	[self start];
	[runList release];
	runList = [[NSMutableArray alloc] initWithObjects:@"", nil];
	NSArray *contents = [manager contentsOfDirectoryAtPath:[runsFolderPath path] error:nil];
	for ( NSString *file in contents ) {
		NSURL *suburl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [runsFolderPath path], file]];
		BOOL isDir;
		[manager fileExistsAtPath:[suburl path] isDirectory:&isDir];
		if (  isDir ) {
			NSString *infoFile = [NSString stringWithFormat:@"%@/info.txt", suburl];
			if ( [manager fileExistsAtPath:infoFile] )
				[runList addObject:suburl];
		}
	}
	[runListTable reloadData];
	[self stop];
	[self scanRun:sender];
}

- (IBAction)scanRun:(id)sender {
	[self start];
	if ( [runListTable selectedRow] > -1 ) {
		NSString *infoFile = [NSString stringWithFormat:@"%@/info.txt", [[runList objectAtIndex:[runListTable selectedRow]] path]];
		if ( [manager fileExistsAtPath:infoFile] ) {
			NSString *infoText = [NSString stringWithContentsOfFile:infoFile encoding:NSASCIIStringEncoding error:nil];
			[infoBox setStringValue:infoText];
			runPath = [runList objectAtIndex:[runListTable selectedRow]];
			[fileList release];
			fileList = [[NSMutableArray alloc] initWithObjects:nil];
			NSArray *contents = [manager contentsOfDirectoryAtPath:[runPath path] error:nil];
			for ( NSString *file in contents ) {
				NSString *filePath = [NSString stringWithFormat:@"%@/%@", [runPath path], file];
				if ( [[file pathExtension] isEqualToString:@"sdf"] ) {
					[fileList addObject:filePath];
				}
			}
			[fileListTable reloadData];
		}
	}
	[self stop];
}

- (id)action:(NSString*)command {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self start];
	NSLog(@"%@", command);
	system((const char*)[command cStringUsingEncoding:NSASCIIStringEncoding]);
	[self stop];
	[pool release];
	return 0;
}

- (IBAction)sdftodv:(id)sender {
	setenv("DVHOST", (const char*)[[DVHOSTField stringValue] cStringUsingEncoding:NSASCIIStringEncoding], 1);
    if ( [fileListTable selectedRow] > -1 ) {
		NSString *sdffile = [NSString stringWithFormat:@"%@", [fileList objectAtIndex:[fileListTable selectedRow]]];
		NSString *appString = [[[NSBundle mainBundle] bundlePath] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
		[statusBox setStringValue:[NSString stringWithFormat:@"sdftodv %@", sdffile]];
		NSString *command = [NSString stringWithFormat:@"%@/Contents/Resources/sdftodv %@", appString, sdffile];
		[self performSelectorInBackground:@selector(action:) withObject:command];
	}
}

-(int)numberOfRowsInTableView:(NSTableView *)tableView {
	if ( tableView == runListTable )
		return [runList count];
	else if ( tableView == fileListTable )
		return [fileList count];
	return 0;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int) row {
	if ( tableView == runListTable )
		return [[runList objectAtIndex:row] lastPathComponent];
	else if ( tableView == fileListTable )
		return [[[fileList objectAtIndex:row] lastPathComponent] stringByDeletingPathExtension];
	return nil;
}

-(void)setDoubleAction:(id)sender {
	[self scanRun:sender];
}

-(void)dealloc {
	if (runsFolderPath != nil) [runsFolderPath release];
	if (runList != nil) [runList release];
	if (fileList != nil) [fileList release];
	[manager release];
	[super dealloc];
}
@end

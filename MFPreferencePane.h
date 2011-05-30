//
// Fan Control
// Copyright 2006 Lobotomo Software
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//

// (for those who don't already know)
// NOTE: for the "Desired/Current Fan Speeds" and "Current Temperatures" values ...
//
//       To connect this code to the UI, do the following:
//       - open the PreferencePane.nib in Interface Builder
//       - via the PreferencePane.nib window, open the "Preferences" panel
//       - in the PreferencePane.nib window, select the "File's Owner"
//         (the cube, not the controller)
//       - CTRL-drag from the selected "File's Owner" to a field (e.g., the
//         "desired/target fan-speed" field next to the "DVD Fan:" title)
//       - release the mouse and a window of defined attributes are available
//         for selection
//       - double-click the attribute that's to be associated with the field
//
//       To see which attributes are bound to which field, do the following:
//       - via the PreferencePane.nib window, open the "Preferences" panel
//       - in the PreferencePane.nib window, select the "File's Owner"
//         (the cube, not the controller)
//       - select the Tools => Connections Inspector menu (CMD-5)
//       - the corresponding field will be indiated in the PreferencePane window
//         when a connection outlet entry has the mouse cursor located over it

#import <Cocoa/Cocoa.h>
#import <NSPreferencePane.h>

@class MFDaemon, MFChartView, MFTemperatureTransformer;


@interface MFPreferencePane : NSPreferencePane {

    // bindings controller
    IBOutlet NSObjectController *fileOwnerController;

    // text fields
    IBOutlet NSTextField *CPUfanRPMfield;
    IBOutlet NSTextField *HDfanRPMfield;
    IBOutlet NSTextField *DVDfanRPMfield;
    //
    IBOutlet NSTextField *CPUfanTargetRPMfield;
    IBOutlet NSTextField *HDfanTargetRPMfield;
    IBOutlet NSTextField *DVDfanTargetRPMfield;
    //
    IBOutlet NSTextField *CPUtempField;
    IBOutlet NSTextField *GPUtempField;
    IBOutlet NSTextField *HDtempField;
    IBOutlet NSTextField *DVDtempField;

    // chart view
    IBOutlet MFChartView *chartView;

    // daemon proxy
    MFDaemon *daemon;

    // temperature transformer
    MFTemperatureTransformer *transformer;

    // update timer
    NSTimer *timer;
}

// accessors & setters

- (float)lowerTempThreshold;
- (float)upperTempThreshold;
- (void)setUpperTempThreshold:(float)newUpperTempThreshold;
- (void)setLowerTempThreshold:(float)newLowerTempThreshold;

- (BOOL)showTempsAsFahrenheit;
- (void)setShowTempsAsFahrenheit:(BOOL)newShowTempsAsFahrenheit;

- (void)setCPUfanBaseRPM:(int)newCPUfanBaseRPM;
- (void)setHDfanBaseRPM:(int)newHDfanBaseRPM;
- (void)setDVDfanBaseRPM:(int)newDVDfanBaseRPM;

- (void)setCPUfanTargetRPM:(int)newCPUfanTargetRPM;
- (void)setHDfanTargetRPM:(int)newHDfanTargetRPM;
- (void)setDVDfanTargetRPM:(int)newDVDfanTargetRPM;

@end

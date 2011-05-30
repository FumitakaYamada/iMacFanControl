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

#import <Cocoa/Cocoa.h>


@interface MFChartView : NSView {

    // the temperature threshold settings used to compute the desired/target fan RPMs
    float lowerTempThreshold;
    float upperTempThreshold;

    // the "base"/slowest/lower-limit fan RPMs
    int CPUfanBaseRPM;
    int HDfanBaseRPM;
    int DVDfanBaseRPM;

    // the computed desired/target fan RPMs based upon the pref settings
    int CPUfanTargetRPM;
    int HDfanTargetRPM;
    int DVDfanTargetRPM;

    // the current fan speeds
    int CPUfanRPM;
    int HDfanRPM;
    int DVDfanRPM;

    // the current sensor temperatures
    float CPUtemp;
    float GPUtemp;
    float HDtemp;
    float DVDtemp;
}

// setters

- (void)setLowerTempThreshold:(float)newLowerTempThreshold;
- (void)setUpperTempThreshold:(float)newUpperTempThreshold;

- (void)setCPUfanBaseRPM:(int)newCPUfanBaseRPM;
- (void)setHDfanBaseRPM:(int)newHDfanBaseRPM;
- (void)setDVDfanBaseRPM:(int)newDVDfanBaseRPM;

- (void)setCPUfanTargetRPM:(int)newCPUfanTargetRPM;
- (void)setHDfanTargetRPM:(int)newHDfanTargetRPM;
- (void)setDVDfanTargetRPM:(int)newDVDfanTargetRPM;

- (void)setCPUfanRPM:(int)newCPUfanRPM;
- (void)setHDfanRPM:(int)newHDfanRPM;
- (void)setDVDfanRPM:(int)newDVDfanRPM;

- (void)setCPUtemp:(float)newCPUtemp;
- (void)setGPUtemp:(float)newGPUtemp;
- (void)setHDtemp:(float)newHDtemp;
- (void)setDVDtemp:(float)newDVDtemp;

@end

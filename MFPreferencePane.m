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

#import "MFChartView.h"
#import "MFDefinitions.h"
#import "MFPreferencePane.h"
#import "MFProtocol.h"
#import "MFTemperatureTransformer.h"


@implementation MFPreferencePane


- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super initWithBundle:bundle]) {
        transformer = [MFTemperatureTransformer new];
        [NSValueTransformer setValueTransformer:transformer forName:@"MFTemperatureTransformer"];
    }
    return self;
}

- (void)dealloc
{
    [transformer release];
    [super dealloc];
}

// update the preference-pane display
- (void)updateDisplay:(NSTimer *)aTimer
{
    int CPUfanRPM;
    int HDfanRPM;
    int DVDfanRPM;

    float CPUtemp;
    float HDtemp;
    float DVDtemp;
    float GPUtemp;

    int CPUfanTargetRPM = [daemon CPUfanTargetRPM];
    int HDfanTargetRPM = [daemon HDfanTargetRPM];
    int DVDfanTargetRPM = [daemon DVDfanTargetRPM];

    [daemon CPUtemp:&CPUtemp GPUtemp:&GPUtemp HDtemp:&HDtemp DVDtemp:&DVDtemp
            CPUfanRPM:&CPUfanRPM HDfanRPM:&HDfanRPM DVDfanRPM:&DVDfanRPM];

    // update the textual fields
    [CPUfanRPMfield setIntValue:CPUfanRPM];
    [HDfanRPMfield setIntValue:HDfanRPM];
    [DVDfanRPMfield setIntValue:DVDfanRPM];

    [CPUfanTargetRPMfield setIntValue:CPUfanTargetRPM];
    [HDfanTargetRPMfield setIntValue:HDfanTargetRPM];
    [DVDfanTargetRPMfield setIntValue:DVDfanTargetRPM];

    [CPUtempField setStringValue:[transformer transformedValue:[NSNumber numberWithFloat:CPUtemp]]];
    [HDtempField setStringValue:[transformer transformedValue:[NSNumber numberWithFloat:HDtemp]]];
    [DVDtempField setStringValue:[transformer transformedValue:[NSNumber numberWithFloat:DVDtemp]]];
    [GPUtempField setStringValue:[transformer transformedValue:[NSNumber numberWithFloat:GPUtemp]]];

    // update the graph/chart
    [chartView setLowerTempThreshold:[daemon lowerTempThreshold]];
    [chartView setUpperTempThreshold:[daemon upperTempThreshold]];
    //
    [chartView setCPUfanBaseRPM:[daemon CPUfanBaseRPM]];
    [chartView setHDfanBaseRPM:[daemon HDfanBaseRPM]];
    [chartView setDVDfanBaseRPM:[daemon DVDfanBaseRPM]];
    //
    [chartView setCPUfanTargetRPM:CPUfanTargetRPM];
    [chartView setHDfanTargetRPM:HDfanTargetRPM];
    [chartView setDVDfanTargetRPM:DVDfanTargetRPM];
    //
    [chartView setCPUfanRPM:CPUfanRPM];
    [chartView setHDfanRPM:HDfanRPM];
    [chartView setDVDfanRPM:DVDfanRPM];
    //
    [chartView setCPUtemp:CPUtemp];
    [chartView setHDtemp:HDtemp];
    [chartView setDVDtemp:DVDtemp];
    [chartView setGPUtemp:GPUtemp];
}

- (void)awakeFromNib
{
    // connect to daemon
    NSConnection *connection =
        [NSConnection connectionWithRegisteredName:MFDaemonRegisteredName host:nil];
    daemon = [[connection rootProxy] retain];
    [(id)daemon setProtocolForProxy:@protocol(MFProtocol)];

    // set transformer mode
    [transformer setShowTempAsFahrenheit:[daemon showTempsAsFahrenheit]];

    // connect to object controller
    [fileOwnerController setContent:self];
}

// message sent before preference pane is displayed (starts udpate the timer)
- (void)willSelect
{
    // update display immediately, then every MFUpdateInterval seconds
    [self updateDisplay:nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:MFUpdateInterval
                     target:self selector:@selector(updateDisplay:)
                     userInfo:nil repeats:YES];
}

// message sent after preference pane is ordered out
- (void)didUnselect
{
    // stop updates
    [timer invalidate];
    timer = nil;
}

// accessors & setters
// -----------------------------------------------------------------------------
- (float)lowerTempThreshold
{
    return [daemon lowerTempThreshold];
}
- (float)upperTempThreshold
{
    return [daemon upperTempThreshold];
}
//
- (void)setLowerTempThreshold:(float)newLowerTempThreshold
{
    [daemon setLowerTempThreshold:newLowerTempThreshold];
    [chartView setLowerTempThreshold:newLowerTempThreshold];
}
- (void)setUpperTempThreshold:(float)newUpperTempThreshold
{
    [daemon setUpperTempThreshold:newUpperTempThreshold];
    [chartView setUpperTempThreshold:newUpperTempThreshold];
}
// -------------------------------------
- (BOOL)showTempsAsFahrenheit
{
    return [daemon showTempsAsFahrenheit];
}
- (void)setShowTempsAsFahrenheit:(BOOL)newShowTempsAsFahrenheit
{
    [daemon setShowTempsAsFahrenheit:newShowTempsAsFahrenheit];
    [transformer setShowTempAsFahrenheit:newShowTempsAsFahrenheit];
    // force display update
    [self updateDisplay:nil];
    [fileOwnerController setContent:nil];
    [fileOwnerController setContent:self];
}
// -----------------------------------------------------------------------------
- (int)CPUfanBaseRPM
{
    return [daemon CPUfanBaseRPM];
}
- (int)HDfanBaseRPM
{
    return [daemon HDfanBaseRPM];
}
- (int)DVDfanBaseRPM
{
    return [daemon DVDfanBaseRPM];
}
//
- (void)setCPUfanBaseRPM:(int)newCPUfanBaseRPM
{
    [daemon setCPUfanBaseRPM:newCPUfanBaseRPM];
    [chartView setCPUfanBaseRPM:newCPUfanBaseRPM];
}
- (void)setHDfanBaseRPM:(int)newHDfanBaseRPM
{
    [daemon setHDfanBaseRPM:newHDfanBaseRPM];
    [chartView setHDfanBaseRPM:newHDfanBaseRPM];
}
- (void)setDVDfanBaseRPM:(int)newDVDfanBaseRPM
{
    [daemon setDVDfanBaseRPM:newDVDfanBaseRPM];
    [chartView setDVDfanBaseRPM:newDVDfanBaseRPM];
}
// -----------------------------------------------------------------------------
- (void)setCPUfanTargetRPM:(int)newCPUfanTargetRPM
{
    [daemon setCPUfanTargetRPM:newCPUfanTargetRPM];
    [chartView setCPUfanTargetRPM:newCPUfanTargetRPM];
}
- (void)setHDfanTargetRPM:(int)newHDfanTargetRPM
{
    [daemon setHDfanTargetRPM:newHDfanTargetRPM];
    [chartView setHDfanTargetRPM:newHDfanTargetRPM];
}
- (void)setDVDfanTargetRPM:(int)newDVDfanTargetRPM
{
    [chartView setDVDfanTargetRPM:newDVDfanTargetRPM];
}

@end

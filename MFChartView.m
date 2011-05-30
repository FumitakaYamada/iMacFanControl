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

// definitions depending on view size and labels - adjust when changing graph view
#define MFPixelPerDegree  2.4857 // <width in pixels (174)> / (MFGraphMaxTemp - MFGraphMinTemp)
#define MFPixelPerRPM     0.028846 // <height in pixels (150)> / (MFGraphMaxRPM - MFGraphMinRPM)
#define MFGraphMinTemp    25.0
#define MFGraphMaxTemp    95.0
#define MFGraphMinRPM     900
#define MFGraphMaxRPM     6100


@implementation MFChartView

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code here.
    }
    return self;
}

- (NSPoint)pointOnGraphWithTemp:(float)theTemp andRPM:(int)theRPM
{
    NSPoint coordinate = [self bounds].origin;
    coordinate.x += roundf((theTemp - MFGraphMinTemp) * MFPixelPerDegree);
    coordinate.y += roundf((theRPM - MFGraphMinRPM) * MFPixelPerRPM);
    return coordinate;
}

- (void)drawRect:(NSRect)rect
{
    // draw background and border
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    [[NSColor blackColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
    [path stroke];

    // draw CPU fan control-path graph
    [[NSColor colorWithDeviceRed:0.625 green:0.0 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:CPUfanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:lowerTempThreshold andRPM:CPUfanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:upperTempThreshold andRPM:MFMaxCPUfanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:MFMaxCPUfanRPM]];
    [path setLineWidth:2.0];
    [path stroke];

    // draw HD fan control-path graph
    [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.625 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:HDfanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:lowerTempThreshold andRPM:HDfanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:upperTempThreshold andRPM:MFMaxHDfanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:MFMaxHDfanRPM]];
    [path setLineWidth:2.0];
    [path stroke];

    // draw DVD fan control-path graph
    [[NSColor colorWithDeviceRed:0.0 green:0.625 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:DVDfanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:lowerTempThreshold andRPM:DVDfanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:upperTempThreshold andRPM:MFMaxDVDfanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:MFMaxDVDfanRPM]];
    [path setLineWidth:2.0];
    [path stroke];

    // draw CPU fan temperature line
    [[NSColor colorWithDeviceRed:0.625 green:0.0 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:CPUtemp andRPM:MFGraphMinRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:CPUtemp andRPM:MFGraphMaxRPM]];
    [path stroke];

    // draw HD fan temperature line
    [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.625 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:HDtemp andRPM:MFGraphMinRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:HDtemp andRPM:MFGraphMaxRPM]];
    [path stroke];

    // draw DVD fan temperature line
    [[NSColor colorWithDeviceRed:0.0 green:0.625 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:DVDtemp andRPM:MFGraphMinRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:DVDtemp andRPM:MFGraphMaxRPM]];
    [path stroke];

    // draw target CPU fan's desired/target RPM O-indicator
    [[NSColor colorWithDeviceRed:0.625 green:0.0 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter:
              [self pointOnGraphWithTemp:CPUtemp andRPM:CPUfanTargetRPM]
          radius:3.0 startAngle:0.0 endAngle:360.0];
    [path setLineWidth:2.0];
    [path stroke];

    // draw target HD fan's desired/target RPM O-indicator
    [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.625 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter:
              [self pointOnGraphWithTemp:HDtemp andRPM:HDfanTargetRPM]
          radius:3.0 startAngle:0.0 endAngle:360.0];
    [path setLineWidth:2.0];
    [path stroke];

    // draw target DVD fan's desired/target RPM O-indicator
    [[NSColor colorWithDeviceRed:0.0 green:0.625 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter:
              [self pointOnGraphWithTemp:DVDtemp andRPM:DVDfanTargetRPM]
          radius:3.0 startAngle:0.0 endAngle:360.0];
    [path setLineWidth:2.0];
    [path stroke];

    // draw target CPU fan's current RPM line
    [[NSColor colorWithDeviceRed:0.625 green:0.0 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:CPUfanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:CPUfanRPM]];
    [path stroke];

    // draw target HD fan's current RPM line
    [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.625 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:HDfanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:HDfanRPM]];
    [path stroke];

    // draw target DVD fan's current RPM line
    [[NSColor colorWithDeviceRed:0.0 green:0.625 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:DVDfanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:DVDfanRPM]];
    [path stroke];
}

// setters
// -----------------------------------------------------------------------------
- (void)setLowerTempThreshold:(float)newLowerTempThreshold
{
    lowerTempThreshold = newLowerTempThreshold;
    [self setNeedsDisplay:YES];
}
- (void)setUpperTempThreshold:(float)newUpperTempThreshold
{
    upperTempThreshold = newUpperTempThreshold;
    [self setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------
- (void)setCPUfanBaseRPM:(int)newCPUfanBaseRPM
{
    CPUfanBaseRPM = newCPUfanBaseRPM;
    [self setNeedsDisplay:YES];
}
- (void)setHDfanBaseRPM:(int)newHDfanBaseRPM
{
    HDfanBaseRPM = newHDfanBaseRPM;
    [self setNeedsDisplay:YES];
}
- (void)setDVDfanBaseRPM:(int)newDVDfanBaseRPM
{
    DVDfanBaseRPM = newDVDfanBaseRPM;
    [self setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------
- (void)setCPUfanTargetRPM:(int)newCPUfanTargetRPM
{
    CPUfanTargetRPM = newCPUfanTargetRPM;
    [self setNeedsDisplay:YES];
}
- (void)setHDfanTargetRPM:(int)newHDfanTargetRPM
{
    HDfanTargetRPM = newHDfanTargetRPM;
    [self setNeedsDisplay:YES];
}
- (void)setDVDfanTargetRPM:(int)newDVDfanTargetRPM
{
    DVDfanTargetRPM = newDVDfanTargetRPM;
    [self setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------
- (void)setCPUfanRPM:(int)newCPUfanRPM
{
    CPUfanRPM = newCPUfanRPM;
    [self setNeedsDisplay:YES];
}
- (void)setHDfanRPM:(int)newHDfanRPM
{
    HDfanRPM = newHDfanRPM;
    [self setNeedsDisplay:YES];
}
- (void)setDVDfanRPM:(int)newDVDfanRPM
{
    DVDfanRPM = newDVDfanRPM;
    [self setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------
- (void)setCPUtemp:(float)newCPUtemp
{
    CPUtemp = newCPUtemp;
    [self setNeedsDisplay:YES];
}
- (void)setGPUtemp:(float)newGPUtemp
{
    GPUtemp = newGPUtemp;
    [self setNeedsDisplay:YES];
}
- (void)setHDtemp:(float)newHDtemp
{
    HDtemp = newHDtemp;
    [self setNeedsDisplay:YES];
}
- (void)setDVDtemp:(float)newDVDtemp
{
    DVDtemp = newDVDtemp;
    [self setNeedsDisplay:YES];
}

@end

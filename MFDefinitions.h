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

// Value to turn off(0)/on(1) debug logging
#define MFDebugCPU  0
#define MFDebugHD   0
#define MFDebugDVD  0

// Value that determines the interval between Fan Control updates
// - use a shorter interval when using faster-responding sensors
// - too long an interval will lead to a oscillating fans
#define MFUpdateInterval  3.5

// Values that specify the range of temperatures (in degrees Celcius) for which
// Fan Control will compute and set a fans RPM versus it's sensor's temperature
//
// NOTE: these values should correspond to the range of values available via the
//       UI's "Lower Temp Threshold" and "Upper Temp Threshold" settings
#define MFLowerTempThresholdBottom  30.0
#define MFLowerTempThresholdTop     55.0
#define MFUpperTempThresholdBottom  65.0
#define MFUpperTempThresholdTop     90.0

// Values that determine the "safe" min/max fan speeds
#define MFMinCPUfanRPM  1200
#define MFMaxCPUfanRPM  3500
//
#define MFMinHDfanRPM   1200
#define MFMaxHDfanRPM   5500
//
#define MFMinDVDfanRPM  1000
#define MFMaxDVDfanRPM  4600

// Values that control the speed-stepping of the fans:
// - fans are adjusted in increments of MFRPMspeedStep
// - fans are adjusted to RPMs on MFRPMspeedStep boundaries
// - fans are adjusted in speed increments no larger than MFMaxRPMspeedStep
//
// NOTEs
// - the UI/slider increments should be set to ensure that the fan settings are
//   are in MFRPMspeedStep increments
#define MFRPMspeedStep     100
#define MFMaxRPMspeedStep  300

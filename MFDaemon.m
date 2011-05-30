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

#import "MFDaemon.h"
#import "MFDefinitions.h"
#import "MFProtocol.h"
#import "smc.h"

#define MFApplicationIdentifier     "com.lobotomo.iMacFanControl"


@implementation MFDaemon

- (id)init
{
    if (self = [super init]) {
        mustSavePrefs = NO;

        // set some sane defaults
        lowerTempThreshold = MFLowerTempThresholdBottom;
        upperTempThreshold = MFUpperTempThresholdTop;
        //
        CPUfanBaseRPM = MFMinCPUfanRPM;
        HDfanBaseRPM = MFMinHDfanRPM;
        DVDfanBaseRPM = MFMinDVDfanRPM;
        //
        CPUfanTargetRPM = MFMinCPUfanRPM;
        HDfanTargetRPM = MFMinHDfanRPM;
        DVDfanTargetRPM = MFMinDVDfanRPM;
    }
    return self;
}

// save the preferences
- (void)storePreferences
{
    CFPreferencesSetValue(CFSTR("CPUfanBaseRPM"), (CFPropertyListRef)[NSNumber numberWithInt:CPUfanBaseRPM],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    CFPreferencesSetValue(CFSTR("HDfanBaseRPM"), (CFPropertyListRef)[NSNumber numberWithInt:HDfanBaseRPM],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    CFPreferencesSetValue(CFSTR("DVDfanBaseRPM"), (CFPropertyListRef)[NSNumber numberWithInt:DVDfanBaseRPM],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);

    CFPreferencesSetValue(CFSTR("lowerTempThreshold"), (CFPropertyListRef)[NSNumber numberWithFloat:lowerTempThreshold],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    CFPreferencesSetValue(CFSTR("upperTempThreshold"), (CFPropertyListRef)[NSNumber numberWithFloat:upperTempThreshold],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);

    CFPreferencesSetValue(CFSTR("showTempsAsFahrenheit"), (CFPropertyListRef)[NSNumber numberWithBool:showTempsAsFahrenheit],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);

    CFPreferencesSynchronize(CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
}

// retrieve the preferences
- (void)readPreferences
{
    CFPropertyListRef property;

    property = CFPreferencesCopyValue(CFSTR("lowerTempThreshold"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) lowerTempThreshold = [(NSNumber *)property floatValue];

    property = CFPreferencesCopyValue(CFSTR("upperTempThreshold"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) upperTempThreshold = [(NSNumber *)property floatValue];

    property = CFPreferencesCopyValue(CFSTR("CPUfanBaseRPM"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) CPUfanBaseRPM = [(NSNumber *)property intValue];

    property = CFPreferencesCopyValue(CFSTR("HDfanBaseRPM"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) HDfanBaseRPM = [(NSNumber *)property intValue];

    property = CFPreferencesCopyValue(CFSTR("DVDfanBaseRPM"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) DVDfanBaseRPM = [(NSNumber *)property intValue];

    property = CFPreferencesCopyValue(CFSTR("showTempsAsFahrenheit"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) showTempsAsFahrenheit = [(NSNumber *)property boolValue];

    // sanity/safety check in case of corrupted preferences
    if (lowerTempThreshold < MFLowerTempThresholdBottom) lowerTempThreshold = MFLowerTempThresholdBottom;
    if (lowerTempThreshold > MFLowerTempThresholdTop) lowerTempThreshold = MFLowerTempThresholdBottom + ((MFLowerTempThresholdTop - MFLowerTempThresholdBottom) / 2);
    //
    if (upperTempThreshold < MFUpperTempThresholdBottom) upperTempThreshold = MFUpperTempThresholdBottom;
    if (upperTempThreshold > MFUpperTempThresholdTop) upperTempThreshold = MFUpperTempThresholdBottom + ((MFUpperTempThresholdTop - MFUpperTempThresholdBottom) / 2);
    //
    if (CPUfanBaseRPM < MFMinCPUfanRPM) CPUfanBaseRPM = MFMinCPUfanRPM;
    if (HDfanBaseRPM < MFMinHDfanRPM) HDfanBaseRPM = MFMinHDfanRPM;
    if (DVDfanBaseRPM < MFMinDVDfanRPM) DVDfanBaseRPM = MFMinDVDfanRPM;
    //
    if (CPUfanTargetRPM < MFMinCPUfanRPM) CPUfanTargetRPM = MFMinCPUfanRPM;
    if (HDfanTargetRPM < MFMinHDfanRPM) HDfanTargetRPM = MFMinHDfanRPM;
    if (DVDfanTargetRPM < MFMinDVDfanRPM) DVDfanTargetRPM = MFMinDVDfanRPM;
    //
    if (CPUfanBaseRPM > MFMaxCPUfanRPM) CPUfanBaseRPM = MFMinCPUfanRPM + ((MFMaxCPUfanRPM - MFMinCPUfanRPM) / 2);
    if (HDfanBaseRPM > MFMaxHDfanRPM) HDfanBaseRPM = MFMinHDfanRPM + ((MFMaxHDfanRPM - MFMinHDfanRPM) / 2);
    if (DVDfanBaseRPM > MFMaxDVDfanRPM) DVDfanBaseRPM = MFMinDVDfanRPM + ((MFMaxDVDfanRPM - MFMinDVDfanRPM) / 2);
    //
    if (CPUfanTargetRPM > MFMaxCPUfanRPM) CPUfanTargetRPM = MFMinCPUfanRPM + ((MFMaxCPUfanRPM - MFMinCPUfanRPM) / 2);
    if (HDfanTargetRPM > MFMaxHDfanRPM) HDfanTargetRPM = MFMinHDfanRPM + ((MFMaxHDfanRPM - MFMinHDfanRPM) / 2);
    if (DVDfanTargetRPM > MFMaxDVDfanRPM) DVDfanTargetRPM = MFMinDVDfanRPM + ((MFMaxDVDfanRPM - MFMinDVDfanRPM) / 2);
}

// this gets called when the application starts
- (void)start
{
    [self readPreferences];
    [NSTimer scheduledTimerWithTimeInterval:MFUpdateInterval target:self selector:@selector(timer:) userInfo:nil repeats:YES];
}

// control loop called by NSTimer at the specified interval
- (void)timer:(NSTimer *)aTimer
{
    double CPUtemp;
    double GPUtemp;
    double HDtemp;
    double DVDtemp;

    int CPUfanRPM;
    int HDfanRPM;
    int DVDfanRPM;

    int adjustmentRPM;
    int alignmentRPM;

    SMCOpen();

    CPUtemp = SMCGetTemperature(SMC_KEY_CPU_TEMP);
    GPUtemp = SMCGetTemperature(SMC_KEY_GPU_TEMP);
    HDtemp = SMCGetTemperature(SMC_KEY_HD_TEMP);
    DVDtemp = SMCGetTemperature(SMC_KEY_DVD_TEMP);

    CPUfanRPM = SMCGetFanRPM(SMC_KEY_CPU_FAN_RPM);
    HDfanRPM = SMCGetFanRPM(SMC_KEY_HD_FAN_RPM);
    DVDfanRPM = SMCGetFanRPM(SMC_KEY_DVD_FAN_RPM);


    // ----- compute the desired/target CPU fan speed

    // determine the desired/target RPM indicated by the preference settings
    if (CPUtemp < lowerTempThreshold) {
        CPUfanTargetRPM = CPUfanBaseRPM;
    } else if (CPUtemp > upperTempThreshold) {
        CPUfanTargetRPM = MFMaxCPUfanRPM;
    } else {
        CPUfanTargetRPM = CPUfanBaseRPM +
                          ((floor(CPUtemp + 0.5) - lowerTempThreshold) /
                          (upperTempThreshold - lowerTempThreshold) *
                          (MFMaxCPUfanRPM - CPUfanBaseRPM));
    }
    if (MFDebugCPU) NSLog (@"CPUtemp = %f\n", CPUtemp);
    if (MFDebugCPU) NSLog (@"rounded CPUtemp = %f\n", floor(CPUtemp + 0.5));
    if (MFDebugCPU) NSLog (@"ideal CPUfanTargetRPM = %d\n", CPUfanTargetRPM);
    if (MFDebugCPU) NSLog (@"CPUfanRPM = %d\n", CPUfanRPM);

    // correct the fan speed if we don't have a fan-speed value/reading from smc
    if (CPUfanRPM == 0) {
        CPUfanRPM = CPUfanTargetRPM;
        if (MFDebugCPU) NSLog (@"corrected CPUfanRPM = %d\n", CPUfanRPM);
    } /*else { // pretend fan speed is aligned to nearest MFRPMspeedStep boundary
        alignmentRPM = (CPUfanRPM % MFRPMspeedStep);
        CPUfanRPM = CPUfanRPM - alignmentRPM;
        if (alignmentRPM > (MFRPMspeedStep / 2)) CPUfanRPM = CPUfanRPM + MFRPMspeedStep;
        if (MFDebugCPU) NSLog (@"aligned CPUfanRPM = %d\n", CPUfanRPM);
    } */

    // determine difference between fan's desired/target RPM and the current RPM
    adjustmentRPM = (CPUfanTargetRPM - CPUfanRPM);
    if (abs(adjustmentRPM) < (MFRPMspeedStep / 2)) {
        adjustmentRPM = 0; // current speed's within 1/2 of an RPM step, leave it
    } else { // ensure the +/- difference is not greater than the maximum allowed
        if (adjustmentRPM < -MFMaxRPMspeedStep) adjustmentRPM = -MFMaxRPMspeedStep;
        if (adjustmentRPM > MFMaxRPMspeedStep) adjustmentRPM = MFMaxRPMspeedStep;
    }
    if (MFDebugCPU) NSLog (@"adjustmentRPM = %d\n", adjustmentRPM);

    // compute the new desired/target RPM
    CPUfanTargetRPM = CPUfanRPM + adjustmentRPM;
    if (MFDebugCPU) NSLog (@"next CPUfanTargetRPM = %d\n", CPUfanTargetRPM);

    // set the desired/target RPM to the nearest MFRPMspeedStep-RPM boundary
    alignmentRPM = (CPUfanTargetRPM % MFRPMspeedStep);
    CPUfanTargetRPM = CPUfanTargetRPM - alignmentRPM;
    if (alignmentRPM > (MFRPMspeedStep / 2)) CPUfanTargetRPM = CPUfanTargetRPM + MFRPMspeedStep;
    if (MFDebugCPU) NSLog (@"%d RPM-aligned next CPUfanTargetRPM = %d\n", MFRPMspeedStep, CPUfanTargetRPM);

    // when decreasing speed, don't target below the set "slowest fan speed" and
    // when increasing speeds, don't target above the maximum safe fan speed
    if (MFDebugCPU) NSLog (@"CPUfanBaseRPM = %d\n", CPUfanBaseRPM);
    if ((adjustmentRPM < 1) && (CPUfanTargetRPM < CPUfanBaseRPM)) CPUfanTargetRPM = CPUfanBaseRPM;
    if (CPUfanTargetRPM > MFMaxCPUfanRPM) CPUfanTargetRPM = MFMaxCPUfanRPM;
    if (MFDebugCPU) NSLog (@"final next CPUfanTargetRPM = %d\n\n", CPUfanTargetRPM);


    // ----- compute the desired/target HD fan speed

    // determine the desired/target RPM indicated by the preference settings
    if (HDtemp < lowerTempThreshold) {
        HDfanTargetRPM = HDfanBaseRPM;
    } else if (HDtemp > upperTempThreshold) {
        HDfanTargetRPM = MFMaxHDfanRPM;
    } else {
        HDfanTargetRPM = HDfanBaseRPM +
                         ((floor(HDtemp + 0.5) - lowerTempThreshold) /
                         (upperTempThreshold - lowerTempThreshold) *
                         (MFMaxHDfanRPM - HDfanBaseRPM));
    }
    if (MFDebugHD) NSLog (@"HDtemp = %f\n", HDtemp);
    if (MFDebugHD) NSLog (@"rounded HDtemp = %f\n", floor(HDtemp + 0.5));
    if (MFDebugHD) NSLog (@"ideal HDfanTargetRPM = %d\n", HDfanTargetRPM);
    if (MFDebugHD) NSLog (@"HDfanRPM = %d\n", HDfanRPM);

    // correct the fan speed if we don't have a fan-speed value/reading from smc
    if (HDfanRPM == 0) {
        HDfanRPM = HDfanTargetRPM;
        if (MFDebugHD) NSLog (@"corrected HDfanRPM = %d\n", HDfanRPM);
    } /*else { // pretend fan speed is aligned to nearest MFRPMspeedStep boundary
        alignmentRPM = (HDfanRPM % MFRPMspeedStep);
        HDfanRPM = HDfanRPM - alignmentRPM;
        if (alignmentRPM > (MFRPMspeedStep / 2)) HDfanRPM = HDfanRPM + MFRPMspeedStep;
        if (MFDebugHD) NSLog (@"aligned HDfanRPM = %d\n", HDfanRPM);
    } */

    // determine difference between fan's desired/target RPM and the current RPM
    adjustmentRPM = (HDfanTargetRPM - HDfanRPM);
    if (abs(adjustmentRPM) < (MFRPMspeedStep / 2)) {
        adjustmentRPM = 0; // current speed's within 1/2 of an RPM step, leave it
    } else { // ensure the +/- difference is not greater than the maximum allowed
        if (adjustmentRPM < -MFMaxRPMspeedStep) adjustmentRPM = -MFMaxRPMspeedStep;
        if (adjustmentRPM > MFMaxRPMspeedStep) adjustmentRPM = MFMaxRPMspeedStep;
    }
    if (MFDebugHD) NSLog (@"adjustmentRPM = %d\n", adjustmentRPM);

    // compute the new desired/target RPM
    HDfanTargetRPM = HDfanRPM + adjustmentRPM;
    if (MFDebugHD) NSLog (@"next HDfanTargetRPM = %d\n", HDfanTargetRPM);

    // set the desired/target RPM to the nearest MFRPMspeedStep-RPM boundary
    alignmentRPM = (HDfanTargetRPM % MFRPMspeedStep);
    HDfanTargetRPM = HDfanTargetRPM - alignmentRPM;
    if (alignmentRPM > (MFRPMspeedStep / 2)) HDfanTargetRPM = HDfanTargetRPM + MFRPMspeedStep;
    if (MFDebugHD) NSLog (@"%d RPM-aligned next HDfanTargetRPM = %d\n", MFRPMspeedStep, HDfanTargetRPM);

    // when decreasing speed, don't target below the set "slowest fan speed" and
    // when increasing speeds, don't target above the maximum safe fan speed
    if (MFDebugHD) NSLog (@"HDfanBaseRPM = %d\n", HDfanBaseRPM);
    if ((adjustmentRPM < 1) && (HDfanTargetRPM < HDfanBaseRPM)) HDfanTargetRPM = HDfanBaseRPM;
    if (HDfanTargetRPM > MFMaxHDfanRPM) HDfanTargetRPM = MFMaxHDfanRPM;
    if (MFDebugHD) NSLog (@"final next HDfanTargetRPM = %d\n\n", HDfanTargetRPM);


    // ----- compute the desired/target DVD fan speed

    // determine the desired/target RPM indicated by the preference settings
    if (DVDtemp < lowerTempThreshold) {
        DVDfanTargetRPM = DVDfanBaseRPM;
    } else if (DVDtemp > upperTempThreshold) {
        DVDfanTargetRPM = MFMaxDVDfanRPM;
    } else {
        DVDfanTargetRPM = DVDfanBaseRPM +
                          ((floor(DVDtemp + 0.5) - lowerTempThreshold) /
                          (upperTempThreshold - lowerTempThreshold) *
                          (MFMaxDVDfanRPM - DVDfanBaseRPM));
    }
    if (MFDebugDVD) NSLog (@"DVDtemp = %f\n", DVDtemp);
    if (MFDebugDVD) NSLog (@"rounded DVDtemp = %f\n", floor(DVDtemp + 0.5));
    if (MFDebugDVD) NSLog (@"ideal DVDfanTargetRPM = %d\n", DVDfanTargetRPM);
    if (MFDebugDVD) NSLog (@"DVDfanRPM = %d\n", DVDfanRPM);

    // correct the fan speed if we don't have a fan-speed value/reading from smc
    if (DVDfanRPM == 0) {
        DVDfanRPM = DVDfanTargetRPM;
        if (MFDebugDVD) NSLog (@"corrected DVDfanRPM = %d\n", DVDfanRPM);
    } /*else { // pretend fan speed is aligned to nearest MFRPMspeedStep boundary
        alignmentRPM = (DVDfanRPM % MFRPMspeedStep);
        DVDfanRPM = DVDfanRPM - alignmentRPM;
        if (alignmentRPM > (MFRPMspeedStep / 2)) DVDfanRPM = DVDfanRPM + MFRPMspeedStep;
        if (MFDebugDVD) NSLog (@"aligned DVDfanRPM = %d\n", DVDfanRPM);
    } */

    // determine difference between fan's desired/target RPM and the current RPM
    adjustmentRPM = (DVDfanTargetRPM - DVDfanRPM);
    if (abs(adjustmentRPM) < (MFRPMspeedStep / 2)) {
        adjustmentRPM = 0; // current speed's within 1/2 of an RPM step, leave it
    } else { // ensure the +/- difference is not greater than the maximum allowed
        if (adjustmentRPM < -MFMaxRPMspeedStep) adjustmentRPM = -MFMaxRPMspeedStep;
        if (adjustmentRPM > MFMaxRPMspeedStep) adjustmentRPM = MFMaxRPMspeedStep;
    }
    if (MFDebugDVD) NSLog (@"adjustmentRPM = %d\n", adjustmentRPM);

    // compute the new desired/target RPM
    DVDfanTargetRPM = DVDfanRPM + adjustmentRPM;
    if (MFDebugDVD) NSLog (@"next DVDfanTargetRPM = %d\n", DVDfanTargetRPM);

    // set the desired/target RPM to the nearest MFRPMspeedStep-RPM boundary
    alignmentRPM = (DVDfanTargetRPM % MFRPMspeedStep);
    DVDfanTargetRPM = DVDfanTargetRPM - alignmentRPM;
    if (alignmentRPM > (MFRPMspeedStep / 2)) DVDfanTargetRPM = DVDfanTargetRPM + MFRPMspeedStep;
    if (MFDebugDVD) NSLog (@"%d RPM-aligned next DVDfanTargetRPM = %d\n", MFRPMspeedStep, DVDfanTargetRPM);

    // when decreasing speed, don't target below the set "slowest fan speed" and
    // when increasing speeds, don't target above the maximum safe fan speed
    if (MFDebugDVD) NSLog (@"DVDfanBaseRPM = %d\n", DVDfanBaseRPM);
    if ((adjustmentRPM < 1) && (DVDfanTargetRPM < DVDfanBaseRPM)) DVDfanTargetRPM = DVDfanBaseRPM;
    if (DVDfanTargetRPM > MFMaxDVDfanRPM) DVDfanTargetRPM = MFMaxDVDfanRPM;
    if (MFDebugDVD) NSLog (@"final next DVDfanTargetRPM = %d\n\n", DVDfanTargetRPM);


    // request the "target" fan speeds
    SMCSetFanRPM(SMC_KEY_CPU_FAN_RPM_MIN, CPUfanTargetRPM);
    SMCSetFanRPM(SMC_KEY_HD_FAN_RPM_MIN, HDfanTargetRPM);
    SMCSetFanRPM(SMC_KEY_DVD_FAN_RPM_MIN, DVDfanTargetRPM);

    SMCClose();

    // save preferences, if required
    if (mustSavePrefs) {
        [self storePreferences];
        mustSavePrefs = NO;
    }
}

// accessors & setters
// -----------------------------------------------------------------------------
- (float)lowerTempThreshold
{
    return lowerTempThreshold;
}
- (float)upperTempThreshold
{
    return upperTempThreshold;
}
//
- (void)setLowerTempThreshold:(float)newLowerTempThreshold
{
    lowerTempThreshold = newLowerTempThreshold;
    mustSavePrefs = YES;
}
- (void)setUpperTempThreshold:(float)newUpperTempThreshold
{
    upperTempThreshold = newUpperTempThreshold;
    mustSavePrefs = YES;
}
// -------------------------------------
- (BOOL)showTempsAsFahrenheit
{
    return showTempsAsFahrenheit;
}
- (void)setShowTempsAsFahrenheit:(BOOL)newShowTempsAsFahrenheit
{
    showTempsAsFahrenheit = newShowTempsAsFahrenheit;
    mustSavePrefs = YES;
}
// -----------------------------------------------------------------------------
- (int)CPUfanBaseRPM
{
    return CPUfanBaseRPM;
}
- (int)HDfanBaseRPM
{
    return HDfanBaseRPM;
}
- (int)DVDfanBaseRPM
{
    return DVDfanBaseRPM;
}
//
- (void)setCPUfanBaseRPM:(int)newCPUfanBaseRPM
{
    CPUfanBaseRPM = newCPUfanBaseRPM;
    mustSavePrefs = YES;
}
- (void)setHDfanBaseRPM:(int)newHDfanBaseRPM
{
    HDfanBaseRPM = newHDfanBaseRPM;
    mustSavePrefs = YES;
}
- (void)setDVDfanBaseRPM:(int)newDVDfanBaseRPM
{
    DVDfanBaseRPM = newDVDfanBaseRPM;
    mustSavePrefs = YES;
}
// -----------------------------------------------------------------------------
- (int)CPUfanTargetRPM
{
    return CPUfanTargetRPM;
}
- (int)HDfanTargetRPM
{
    return HDfanTargetRPM;
}
- (int)DVDfanTargetRPM
{
    return DVDfanTargetRPM;
}
// -----------------------------------------------------------------------------
- (void)CPUtemp:(float *)CPUtemp
        GPUtemp:(float *)GPUtemp
        HDtemp:(float *)HDtemp
        DVDtemp:(float *)DVDtemp
        CPUfanRPM:(int *)CPUfanRPM
        HDfanRPM:(int *)HDfanRPM
        DVDfanRPM:(int *)DVDfanRPM
{
    SMCOpen();
    if (CPUtemp) *CPUtemp = SMCGetTemperature(SMC_KEY_CPU_TEMP);
    if (GPUtemp) *GPUtemp = SMCGetTemperature(SMC_KEY_GPU_TEMP);
    if (HDtemp) *HDtemp = SMCGetTemperature(SMC_KEY_HD_TEMP);
    if (DVDtemp) *DVDtemp = SMCGetTemperature(SMC_KEY_DVD_TEMP);
    if (CPUfanRPM) *CPUfanRPM = SMCGetFanRPM(SMC_KEY_CPU_FAN_RPM);
    if (HDfanRPM) *HDfanRPM = SMCGetFanRPM(SMC_KEY_HD_FAN_RPM);
    if (DVDfanRPM) *DVDfanRPM = SMCGetFanRPM(SMC_KEY_DVD_FAN_RPM);
    SMCClose();
}

@end

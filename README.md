## DCMTK

To compile you'll need to first checkout the correct tagged version of the 3.6.1 series.

>> DCMTK-3.6.1_20150629

You need to apply the patch for Multiframe from support issue 661.

  [1]: http://support.dcmtk.org/redmine/issues/661

The issue is, that while the multiframe support is from this patch, the version we want is a slightly different version that keeps some of the old functionality. I also modified some of the CMake scripts work slightly better within the Android build environment.

    patch -p1 << DCMTK-3.6.1_20150629.patch

Then modify and run the dcmtk-build.sh script. The script expects Android emulators with the names nexus19-arm and nexus19-x86. If you use different versions or naming you'll need to change that. The Android SDK tools are needed for this build script as is a per-desired-architecture version of the libiconv and libcharset libraries. Adding additional support like PNG and JPEG will need to be added, but for our purposes is unnecessary.

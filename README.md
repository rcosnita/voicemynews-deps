# Summary

This branch provides v8 android library compiled without i18n support and without snapshot.

It also holds the flags used when the library was built in case someone is interested to reproduce all binaries. See **v8_flags.source** file.

## ARM compilation

At the moment, V8 does not compile well on ARM (ARM64 works as expected) family of processors. In order to make it work, you need to patch v8 with the following code:

```c++
// src/base/debug/stack_trace_android.cc:35
_Unwind_Reason_Code TraceStackFrame(_Unwind_Context* context, void* arg) {
#ifndef __arm__
  StackCrawlState* state = static_cast<StackCrawlState*>(arg);
  uintptr_t ip = _Unwind_GetIP(context);

  // The first stack frame is this function itself.  Skip it.
  if (ip != 0 && !state->have_skipped_self) {
    state->have_skipped_self = true;
    return _URC_NO_REASON;
  }

  state->frames[state->frame_count++] = ip;
  if (state->frame_count >= state->max_depth)
    return _URC_END_OF_STACK;
#endif
  return _URC_NO_REASON;
} 
```

## Compilation

Except the above mentioned exception it is fairly simple to compile v8 for Android. Just follow the steps below on an Ubuntu machine:

```bash
sudo apt-get install -y curl libc6-dev g++-multilib
# setup v8 according to official guide then move on to the next steps
cd v8
# follow the steps from make sections
# execute build_fat once you are done with previous step
./build_fat.sh <arm|arm64|ia32|x64> # build_fat.sh is part of this repo and must be copied under v8 folder.
```

### Make ARM64

```bash
export LDFLAGS="-lc++"
export ANDROID_NDK=/home/cosnita/work/ndk12b
make -j4 snapshot=off i18nsupport=off android_arm64.release
```

### Make ARM

```bash
sudo apt-get install gcc-4.9-arm-linux-gnueabihf g++-4.9-arm-linux-gnueabihf g++-4.9-multilib-arm-linux-gnueabihf libc6-armhf-cross
nano ./tools/cross_build_gcc.sh

# paste the content from the cross_build_gcc.sh snippet.

./tools/cross_build_gcc.sh /usr/bin/arm-linux-gnueabihf- arm.release arm_version=7 armfpu=vfpv3-d16 armfloatabi=hard armthumb=on i18nsupport=off snapshot=off -j4
```

```bash
# cross_build_gcc.sh snippet
export CXX=$1g++-4.9
export AR=$1ar
export RANLIB=$1ranlib
export CC=$1gcc-4.9
export LD=$1g++-4.9
export LINK=$1g++-4.9
```

### Make x86

```bash
export LDFLAGS="-lc++"
export ANDROID_NDK=/home/cosnita/work/ndk12b
make -j4 snapshot=off i18nsupport=off android_ia32.release
```

### Make x86_64

```bash
export LDFLAGS="-lc++"
export ANDROID_NDK=/home/cosnita/work/ndk12b
make -j4 snapshot=off i18nsupport=off android_x64.release
```
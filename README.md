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

```
sudo apt-get install -y curl libc6-dev g++-multilib
# setup v8 according to official guide then move on to the next steps
cd v8
make -j4 snapshot=off i18nsupport=off android_<arm|arm64|ia32|x64>.release
./build_fat.sh <arm|arm64|ia32|x64> # build_fat.sh is part of this repo and must be copied under v8 folder.
```
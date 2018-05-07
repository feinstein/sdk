// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef RUNTIME_PLATFORM_ATOMIC_LINUX_H_
#define RUNTIME_PLATFORM_ATOMIC_LINUX_H_

#if !defined RUNTIME_PLATFORM_ATOMIC_H_
#error Do not include atomic_linux.h directly. Use atomic.h instead.
#endif

#if !defined(HOST_OS_LINUX)
#error This file should only be included on Linux builds.
#endif

namespace dart {

inline uintptr_t AtomicOperations::FetchAndIncrement(uintptr_t* p) {
  return __sync_fetch_and_add(p, 1);
}

inline intptr_t AtomicOperations::FetchAndIncrement(intptr_t* p) {
  return __sync_fetch_and_add(p, 1);
}

inline void AtomicOperations::IncrementBy(intptr_t* p, intptr_t value) {
  __sync_fetch_and_add(p, value);
}

inline void AtomicOperations::IncrementInt64By(int64_t* p, int64_t value) {
  // Some ARM implementations require 8-byte alignment for atomic access but
  // not non-atomic access.
  ASSERT((reinterpret_cast<uword>(p) % 8) == 0);
  __sync_fetch_and_add(p, value);
}

inline uintptr_t AtomicOperations::FetchAndDecrement(uintptr_t* p) {
  return __sync_fetch_and_sub(p, 1);
}

inline intptr_t AtomicOperations::FetchAndDecrement(intptr_t* p) {
  return __sync_fetch_and_sub(p, 1);
}

inline void AtomicOperations::DecrementBy(intptr_t* p, intptr_t value) {
  __sync_fetch_and_sub(p, value);
}

inline uword AtomicOperations::CompareAndSwapWord(uword* ptr,
                                                  uword old_value,
                                                  uword new_value) {
  return __sync_val_compare_and_swap(ptr, old_value, new_value);
}

inline uint32_t AtomicOperations::CompareAndSwapUint32(uint32_t* ptr,
                                                       uint32_t old_value,
                                                       uint32_t new_value) {
  return __sync_val_compare_and_swap(ptr, old_value, new_value);
}

}  // namespace dart

#endif  // RUNTIME_PLATFORM_ATOMIC_LINUX_H_

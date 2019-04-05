// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer/src/test_utilities/package_mixin.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/driver_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MustCallSuperTest);
  });
}

@reflectiveTest
class MustCallSuperTest extends DriverResolutionTest with PackageMixin {
  setUp() {
    super.setUp();
    addMetaPackage();
  }

  test_containsSuperCall() async {
    await assertNoErrorsInCode(r'''
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  void a() {}
}
class C extends A {
  @override
  void a() {
    super.a(); // OK
  }
}
''');
  }

  test_fromExtendingClass() async {
    await assertErrorsInCode(r'''
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  void a() {}
}
class B extends A {
  @override
  void a() {}
}
''', [HintCode.MUST_CALL_SUPER]);
  }

  test_fromExtendingClass_abstractImplementation() async {
    await assertNoErrorsInCode(r'''
import 'package:meta/meta.dart';
abstract class A {
  @mustCallSuper
  void a();
}
class B extends A {
  @override
  void a() {}
}
''');
  }

  test_fromExtendingClass_separateImplementation() async {
    await assertErrorsInCode(r'''
import 'package:meta/meta.dart';
abstract class A {
  @mustCallSuper
  void a();
}
class B implements A {
  void a() {}
}
class C extends B {
  @override
  void a() {}
}
''', [HintCode.MUST_CALL_SUPER]);
  }

  test_fromInterface() async {
    await assertNoErrorsInCode(r'''
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  void a() {}
}
class C implements A {
  @override
  void a() {}
}
''');
  }

  test_fromMixin() async {
    await assertErrorsInCode(r'''
import 'package:meta/meta.dart';
class Mixin {
  @mustCallSuper
  void a() {}
}
class C with Mixin {
  @override
  void a() {}
}
''', [HintCode.MUST_CALL_SUPER]);
  }

  test_indirectlyInherited() async {
    await assertErrorsInCode(r'''
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  void a() {}
}
class C extends A {
  @override
  void a() {
    super.a();
  }
}
class D extends C {
  @override
  void a() {}
}
''', [HintCode.MUST_CALL_SUPER]);
  }

  test_indirectlyInheritedFromInterface() async {
    await assertErrorsInCode(r'''
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  void a() {}
}
class C implements A {
  @override
  void a() {}
}
class D extends C {
  @override
  void a() {}
}
''', [HintCode.MUST_CALL_SUPER]);
  }

  test_indirectlyInheritedMultiply_fromFirstInterface() async {
    await assertErrorsInCode(r'''
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  void a() {}
}
class B {
  void a() {}
}
// Here's the crux: D needs to call super because of C's _first_ interface.
class C implements A, B {
  @override
  void a() {}
}
class D extends C {
  @override
  void a() {}
}
''', [HintCode.MUST_CALL_SUPER]);
  }

  test_indirectlyInheritedMultiply_fromInterfaceAfterFirst() async {
    await assertErrorsInCode(r'''
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  void a() {}
}
class B {
  void a() {}
}
// Here's the crux: D needs to call super because of one of C's interfaces, but
// not the first.
class C implements B, A {
  @override
  void a() {}
}
class D extends C {
  @override
  void a() {}
}
''', [HintCode.MUST_CALL_SUPER]);
  }

  test_indirectlyInheritedFromMixin() async {
    await assertErrorsInCode(r'''
import 'package:meta/meta.dart';
class Mixin {
  @mustCallSuper
  void b() {}
}
class C extends Object with Mixin {}
class D extends C {
  @override
  void b() {}
}
''', [HintCode.MUST_CALL_SUPER]);
  }

  test_indirectlyInheritedFromMixinConstraint() async {
    await assertErrorsInCode(r'''
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  void a() {}
}
mixin C on A {
  @override
  void a() {}
}
''', [HintCode.MUST_CALL_SUPER]);
  }

  test_overriddenWithFuture() async {
    // https://github.com/flutter/flutter/issues/11646
    await assertNoErrorsInCode(r'''
import 'dart:async';
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  Future<Null> bar() => new Future<Null>.value();
}
class C extends A {
  @override
  Future<Null> bar() {
    final value = super.bar();
    return value.then((Null _) {
      return null;
    });
  }
}
''');
  }

  test_overriddenWithFuture2() async {
    // https://github.com/flutter/flutter/issues/11646
    await assertNoErrorsInCode(r'''
import 'dart:async';
import 'package:meta/meta.dart';
class A {
  @mustCallSuper
  Future<Null> bar() => new Future<Null>.value();
}
class C extends A {
  @override
  Future<Null> bar() {
    return super.bar().then((Null _) {
      return null;
    });
  }
}
''');
  }
}

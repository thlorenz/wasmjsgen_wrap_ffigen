import 'binding.dart';
/*
import 'type.dart';
import 'utils.dart';
import 'writer.dart';
*/

class Writer {
  String generate() {
    return '';
  }
}

// TODO: copy most from ffi writer minus the render
/*
  late String _wasmInstance;
  late String _dartAsync;
  late String _dartConvert;
  late String _dartTyped;
  late String _wasmInterop;
  late String _opaqueClass;
  late String _jsBigIntToInt;
  late String _jsBigInt;

  String get jsBigIntToInt => _jsBigIntToInt;
  String get jsBigInt => _jsBigInt;

  WasmJsWriter({
    required List<Binding> lookUpBindings,
    required List<Binding> noLookUpBindings,
    required String className,
    required bool dartBool,
    String? classDocComment,
    String? header,
  }) : super(
            lookUpBindings: lookUpBindings,
            noLookUpBindings: noLookUpBindings,
            className: className,
            dartBool: dartBool,
            classDocComment: classDocComment,
            header: header) {
    _wasmInstance = _resolveNameConflict(
      name: '_wasmInstance',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _dartAsync = _resolveNameConflict(
      name: 'dart_async',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _dartConvert = _resolveNameConflict(
      name: 'dart_convert',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _dartTyped = _resolveNameConflict(
      name: 'dart_typed',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _wasmInterop = _resolveNameConflict(
      name: 'wasm_interop',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _opaqueClass = _resolveNameConflict(
      name: 'Opaque',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _jsBigInt = _resolveNameConflict(
      name: 'JsBigInt',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _jsBigIntToInt = _resolveNameConflict(
      name: 'jsBigIntToInt',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
  }

  /// Resolved name conflict using [makeUnique] and marks the result as used in
  /// all [markUsed].
  String _resolveNameConflict({
    required String name,
    required UniqueNamer makeUnique,
    List<UniqueNamer> markUsed = const [],
  }) {
    final s = makeUnique.makeUnique(name);
    for (final un in markUsed) {
      un.markUsed(s);
    }
    return s;
  }

  @override
  String generate() {
    final s = StringBuffer();

    // Reset unique names to initial state.
    resetUniqueNamersNamers();

    s.writeln(
        '// ignore_for_file: non_constant_identifier_names, unused_import, camel_case_types\n');

    // Write file header (if any).
    if (header != null) {
      s.write(header);
      s.write('\n');
    }

    // Write auto generated declaration.
    s.write(makeDoc(
        'AUTO GENERATED FILE, DO NOT EDIT.\n\nGenerated by `package:ffigen`.'));
    s.write('\n');

    // Imports
    s.write("import 'dart:async' as $_dartAsync;\n");
    s.write("import 'dart:convert' as $_dartConvert;\n");
    s.write("import 'dart:typed_data' as $_dartTyped;\n");
    s.write(
        "import 'package:wasm_interop/wasm_interop.dart' as $_wasmInterop;\n");

    if (classDocComment != null) {
      s.write(makeDartDoc(classDocComment!));
    }

    // Write Library wrapper class
    s.write('class $className{\n');
    s.write('/// The symbol lookup function.\n');

    // Write lookup function
    s.write('T $lookupFuncIdentifier<T>(String name) {\n');
    s.write('  return $_wasmInstance.functions[name] as T;\n');
    s.write('}\n');

    // Instance field and constructor
    s.write('final $_wasmInterop.Instance $_wasmInstance;\n');
    s.write('$className(this._wasmInstance);\n\n');

    // Function declarations
    if (lookUpBindings.isNotEmpty) {
      for (final b in lookUpBindings) {
        s.writeln('\n  // --- ${b.name} ---');
        s.write(b.toBindingString(this).string);
      }
    }

    // Static Initializers
    s.write('\n');
    s.write('static $className? _instance;\n');
    s.write('static $className get instance {\n');
    s.write('  assert(_instance != null,\n');
    s.write('      "need to $className.init() before accessing instance");\n');
    s.write('  return _instance!;\n');
    s.write('}\n');
    s.write('\n');
    s.write(
        'static Future<$className> init($_dartTyped.Uint8List moduleData) async {\n');
    s.write(
        '  final $_wasmInterop.Instance instance = await $_wasmInterop.Instance.fromBytesAsync(moduleData);\n');
    s.write('  _instance = $className(instance);\n');
    s.write('  return $className.instance;\n');
    s.write('}\n');

    s.write('}\n\n');

    // Struct declarations
    if (noLookUpBindings.isNotEmpty) {
      for (final b in noLookUpBindings) {
        s.write(b.toBindingString(this).string);
      }
    }

    writePointerAndOpaque(s);
    writeBuiltInNatives(s);
    writeJsBigIntConverter(s);
    return s.toString();
  }

  void writePointerAndOpaque(StringBuffer s) {
    s.writeln('// Base for Native Types and Opaque Structs');
    s.writeln('class $_opaqueClass {');
    s.writeln('  final int _address;');
    s.writeln('  int get address => _address;');
    s.writeln('  $_opaqueClass(this._address);');
    s.writeln('}\n');

    s.writeln('// FFI Pointer Replacement');
    s.writeln('class Pointer<T extends $_opaqueClass> {');
    s.writeln('  final T _opaque;');
    s.writeln('  Pointer._(this._opaque);');
    s.writeln('  factory Pointer.fromAddress(T opaque) {');
    s.writeln('    return Pointer._(opaque);');
    s.writeln('  }');
    s.writeln('  int get address => _opaque.address;');
    s.writeln('}');
  }

  void writeBuiltInNatives(StringBuffer s) {
    s.writeln('// Dart FFI Native Types');

    final uniquePrims = Type.primitives.values.map((x) => x.c).toSet();
    for (final prim in uniquePrims) {
      s.writeln('class $prim extends $_opaqueClass {');
      s.writeln('  $prim(int address): super(address);');
      s.writeln('}');
    }
  }

  void writeJsBigIntConverter(StringBuffer s) {
    s.writeln('typedef $_jsBigInt = String;\n');
    s.writeln('// Only reliable way I found to convert JS BigInt to int.');
    s.writeln('// It is used to convert uint64_t and int64_t.');
    s.writeln(
        '// Dart int is 64bit (signed). A u64 will not fit if it is larger than max i64.');
    s.writeln('// However in most scenarios we will not hit this max value.');
    s.writeln('//   Max u64 is 18,446,744,073,709,551,615');
    s.writeln('//   Max i64 is  9,223,372,036,854,775,807');
    s.writeln(
        '// Thus we take a shortcut to avoid having to deal with Dart BigInt.');
    s.writeln('int $_jsBigIntToInt($_jsBigInt n) {');
    s.writeln('  return int.parse(n);');
    s.writeln('}');
  }
}
*/

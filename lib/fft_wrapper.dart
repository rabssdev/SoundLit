import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef FFTWPlan = Pointer<Void>;
typedef FFTWComplex = Pointer<Double>;

class FFTW {
  late DynamicLibrary _lib;

  FFTW() {
    if (Platform.isWindows) {
      _lib = DynamicLibrary.open('libfftw3-3.dll');
    } else if (Platform.isMacOS) {
      _lib = DynamicLibrary.open('libfftw3.dylib');
    } else if (Platform.isLinux) {
      _lib = DynamicLibrary.open('libfftw3.so.3');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  late final Pointer<FFTWComplex> Function(int n) fftw_alloc_complex = _lib
      .lookup<NativeFunction<Pointer<FFTWComplex> Function(Int32)>>(
          'fftw_alloc_complex')
      .asFunction();

  late final FFTWPlan Function(
    Pointer<FFTWComplex> input,
    Pointer<FFTWComplex> output,
    int direction,
    int flags,
  ) fftw_plan_dft_1d = _lib
      .lookup<
          NativeFunction<
              FFTWPlan Function(Pointer<FFTWComplex>, Pointer<FFTWComplex>,
                  Int32, Int32)>>('fftw_plan_dft_1d')
      .asFunction();

  late final void Function(FFTWPlan) fftw_execute = _lib
      .lookup<NativeFunction<Void Function(FFTWPlan)>>('fftw_execute')
      .asFunction();

  late final void Function(FFTWPlan) fftw_destroy_plan = _lib
      .lookup<NativeFunction<Void Function(FFTWPlan)>>('fftw_destroy_plan')
      .asFunction();

  late final void Function(Pointer<FFTWComplex>) fftw_free = _lib
      .lookup<NativeFunction<Void Function(Pointer<FFTWComplex>)>>('fftw_free')
      .asFunction();
}

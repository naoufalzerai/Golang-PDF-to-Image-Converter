import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:ffi/src/utf8.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

typedef get_key_func = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8>); // FFI fn signature
typedef pdf2jpeg = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8>); // Dart fn signature
final dylib = ffi.DynamicLibrary.open('./pdf2jpeg.so');

final pdf2jpeg PdfToJpeg =
    dylib.lookup<ffi.NativeFunction<get_key_func>>('PdfToJpeg').asFunction();

void main(List<String> args) async {
  var addressOf = PdfToJpeg("test.pdf".toNativeUtf8());
  var path = addressOf.toDartString();

  final pdf = pw.Document();

  final file = File("example.pdf");

  final List<FileSystemEntity> images = Directory(path)
      .listSync(recursive: false)
      .toList()
    ..sort((l, r) => l.path.compareTo(r.path));
  for (var img in images) {
    final image = pw.MemoryImage(
      File(img.path).readAsBytesSync(),
    );

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          child: pw.Image(image),
        );
      },
      pageFormat:
          PdfPageFormat(image.width.toDouble(), image.height.toDouble()),
    ));
  }

  await file.writeAsBytes(await pdf.save());
}

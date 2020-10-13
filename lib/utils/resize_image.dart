import 'dart:ui';
import 'dart:typed_data';

import 'package:famedlysdk/famedlysdk.dart';
import 'package:native_imaging/native_imaging.dart' as native;

Future<MatrixImageFile> resizeImage(MatrixImageFile file,
    {int max = 800}) async {
  await native.init();

  var nativeImg = native.Image();
  try {
    try {
      await nativeImg.loadEncoded(file.bytes);
      file.width = nativeImg.width;
      file.height = nativeImg.height;
    } on UnsupportedError {
      final dartCodec = await instantiateImageCodec(file.bytes);
      final dartFrame = await dartCodec.getNextFrame();
      file.width = dartFrame.image.width;
      file.height = dartFrame.image.height;
      final rgbaData = await dartFrame.image.toByteData();
      final rgba = Uint8List.view(
          rgbaData.buffer, rgbaData.offsetInBytes, rgbaData.lengthInBytes);
      dartFrame.image.dispose();
      dartCodec.dispose();
      nativeImg.loadRGBA(file.width, file.height, rgba);
    }

    if (file.width > max || file.height > max) {
      var w = max, h = max;
      if (file.width > file.height) {
        h = max * file.height ~/ file.width;
      } else {
        w = max * file.width ~/ file.height;
      }

      final scaledImg =
          await nativeImg.resample(w, h, native.Transform.lanczos);
      nativeImg.free();
      nativeImg = scaledImg;
    }

    final jpegBytes = await nativeImg.toJpeg(75);
    file.blurhash = await nativeImg.toBlurhash(3, 3);

    return (jpegBytes.length > file.size ~/ 2)
        ? null
        : MatrixImageFile(
            bytes: jpegBytes,
            name: 'thumbnail.jpg',
            mimeType: 'image/jpeg',
            width: nativeImg.width,
            height: nativeImg.height,
          );
  } finally {
    nativeImg.free();
  }
}

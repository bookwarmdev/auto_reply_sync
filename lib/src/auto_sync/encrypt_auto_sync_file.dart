import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart';

class EncryptAutoSyncFile {

  static final BlockCipher _aes = AESFastEngine();
  // static final _cipher = CFBBlockCipher(AESFastEngine(), AESFastEngine().blockSize);
  static final _cipher = CBCBlockCipher(AESFastEngine());

  static Uint8List _generateAutoSyncKey() {
    final key = Uint8List(32);
    final secureRandomKey =  FortunaRandom();
    secureRandomKey.seed(KeyParameter(Uint8List.fromList(key)));
    return key;
  }

  static String _getASCII(String source) {
    var encode = ascii.encode(source);
    return ascii.decode(encode);
  }
  
  static String _getUtf8(value) {
    var encoded = utf8.encode(value);
    var decoded = utf8.decode(encoded);
    return decoded;
  }

  static Future<Uint8List> _generateAutoSyncIV() async {
    Directory? _directory;
    _directory = await getTemporaryDirectory();
    // var iv = Uint8List.fromList(_getASCII("Hyk(h2#A)3LquJsG").codeUnits);
    // var random =X Random.secure();
    // var iv = Uint8List(16);
    // // for (var i = 0; i < 16; i++) {
    // //   iv[i] = random.nextInt(256);
    // // }
    var iv = Uint8List.fromList(_directory.absolute.path.toString().split(".").first.codeUnits);
    return iv;
  }

  static Uint8List _pad(Uint8List src, int blockSize) {
    var pad = PKCS7Padding();
    pad.init(null);

    int padLength = blockSize - (src.length % blockSize);
    var out = Uint8List(src.length + padLength)..setAll(0, src);
    pad.addPadding(out, src.length);

    return out;
  }

  static Uint8List _unPad(Uint8List src) {
    var pad = PKCS7Padding();
    pad.init(null);

    int padLength = pad.padCount(src);
    int len = src.length - padLength;

    return Uint8List(len)..setRange(0, len, src);
  }

  static Uint8List _processBlocks(BlockCipher cipher, Uint8List inp) {
    var out = Uint8List(inp.lengthInBytes);

    for (var offset = 0; offset < inp.lengthInBytes;) {
      var len = cipher.processBlock(inp, offset, out, offset);
      offset += len;
    }

    return out;
  }

  // Future<String> encrypt(String plainText) async {
  //   final key = _generateAutoSyncKey();
  //   final iv = await _generateAutoSyncIV();
  //
  //   var params = ParametersWithIV(KeyParameter(key), iv);
  //
  //
  //   BlockCipher encrypter = CFBBlockCipher(_aes, _aes.blockSize);
  //   encrypter.init(true, params);
  //
  //   Uint8List plainBytes = Uint8List.fromList(utf8.encode(plainText));
  //   Uint8List paddedText = _pad(plainBytes, _aes.blockSize);
  //   Uint8List encryptedBytes = _processBlocks(encrypter, paddedText);
  //
  //   String encryptedBase64 = base64.encode(encryptedBytes);
  //
  //   return encryptedBase64;
  // }

  static Future<String> encryptAutoSyncFile(
      {required String inputFile,}
      ) async {
    print(await getTemporaryDirectory().asStream().first.toString().matchAsPrefix("/"));
    final myKey = _generateAutoSyncKey();
    final myIv = await _generateAutoSyncIV();

    final params = ParametersWithIV<KeyParameter>(KeyParameter(myKey), myIv);

    if (params != null) {
      _cipher.init(true, params);

      final inputBytes = Uint8List.fromList(_getUtf8(inputFile).codeUnits);
      Uint8List paddedText = _pad(inputBytes, _aes.blockSize);
      Uint8List encryptedBytes = _processBlocks(_cipher, paddedText);

      String encryptedBase64 = base64.encode(encryptedBytes);
      return encryptedBase64;
    } else {
      throw  Exception("Encryption parameters an not initialized");
    }
  }
  //

  static Future<String> decryptAutoSyncFile(
      {required String inputFile,}
      ) async {
    final myKey = _generateAutoSyncKey();
    final myIv = await _generateAutoSyncIV();

    // if (params != null) {
      final inputBytes = base64.decode(_getUtf8(inputFile));

      Uint8List cipherIvBytes =
      Uint8List(inputBytes.length + myIv.length)
        ..setAll(0, myIv)
        ..setAll(myIv.length, inputBytes);

    final params = ParametersWithIV<KeyParameter>(KeyParameter(myKey), myIv);
      _cipher.init(false, params);

      int cipherLength = cipherIvBytes.length - _aes.blockSize;
      final cipherBytes = Uint8List(cipherLength)..setRange(0, cipherLength, cipherIvBytes, _aes.blockSize);
      final decryptedBytes = _processBlocks(_cipher, cipherBytes);
      final unPaddedText = _unPad(decryptedBytes);
      String decryptedBase64 = String.fromCharCodes(unPaddedText);
      return decryptedBase64;
    // } else {
    //   throw  Exception("Encryption parameters an not initialized");
    // }
  }
}

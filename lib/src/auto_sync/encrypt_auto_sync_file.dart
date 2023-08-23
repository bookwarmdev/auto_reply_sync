// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:pointycastle/export.dart';

// class EncryptAutoSyncFile {
//   final _secureRandomKey = FortunaRandom();
//   final _cipher = StreamCipher("Salsa20");

//   Uint8List _geberateAutoSyncKey() {
//     final key = Uint8List(32);
//     _secureRandomKey.seed(KeyParameter(Uint8List.fromList([1, 2, 3, 4])));
//     // _secureRandomKey.nextBytes(key.length);
//     for (var i = 0; i < key.length; i++) {
//     key[i] = _secureRandomKey.nextInt(256);
//   }
//     return key;
//   }

//   // Uint8List Key() {
//   //   final secureRandom = FortunaRandom();
//   //   final key = Uint8List(32);
//   //   secureRandom.seed(KeyParameter(Uint8List.fromList([1, 2, 3])));
//   //   secureRandom.nextBytes(key.length);
//   //   return key;
//   // }

//   Uint8List _generateAutoSyncIV() {
//     final iv = Uint8List(16);
//     _secureRandomKey.seed(KeyParameter(Uint8List.fromList([5, 6, 6, 8])));
//     // _secureRandomKey.nextBytes(iv.length);
//     return iv;
//   }

//   Future encryptAutoSyncFile({required File inputFile}) async {
//     final myKey = _geberateAutoSyncKey();
//     final myIv = _generateAutoSyncIV();
//     final params = ParametersWithIV<KeyParameter>(KeyParameter(myKey), myIv);
//     _cipher.init(true, params);

//     final inputBytes = await inputFile.readAsBytes();
//     final encryptedBytes = _cipher.process(Uint8List.fromList(inputBytes));
//     log(encryptedBytes.toString());
//   }

//   Future decryptAutoSyncFile(
//       {required File inputFile, required File outputFile}) async {
//     final myKey = _geberateAutoSyncKey();
//     final myIv = _generateAutoSyncIV();
//     final params = ParametersWithIV<KeyParameter>(KeyParameter(myKey), myIv);
//     _cipher.init(false, params);

//     final encryptedBytes = await inputFile.readAsBytes();
//     final decryptedBytes = _cipher.process(Uint8List.fromList(encryptedBytes));
//     log(decryptedBytes.toString());
//     // await outputFile.writeAsBytes(decryptedBytes);
//   }
// }

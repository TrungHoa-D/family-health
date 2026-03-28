import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart' as mime;

extension StringNullableExtension on String? {
  /// Returns `true` if this nullable char sequence is either `null` or empty.
  bool isNullOrEmpty() {
    return (this ?? '').isEmpty;
  }

  /// Returns `false` if this nullable char sequence is either `null` or empty.
  bool isNotNullOrEmpty() {
    return (this ?? '').isNotEmpty;
  }
}

extension StringExtension on String {
  Size getSize(TextStyle? style) {
    final textPainter = TextPainter(
      text: TextSpan(text: this, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  String? guessMimeTypeFromBase64() {
    // Compute the minimum length of the base64 string we need to decode
    // [mime.defaultMagicNumbersMaxLength] bytes.  base64 encodes 3 bytes of
    // binary data to 4 characters.
    final minimumBase64Length =
        (mime.defaultMagicNumbersMaxLength / 3).ceil() * 4;
    return mime.lookupMimeType(
      '',
      headerBytes: base64.decode(substring(0, minimumBase64Length)),
    );
  }
}

extension RemoveSignExtension on String {
  static const _coreCharacter = [
    'a',
    'A',
    'e',
    'E',
    'o',
    'O',
    'u',
    'U',
    'i',
    'I',
    'd',
    'D',
    'y',
    'Y',
  ];
  static final _signedCharacterRegex = [
    RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'),
    RegExp(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]'),
    RegExp(r'[èéẹẻẽêềếệểễ]'),
    RegExp(r'[ÈÉẸẺẼÊỀẾỆỂỄ]'),
    RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'),
    RegExp(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]'),
    RegExp(r'[ùúụủũưừứựửữ]'),
    RegExp(r'[ÙÚỤỦŨƯỪỨỰỬỮ]'),
    RegExp(r'[ìíịỉĩ]'),
    RegExp(r'[ÌÍỊỈĨ]'),
    RegExp(r'đ'),
    RegExp(r'Đ'),
    RegExp(r'[ỳýỵỷỹ]'),
    RegExp(r'[ỲÝỴỶỸ]'),
  ];

  String unSigned() {
    var result = this;
    for (var i = 0; i < _coreCharacter.length; i++) {
      result = result.replaceAll(_signedCharacterRegex[i], _coreCharacter[i]);
    }
    return result;
  }

  bool compareUnSigned(String other) {
    return toLowerCase().unSigned().contains(other.toLowerCase().unSigned());
  }
}

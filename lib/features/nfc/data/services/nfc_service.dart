import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';
import 'dart:typed_data';

class NFCService {
  static Future<bool> isAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  static Future<void> startNFCSession({
    required Function(String) onTagRead,
    required Function(String) onError,
  }) async {
    try {
      if (!await isAvailable()) {
        onError('NFC is not available on this device');
        return;
      }

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndefTag = Ndef.from(tag);
            if (ndefTag == null) {
              onError('Tag is not NDEF formatted');
              return;
            }

            final ndefMessage = await ndefTag.read();
            String tagData = '';

            for (final record in ndefMessage.records) {
              if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown ||
                  record.typeNameFormat == NdefTypeNameFormat.media) {
                tagData += String.fromCharCodes(record.payload);
              }
            }

            if (tagData.isNotEmpty) {
              onTagRead(tagData);
            } else {
              onError('No readable data found on tag');
            }
          } catch (e) {
            onError('Error reading NFC tag: $e');
          } finally {
            NfcManager.instance.stopSession();
          }
        },
        onError: (error) => onError('NFC session error: $error'),
      );
    } catch (e) {
      onError('Error starting NFC session: $e');
    }
  }

  static Future<void> writeNFCTag(String data) async {
    try {
      if (!await isAvailable()) {
        throw Exception('NFC is not available on this device');
      }

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndef = Ndef.from(tag);
            if (ndef == null) {
              throw Exception('Tag is not NDEF formatted');
            }

            if (!ndef.isWritable) {
              throw Exception('Tag is not writable');
            }

            final record = NdefRecord(
              typeNameFormat: NdefTypeNameFormat.nfcWellknown,
              type: Uint8List.fromList([0x54]), // 'T' for text record
              identifier: Uint8List(0),
              payload: Uint8List.fromList([
                0x02, // UTF8
                ...utf8.encode(data),
              ]),
            );

            final message = NdefMessage([record]);
            await ndef.write(message);
          } catch (e) {
            throw Exception('Error writing to NFC tag: $e');
          } finally {
            NfcManager.instance.stopSession();
          }
        },
      );
    } catch (e) {
      throw Exception('Error starting NFC write session: $e');
    }
  }

  static Future<void> stopNFCSession() async {
    await NfcManager.instance.stopSession();
  }
}

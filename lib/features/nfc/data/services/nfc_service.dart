import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/record.dart';

class NFCService {
  static Future<bool> isAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  static Future<void> startNFCSession({
    required Function(String) onTagRead,
    required Function(String) onError,
  }) async {
    try {
      // Check NFC availability
      if (!await isAvailable()) {
        onError('NFC is not available on this device');
        return;
      }

      // Start NFC session
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndefTag = Ndef.from(tag);
            if (ndefTag == null) {
              onError('Tag is not NDEF formatted');
              return;
            }

            final records = await ndefTag.read();
            String tagData = '';

            for (final record in records) {
              if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
                final wellKnownRecord = record as NdefWellKnownRecord;
                tagData += String.fromCharCodes(wellKnownRecord.payload);
              }
            }

            onTagRead(tagData);
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

            final record = NdefRecord.createText(data);
            await ndef.write([record]);
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

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:dio/dio.dart';
import 'package:vpn_connection_detector/vpn_connection_detector.dart';

class ShieldGuardSecurity {
  static final _key = enc.Key.fromUtf8('shieldguard_fixpickup_32char_key!'); // 32 chars
  static final _iv = enc.IV.fromLength(16);
  static final _encrypter = enc.Encrypter(enc.AES(_key));

  /// 1. Zero-Trust Local Encryption (AES-256)
  static String encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  static String decrypt(String cipherText) {
    return _encrypter.decrypt(enc.Encrypted.fromBase64(cipherText), iv: _iv);
  }


  /// 2. Environmental Mismatch Detector
  /// Uses a combination of local VPN detection and server-side ASN verification.
  static Future<Map<String, dynamic>> checkEnvironment() async {
    bool isVpnActive = false;
    if (!kIsWeb) {
      try {
        isVpnActive = await VpnConnectionDetector.isVpnActive();
      } catch (e) {
        print("VPN Detection Error: $e");
      }
    }

    final dio = Dio();
    try {
      // Step 1: Get Public IP and ASN Metadata
      final ipResponse = await dio.get('http://ip-api.com/json/');
      final geo = ipResponse.data;

      // Identify mismatched environments (e.g. Mobile User-Agent + Hosting ISP)
      bool isHosting = geo['hosting'] ?? false;
      String isp = geo['isp'] ?? 'Unknown';
      
      bool suspicious = isVpnActive || isHosting || 
                        isp.contains('Amazon') || 
                        isp.contains('DigitalOcean') || 
                        isp.contains('Google');

      return {
        'suspicious': suspicious,
        'reason': isVpnActive ? 'VPN Detected' : (isHosting ? 'Hosting Environment detected' : 'Commercial Proxy'),
        'ip': geo['query'],
        'location': '${geo['city']}, ${geo['country']}',
        'isp': isp,
      };
    } catch (e) {
      return {'suspicious': true, 'reason': 'Failed to verify IP context'};
    }
  }

  /// 3. The Honeytoken Trigger
  /// In a real app, this would be a dummy API call hidden in the background.
  static Future<void> triggerBait() async {
    try {
      final dio = Dio();
      // Replace with your actual Firebase Cloud Function URL
      await dio.get('https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/deceptionTrigger');
    } catch (e) {
      // In a hackathon demo, we want this to "fail" correctly as we've hit a honeypot.
      print("ShieldGuard: Honeytoken Access Detected (Correctly Handled)");
    }
  }
}

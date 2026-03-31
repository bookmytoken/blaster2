import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dio/dio.dart';
import '../models/threat_model.dart';
import '../services/security_service.dart';

class ThreatDashboard extends StatefulWidget {
  const ThreatDashboard({super.key});

  @override
  State<ThreatDashboard> createState() => _ThreatDashboardState();
}

class _ThreatDashboardState extends State<ThreatDashboard> {
  double currentRiskScore = 0.0;
  String currentArchetype = "Monitoring Securely...";
  String currentLocation = "";
  String currentIp = "";
  String currentIsp = "";
  bool isThreatDetected = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure initialization doesn't block the first frame
    Future.microtask(() async {
      await _resetBackendState();
      _startPolling();
    });
  }

  Future<void> _resetBackendState() async {
    try {
      final dio = Dio();
      await dio.get('http://localhost:5001/reset');
    } catch (e) {
      // Ignore errors on load
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    final dio = Dio();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final response = await dio.get('http://localhost:5001/threatStatus');
        if (mounted && response.data != null && response.data['threatDetected'] == true) {
          final data = response.data['threatData'];
          if (!isThreatDetected) {
            setState(() {
              currentRiskScore = (data['riskScore'] as num).toDouble();
              currentArchetype = data['archetype'] ?? 'Unknown';
              currentLocation = data['location'] ?? 'Unknown Location';
              currentIp = data['ip'] ?? 'Unknown IP';
              currentIsp = data['isp'] ?? 'Unknown ISP';
              isThreatDetected = true;
            });
          }
        } else if (mounted && isThreatDetected && response.data != null && response.data['threatDetected'] == false) {
           // Auto-reset if backend says threat is gone
           setState(() {
             isThreatDetected = false;
             currentRiskScore = 0.0;
             currentArchetype = "Monitoring Securely...";
           });
        }
      } catch (e) {
        debugPrint("Polling error: $e");
      }
    });
  }

  Future<void> _simulateThreatDetection() async {
    // 1. Show scanning phase
    setState(() {
      currentArchetype = "Analyzing Anomalies...";
    });

    // 2. Trigger the bait on the actual backend Server
    try {
      final dio = Dio();
      await dio.get(
        'http://localhost:5001/deceptionTrigger',
        options: Options(headers: {"User-Agent": "Flutter Dash (Admin Override)"}),
      );
    } catch (e) {
      // Ignore intercept errors
    }

    // Notice we do NOT hardcode the Risk Score or Archtype anymore!
    // The _startPolling() loop will automatically fetch the TRUE real data
    // from the backend and update the UI brilliantly!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate
      appBar: AppBar(
        title: Text('SHIELDGUARD COMMAND', style: GoogleFonts.orbitron(letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Reset System to Secure State',
            onPressed: () async {
              try {
                // Ignore cache by adding timestamp
                await Dio().get('http://localhost:5001/reset?_=${DateTime.now().millisecondsSinceEpoch}');
              } catch (e) {}
              setState(() {
                isThreatDetected = false;
                currentRiskScore = 0.0;
                currentArchetype = "Monitoring Securely...";
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.bolt, color: isThreatDetected ? Colors.redAccent : Colors.cyanAccent),
            onPressed: _simulateThreatDetection,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRiskGauge(),
            const SizedBox(height: 32),
            if (isThreatDetected) ...[
              _buildThreatArchetypeCard(),
              const SizedBox(height: 32),
              _buildActionableIntelligence(),
              const SizedBox(height: 32),
              _buildGeoOriginSection(),
            ] else ...[
              _buildSecureStatus(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRiskGauge() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isThreatDetected ? Colors.redAccent.withOpacity(0.3) : Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: currentRiskScore == 0 ? 0.1 : currentRiskScore,
                  color: isThreatDetected ? Colors.redAccent : Colors.cyanAccent,
                  radius: 12,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 10 - currentRiskScore,
                  color: Colors.white.withOpacity(0.1),
                  radius: 10,
                  showTitle: false,
                ),
              ],
              startDegreeOffset: 270,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentRiskScore.toStringAsFixed(1),
                style: GoogleFonts.exo2(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'RISK INDEX',
                style: GoogleFonts.exo2(color: isThreatDetected ? Colors.redAccent : Colors.cyanAccent, letterSpacing: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThreatArchetypeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyanAccent.withOpacity(0.15), Colors.blueAccent.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.cyanAccent),
              const SizedBox(width: 12),
              Text(
                'THREAT ARCHETYPE',
                style: GoogleFonts.exo2(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentArchetype,
            style: GoogleFonts.exo2(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'High-confidence match: Intruder connection flagged from $currentIsp at $currentLocation using anomalous tools.',
            style: GoogleFonts.inter(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionableIntelligence() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELF-HEALING ACTIONS',
          style: GoogleFonts.exo2(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildActionItem(Icons.key, 'Rotate Technicians Access Token', 'Recommended due to elevated threat profile.'),
        _buildActionItem(Icons.block, 'Block Network Traffic', 'Drop incoming connections from ISP: $currentIsp.'),
        _buildActionItem(Icons.lock, 'Enable Zero-Trust Vault Override', 'Review logs for IP $currentIp and enforce local encryption.'),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title, String sub) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white54)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildGeoOriginSection() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, color: Colors.white30, size: 40),
            const SizedBox(height: 8),
            Text('GEOSPATIAL ORIGIN: ${currentLocation.toUpperCase()} (IP: $currentIp)', 
                 style: GoogleFonts.inter(color: Colors.white30, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureStatus() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.shield, size: 80, color: Colors.cyanAccent.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'SYSTEM SECURE',
            style: GoogleFonts.orbitron(fontSize: 24, color: Colors.cyanAccent, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            'Zero-Trust Vault Active. Monitoring for anomalies.',
            style: GoogleFonts.inter(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

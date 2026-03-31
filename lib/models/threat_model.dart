class ThreatLog {
  final String ip;
  final String userAgent;
  final DateTime timestamp;
  final GeoLocation geo;
  final double riskScore;
  final String archetype;
  final String status;

  ThreatLog({
    required this.ip,
    required this.userAgent,
    required this.timestamp,
    required this.geo,
    required this.riskScore,
    required this.archetype,
    required this.status,
  });

  factory ThreatLog.fromJson(Map<String, dynamic> json) {
    return ThreatLog(
      ip: json['ip'] ?? 'Unknown',
      userAgent: json['userAgent'] ?? 'Unknown',
      timestamp: json['timestamp']?.toDate() ?? DateTime.now(),
      geo: GeoLocation.fromJson(json['geo'] ?? {}),
      riskScore: (json['riskScore'] ?? 0.0).toDouble(),
      archetype: json['archetype'] ?? 'Unknown',
      status: json['status'] ?? 'unknown',
    );
  }
}

class GeoLocation {
  final String city;
  final String country;
  final String isp;
  final double lat;
  final double lon;

  GeoLocation({
    required this.city,
    required this.country,
    required this.isp,
    required this.lat,
    required this.lon,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      city: json['city'] ?? 'Unknown',
      country: json['country'] ?? 'Unknown',
      isp: json['isp'] ?? 'Unknown',
      lat: (json['lat'] ?? 0).toDouble(),
      lon: (json['lon'] ?? 0).toDouble(),
    );
  }
}

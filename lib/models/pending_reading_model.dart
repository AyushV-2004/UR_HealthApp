class PendingReading {
  final String mac;
  final Map<String, dynamic> data;

  PendingReading({
    required this.mac,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'mac': mac,
    'data': data,
  };

  static PendingReading fromJson(Map json) {
    return PendingReading(
      mac: json['mac'],
      data: Map<String, dynamic>.from(json['data']),
    );
  }
}


// temperory container to store reading until internet comes back
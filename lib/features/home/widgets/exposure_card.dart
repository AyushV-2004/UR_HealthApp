// import 'package:flutter/material.dart';
// class ExposureCard extends StatelessWidget {
//   final int pm25;
//   final int pm10;
//
//   const ExposureCard({
//     super.key,
//     required this.pm25,
//     required this.pm10,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final exposureValue = ((pm25 + pm10) / 2).round();
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEAF8FF),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFF66CCFF)),
//       ),
//       child: Column(
//         children: [
//           const Text("Ur Exposure", style: TextStyle(fontSize: 18)),
//           const SizedBox(height: 12),
//           Text(
//             exposureValue.toString(),
//             style: const TextStyle(
//               fontSize: 36,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Text("Unit"),
//         ],
//       ),
//     );
//   }
// }












import 'package:flutter/material.dart';

class ExposureCard extends StatelessWidget {
  final int pm25;
  final int pm10;

  const ExposureCard({
    super.key,
    required this.pm25,
    required this.pm10,
  });

  int get exposureValue => ((pm25 + pm10) / 2).round();

  String get status {
    if (exposureValue <= 50) return "Good";
    if (exposureValue <= 100) return "Moderate";
    return "Bad";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 322,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F6FF), // Figma bg
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF66CCFF),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// 🔝 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Ur Exposure",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Monitoring over the last 24 hours",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),

              /// 🔵 LIVE BADGE
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF1FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFF2196F3),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Live",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// 🟢 CENTER CIRCLE
          Container(
            height: 120,
            width: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2ED47A),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exposureValue.toString(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Unit",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          /// 🔻 STATUS
          Column(
            children: [
              Text(
                status,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Higher than yesterday",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

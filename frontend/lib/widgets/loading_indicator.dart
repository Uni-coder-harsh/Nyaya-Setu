import 'package:flutter/material.dart';

class NyayaLoadingIndicator extends StatelessWidget {
  const NyayaLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Nyaya-Setu is searching BNS Knowledge Base...",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Skeleton line 1
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          // Skeleton line 2
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

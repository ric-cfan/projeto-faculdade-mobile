import 'package:flutter/material.dart';

class CompactCardView extends StatelessWidget {
  final double balance;
  final Function onTap;

  const CompactCardView({
    super.key,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[850]!, width: 1),
        ),
        child: Stack(
          children: [
            // Card label
            Positioned(
              left: 16,
              bottom: 16,
              child: Row(
                children: [
                  const Text(
                    'Cards',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            
            // More button
            Positioned(
              right: 8,
              bottom: 16,
              child: IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                onPressed: () => onTap(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
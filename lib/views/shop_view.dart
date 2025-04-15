// Simple structure for product data
import 'package:flutter/material.dart';

import '../widgets/sidebar.dart';

class ProductTier {
  final String name;
  final String description;
  final String price;
  final IconData icon;
  final List<String> features;
  final Color accentColor; // Optional: Color for icon/accents per tier

  const ProductTier({
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.features,
    required this.accentColor,
  });
}

// Define the spoof product tiers
final List<ProductTier> shopProducts = [
  ProductTier(
    name: 'Portal Lite',
    description: 'Entry-level processing for smaller models and basic tasks.',
    price: '€79.99',
    icon: Icons.speed_outlined,
    features: ['Runs < 7B models', '4GB+ RAM Systems', 'Offline Ready'],
    accentColor: Colors.lightBlueAccent.shade400,
  ),
  ProductTier(
    name: 'Portal Pro',
    description: 'Balanced performance for standard models and moderate usage.',
    price: '€129.99',
    icon: Icons.developer_board, // Changed icon
    features: ['Runs 7B-13B models', '8GB+ RAM Recommended', 'Enhanced Security'],
    accentColor: Colors.deepPurpleAccent.shade100,
  ),
   ProductTier(
    name: 'Portal Max',
    description: 'High-end local processing for demanding models and frequent use.',
    price: '€199.99',
    icon: Icons.memory, // Changed icon
    features: ['Runs 13B+ models', '16GB+ RAM Recommended', 'Hardware Acceleration'],
     accentColor: Colors.greenAccent.shade400,
  ),
   ProductTier(
    name: 'Portal DevKit',
    description: 'Unlocked developer version for custom model deployment and research.',
    price: 'Contact Us',
    icon: Icons.build_circle_outlined,
    features: ['Custom Model Support', 'Debugging Tools', 'Community Access'],
    accentColor: Colors.orangeAccent.shade400,
  ),
];

class ShopView extends StatelessWidget {
  const ShopView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
     final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Consistent background
      // appBar: AppBar( // AppBar can be used, or integrate title into body
      //   title: const Text('Portal Store'),
      //   backgroundColor: const Color(0xFF1A1A1A),
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      // ),
      body: Row( // Use Row for Sidebar + Content layout
        children: [
          const Sidebar(), // Include sidebar
          Expanded(
            child: ListView.builder(
              // Add padding for visual spacing, account for potential AppBar space if not using one
               padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
              itemCount: shopProducts.length,
              itemBuilder: (context, index) {
                final product = shopProducts[index];
                return _buildProductCard(context, theme, colorScheme, product);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build each product card
  Widget _buildProductCard(BuildContext context, ThemeData theme, ColorScheme colorScheme, ProductTier product) {
    return Card(
       color: const Color(0xFF1C1C1C), // Dark card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
         side: BorderSide(color: product.accentColor.withOpacity(0.3), width: 1), // Subtle accent border
      ),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
         padding: const EdgeInsets.all(16.0),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                // Product Icon
                Icon(
                   product.icon,
                   size: 48,
                   color: product.accentColor, // Use accent color for the icon
                 ),
                 const SizedBox(width: 16),
                 // Product Name and Description
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         product.name,
                         style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         product.description,
                         style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                       ),
                     ],
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),

             // Features (using Chips)
             if (product.features.isNotEmpty)
               Wrap(
                 spacing: 8.0, // Gap between chips
                 runSpacing: 4.0, // Gap between lines
                 children: product.features.map((feature) => Chip(
                   label: Text(feature),
                   labelStyle: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                   backgroundColor: colorScheme.primary.withOpacity(0.15),
                   side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                   visualDensity: VisualDensity.compact,
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                 )).toList(),
               ),

             const Divider(color: Colors.white24, height: 30),

             // Price and Action Button Row
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 // Price
                 Text(
                   product.price,
                   style: theme.textTheme.titleLarge?.copyWith(
                      color: product.accentColor, // Use accent color for price
                      fontWeight: FontWeight.bold
                   ),
                 ),
                 // Action Button
                 ElevatedButton(
                   onPressed: () {
                     // Placeholder action for the spoof shop
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('More details for ${product.name} coming soon!')),
                     );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: product.accentColor.withOpacity(0.8), // Button color based on accent
                     foregroundColor: Colors.black87, // Text color on button
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                   ),
                   child: const Text('Learn More'),
                 ),
               ],
             ),
           ],
         ),
       ),
     );
  }
}
import 'package:flutter/material.dart';

class ModalMenu extends StatelessWidget {
  const ModalMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Text(
              'Menu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Divider(color: Colors.white70),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('User Page', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/user');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shop, color: Colors.white),
              title: const Text('Shop Page', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shop');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Options Page', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/options');
              },
            ),
          ],
        ),
      ),
    );
  }
}

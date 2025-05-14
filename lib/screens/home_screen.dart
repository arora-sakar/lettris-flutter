import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.grey,
            width: double.infinity,
            height: 50,
            child: const Center(
              child: Text(
                "World of Web games",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/lettris');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Lettris',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

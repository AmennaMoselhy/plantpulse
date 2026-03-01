import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  String fullName;
  Profile({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0XFF1F1F1F),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                ],
              ),
              SizedBox(height: 24),
              Stack(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/bigProfilePic.png',
                      width: size.width * 0.24,
                      height: size.height * 0.111,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(0XFF399B25),
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {},
                        child: Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(fullName,
              style: TextStyle(
                color: Color(0XFF1F1F1F),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),),
              SizedBox(height: 24),
              Container(padding: EdgeInsets.all(16),)
            ],
          ),
        ),
      ),
    );
  }
}

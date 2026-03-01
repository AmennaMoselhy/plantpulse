import 'package:flutter/material.dart';

class HomePageContent extends StatelessWidget {
  String firstName;
  HomePageContent({super.key, required this.firstName});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: size.height * 0.0296,
        right: size.width * 0.064,
        left: size.width * 0.064,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 48),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi $firstName!",
                    style: TextStyle(
                      color: Color(0XFF1F1F1F),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Check Your Plants’ Health Summary",
                    style: TextStyle(
                      color: Color(0XFF4A4A4A),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Spacer(),
              ClipOval(
                child: Image.asset(
                  'assets/profilePic.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.0296),
          Text(
            "Statistics",
            style: TextStyle(
              color: Color(0XFF1F1F1F),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0XFFEBF5E9),
              border: Border.all(color: Color(0XFF61AF51), width: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Image.asset('assets/totalScans.png'),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Scans",
                      style: TextStyle(
                        color: Color(0XFF1F1F1F),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "0",
                      style: TextStyle(
                        color: Color(0XFF1F1F1F),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0XFFEBF5E9),
                    border: Border.all(color: Color(0XFF61AF51), width: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/health.png'),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Healthy",
                            style: TextStyle(
                              color: Color(0XFF1F1F1F),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "0",
                            style: TextStyle(
                              color: Color(0XFF1F1F1F),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0XFFFFF4E9),
                    border: Border.all(color: Color(0XFFFFA352), width: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/disease.png'),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Diseased",
                            style: TextStyle(
                              color: Color(0XFF1F1F1F),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "0",
                            style: TextStyle(
                              color: Color(0XFF1F1F1F),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0XFFEBF5E9),
              border: Border.all(color: Color(0XFF61AF51), width: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Image.asset('assets/didYouKnow.png'),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Did you know?",
                        style: TextStyle(
                          color: Color(0XFF1F1F1F),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Overwatering causes yellow leaves . Water only when the top 2 inches of soil feel dry!",
                        style: TextStyle(
                          color: Color(0XFF1F1F1F),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

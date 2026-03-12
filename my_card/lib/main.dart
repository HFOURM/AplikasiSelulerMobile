import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.teal,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  "images/profile.jpg",
                ),
              ),
              Text("Hammam Mudhoffar",
                style: GoogleFonts.pacifico(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
              Text(
                "ANDROID DEVELOPER",
                style: GoogleFonts.sourceSans3(
                  fontSize: 15,
                  color: Colors.teal.shade100,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                )),
              SizedBox(
                height: 20,
                width: 150,
                child: Divider(
                  color: Colors.teal.shade100
                ),
              ),
              Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 25,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.teal,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "085572727",
                          style: GoogleFonts.sourceSans3(
                            fontSize: 17,
                            color: Colors.teal.shade900
                            ),
                        ),
                      ],
                    ),
                  ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                ),
                margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.teal,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "hammam.mudhoffar@gmail.com",
                      style: GoogleFonts.sourceSans3(
                        fontSize: 17,
                        color: Colors.teal.shade900
                      ),
                    )
                  ],
                )
              )
            ],
          )
        ),
      ),
    );
  }
}

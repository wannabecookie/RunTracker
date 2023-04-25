import 'package:flutter/material.dart';

import 'package:run_tracker/utils/Color.dart';

class WelcomeDialogScreen extends StatefulWidget {
  @override
  _WelcomeDialogScreenState createState() => _WelcomeDialogScreenState();
}

class _WelcomeDialogScreenState extends State<WelcomeDialogScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 0, 0, 0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            child: Container(
              padding: EdgeInsets.only(
                  left: 18.0, right: 18.0, top: 150.00, bottom: 200),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 100.0,
                    width: 100.0,
                    child: Image.asset(
                      'assets/images/1.png',
                    ),
                  ),
                  Divider(
                    height: 30,
                  ),
                  Image.network(
                    'https://img.freepik.com/free-photo/young-fitness-woman-runner_1150-10576.jpg?w=2000&t=st=1676915653~exp=1676916253~hmac=7a9fbde89e9294b4047ceb4e52c7b436747cc3e000b8c9aeca3123088594acd2',
                    width: 300,
                  ),
                  Divider(
                    height: 30,
                  ),
                  Text(
                    "Welcom to Run Tracker",
                    style: TextStyle(
                        color: Colur.txt_white,
                        fontWeight: FontWeight.w700,
                        fontSize: 28),
                  ),
                  Divider(
                    height: 30,
                  ),
                  Text(
                    "Make every run count with the Run Tracker app. Track runs, challenge friends and get motivated to keep going.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 18),
                  ),
                  Divider(
                    height: 30,
                  ),
                  Container(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0)),
                        minimumSize: Size(250, 40),
                      ),
                      child: Text(
                        "Next",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colur.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

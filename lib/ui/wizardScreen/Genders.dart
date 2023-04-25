import 'package:flutter/material.dart';
import 'package:run_tracker/ui/wizardScreen/WizardScreen.dart';
import 'package:run_tracker/utils/Color.dart';

enum Gender { Male, Female }

class Genders extends StatefulWidget {
  final PageController? pageController;
  final Function? updatevalue;
  final bool? isBack;
  final Function? pageNum;

  final WizardScreenState wizardScreenState;
  final String? gender;
  final Function onGender;

  Genders(
      {this.pageController,
      this.updatevalue,
      this.isBack = false,
      this.pageNum,
      required this.gender,
      required this.onGender,
      required this.wizardScreenState});

  @override
  _GendersState createState() => _GendersState();
}

class _GendersState extends State<Genders> {
  Gender? gender = Gender.Male;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var fullHeight = MediaQuery.of(context).size.height;
    var fullWidth = MediaQuery.of(context).size.width;
    return Container(
      height: fullHeight,
      width: fullWidth,
      color: Color.fromARGB(255, 0, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            child: Text(
              "Select Your Gender",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colur.txt_white,
                  fontSize: 30),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              "Tell us about your self",
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 20,
              ),
            ),
          ),
          _maleContanier(fullHeight),
          _femaleContainer(fullHeight),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10, bottom: 150, right: 10),
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  fixedSize: Size(250, 40),
                ),
                child: Text(
                  "Next",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colur.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0),
                ),
                onPressed: () async {
                  setState(() {
                    widget.onGender(gender.toString());
                    widget.updatevalue!(0.66);
                    widget.pageNum!(2);
                  });
                  widget.pageController!.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _maleContanier(double fullHeight) {
    return InkWell(
      onTap: () {
        setState(() {
          gender = Gender.Male;
        });
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(255, 215, 0, 0),
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Color.fromARGB(255, 255, 255, 255)),
        margin: EdgeInsets.only(top: fullHeight * 0.1, left: 60, right: 60),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 30),
              child: Image.asset(
                'assets/icons/male.png',
                width: 30,
                height: 30,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "Male",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 21,
                      color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 30),
              child: Radio(
                fillColor: MaterialStateColor.resolveWith(
                    (states) => Color.fromARGB(255, 215, 0, 0)),
                value: Gender.Male,
                groupValue: gender,
                onChanged: (Gender? value) {
                  setState(() {
                    gender = value;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  _femaleContainer([double? fullHeight]) {
    return InkWell(
      onTap: () {
        setState(() {
          gender = Gender.Female;
        });
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(255, 215, 0, 0),
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Color.fromARGB(255, 255, 255, 255)),
        margin: EdgeInsets.only(top: 30, left: 60, right: 60, bottom: 20),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 30),
              child: Image.asset(
                'assets/icons/female.png',
                width: 30,
                height: 40,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "Female",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 21,
                      color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 30),
              child: Radio(
                fillColor: MaterialStateColor.resolveWith(
                    (states) => Color.fromARGB(255, 215, 0, 0)),
                value: Gender.Female,
                groupValue: gender,
                onChanged: (Gender? value) {
                  setState(() {
                    gender = value;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

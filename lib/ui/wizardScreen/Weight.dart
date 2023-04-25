import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:run_tracker/custom/GradientButtonSmall.dart';
import 'package:run_tracker/ui/wizardScreen/WizardScreen.dart';
import 'package:run_tracker/utils/Color.dart';

class Weight extends StatefulWidget {
  final PageController? pageController;
  final Function? updatevalue;
  final bool? isBack;
  final Function? pageNum;

  final WizardScreenState wizardScreenState;
  final int? weight;
  final Function onWeight;

  Weight(
      {this.pageController,
      this.updatevalue,
      this.isBack = true,
      this.pageNum,
      required this.wizardScreenState,
      required this.weight,
      required this.onWeight});

  @override
  _WeightState createState() => _WeightState();
}

class _WeightState extends State<Weight> {
  bool kgSelected = true;
  bool lbsSelected = false;

  bool unit = true;
  int? weightKG = 20;
  int weightLBS = 44;

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
              "Select Your Weight",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colur.txt_white,
                  fontSize: 30),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              "Unit",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colur.txt_grey,
                fontSize: 20,
              ),
            ),
          ),
          weightUnitPicker(fullHeight),
          weightSelector(fullHeight),
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
                onPressed: () {
                  setState(() {
                    widget.updatevalue!(1.0);
                    widget.pageNum!(3);
                  });

                  convert();
                  widget.onWeight(weightKG);

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

  weightUnitPicker(double fullHeight) {
    return Container(
      margin: EdgeInsets.only(top: fullHeight * 0.03),
      height: 60,
      width: 205,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colur.txt_grey, width: 1.5),
        color: Color.fromARGB(255, 83, 27, 27),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                kgSelected = true;
                lbsSelected = false;
                unit = true;
              });
            },
            child: Container(
              width: 100,
              child: Center(
                child: Text(
                  "KG.",
                  style: TextStyle(
                      color: kgSelected ? Colur.txt_white : Colur.txt_grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
            ),
          ),
          Container(
            height: 23,
            child: VerticalDivider(
              color: Colur.txt_grey,
              width: 1,
              thickness: 1,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                kgSelected = false;
                lbsSelected = true;
                unit = false;
              });
            },
            child: Container(
              width: 100,
              child: Center(
                child: Text(
                  "LBS",
                  style: TextStyle(
                      color: lbsSelected ? Colur.txt_white : Colur.txt_grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  weightSelector(double fullHeight) {
    if (unit == false) {
      return Expanded(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.only(bottom: fullHeight * 0.025),
                  child: Image.asset(
                    "assets/icons/ic_select_pointer.png",
                  ),
                ),
              ),
              Container(
                width: 125,
                height: fullHeight * 0.32,
                child: CupertinoPicker(
                  useMagnifier: true,
                  magnification: 1.05,
                  selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                    background: Colur.transparent,
                  ),
                  scrollController: FixedExtentScrollController(initialItem: 0),
                  looping: true,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      value += 44;
                      weightLBS = value;
                    });
                  },
                  itemExtent: 75.0,
                  children: List.generate(2155, (index) {
                    index += 44;
                    return Text(
                      "$index",
                      style: TextStyle(
                          color: Colur.txt_white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                    );
                  }),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.only(bottom: fullHeight * 0.025),
                  child: Image.asset(
                    "assets/icons/ic_select_pointer.png",
                  ),
                ),
              ),
              Container(
                width: 125,
                height: fullHeight * 0.32,
                child: CupertinoPicker(
                  useMagnifier: true,
                  magnification: 1.05,
                  selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                    background: Colur.transparent,
                  ),
                  looping: true,
                  scrollController: FixedExtentScrollController(initialItem: 0),
                  onSelectedItemChanged: (value) {
                    setState(() {
                      value += 20;
                      weightKG = value;
                    });
                  },
                  itemExtent: 75.0,
                  children: List.generate(978, (index) {
                    index += 20;
                    return Text(
                      "$index",
                      style: TextStyle(
                          color: Colur.txt_white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  convert() {
    if (unit == false) {
      var w = weightLBS * 0.45;
      weightKG = w.toInt();
    }
  }
}

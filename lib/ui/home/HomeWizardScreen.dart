import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:run_tracker/ui/home/HomeScreen.dart';
import 'package:run_tracker/ui/profile/ProfileScreen.dart';
import 'package:run_tracker/ui/startRun/StartRunScreen.dart';
import 'package:run_tracker/ui/useLocation/UseLocationScreen.dart';
// import 'package:run_tracker/utils/Color.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';

class HomeWizardScreen extends StatefulWidget {
  const HomeWizardScreen({Key? key}) : super(key: key);

  @override
  _HomeWizardScreenState createState() => _HomeWizardScreenState();
}

class _HomeWizardScreenState extends State<HomeWizardScreen> {
  PageController _myPage = PageController(initialPage: 0);
  int? num;
  Location _location = Location();

  @override
  void initState() {
    Preference.shared.remove(Preference.IS_PAUSE);
    super.initState();
    num = 0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exitDialog();
        return false;
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 91, 91, 91),
        bottomNavigationBar: BottomAppBar(
          color: Color.fromARGB(255, 215, 0, 0),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          num = 0;
                          _myPage.jumpToPage(0);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Image.asset(
                          "assets/icons/home.png",
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          num = 1;
                          _myPage.jumpToPage(1);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Image.asset(
                          "assets/icons/user.png",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: InkWell(
          onTap: () {
            _permissionCheck();
          },
          child: Container(
            height: 75,
            width: 75,
            child: Image.asset(
              "assets/images/1.png",
              height: 45,
              width: 45,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 9,
                child: new PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _myPage,
                  onPageChanged: (pos) {
                    if (pos == 0) {
                      setState(() {
                        num = 0;
                      });
                    } else if (pos == 1) {
                      setState(() {
                        num = 1;
                      });
                    } else {
                      setState(() {
                        num = 0;
                      });
                    }
                    Debug.printLog("Page changed to: $pos");
                  },
                  children: <Widget>[
                    HomeScreen(),
                    ProfileScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _permissionCheck() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        Utils.showToast(context, "not enabled Service");
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UseLocationScreen()));
      return;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => StartRunScreen()));
  }

  void exitDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ExitMessage"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Exit"),
                onPressed: () async {
                  SystemNavigator.pop();
                },
              ),
            ],
          );
        });
  }
}

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:run_tracker/custom/chart/CustomCircleSymbolRenderer.dart';
import 'package:run_tracker/dbhelper/DataBaseHelper.dart';
import 'package:run_tracker/dbhelper/datamodel/RunningData.dart';
import 'package:run_tracker/dbhelper/datamodel/WaterData.dart';
import 'package:run_tracker/dbhelper/datamodel/WeightData.dart';
import 'package:run_tracker/localization/locale_constant.dart';
import 'package:run_tracker/ui/recentActivities/RecentActivitiesScreen.dart';
import 'package:run_tracker/utils/Constant.dart';
import 'package:run_tracker/utils/Debug.dart';
import 'package:run_tracker/utils/Preference.dart';
import 'package:run_tracker/utils/Utils.dart';
import '../../utils/Color.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int touchedIndexForWaterChart = -1;
  int touchedIndexForHartHealthChart = -1;

  var currentDate = DateTime.now();
  var currentDay;
  var startDateOfCurrentWeek;
  var endDateOfCurrentWeek;
  var formatStartDateOfCurrentWeek;
  var formatEndDateOfCurrentWeek;
  var startDateOfPreviousWeek;
  var endDateOfPreviousWeek;
  var formatStartDateOfPreviousWeek;
  var formatEndDateOfPreviousWeek;

  List<String> allDays = DateFormat.EEEE(getLocale().languageCode)
      .dateSymbols
      .STANDALONESHORTWEEKDAYS;

  bool isNextWeek = false;
  bool isPreviousWeek = false;

  List<charts.Series<LinearSales, DateTime>>? series;
  List<LinearSales> data = [];

  int minWeight = Constant.MIN_KG.toInt();
  int maxWeight = Constant.MAX_KG.toInt();

  bool kmSelected = true;

  @override
  void initState() {
    _fillData();

    Debug.printLog(jsonEncode(allDays));

    isPreviousWeek = true;
    isNextWeek = false;

    int totalDaysInYear = DateTime(DateTime.now().year, 12, 31)
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    DateTime start = DateTime(DateTime.now().year, 1, 1);
    for (int i = 0; i < totalDaysInYear; i++) {
      data.add(LinearSales(start, null));
      start = start.add(Duration(days: 1));
    }
    super.initState();
  }

  _fillData() {
    _getPreference();
    _getDates();
    _getChartDataForDrinkWater();
    _getBestRecordsDataForDistance();
    _getBestRecordsDataForBestPace();
    _getBestRecordsDataForLongestDuration();
    _getLast30DaysWeightAverage();
    _getTotalDistanceForProgress();
    _getTotaCaloriesForProgress();
    _getAveragePaceForProgress();
    _getTotalHoursForProgress();
    _getChartDataForHeartHealth(isCurrent: true);
    _getChartDataForWeight();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  var prefTargetValue;
  int? prefSelectedDay;
  int? maxLimitOfDrinkWater;
  int? maxHeartHealth;
  int? prefMaxHeartHealth;

  _getPreference() {
    prefTargetValue =
        Preference.shared.getString(Preference.TARGET_DRINK_WATER);
    prefSelectedDay =
        Preference.shared.getInt(Preference.FIRST_DAY_OF_WEEK_IN_NUM) ?? 1;
    prefMaxHeartHealth =
        (Preference.shared.getInt(Preference.TARGETVALUE_FOR_WALKTIME) ?? 150) +
            (Preference.shared.getInt(Preference.TARGETVALUE_FOR_RUNTIME) ??
                75);
    setState(() {
      if (prefTargetValue == null) {
        maxLimitOfDrinkWater = 2000;
      } else {
        maxLimitOfDrinkWater = int.parse(prefTargetValue);
      }
      maxHeartHealth = prefMaxHeartHealth;
      kmSelected = Preference.shared.getBool(Preference.IS_KM_SELECTED) ?? true;
    });
  }

  List<RunningData>? totalRunningData;
  Map<String, int> mapRunning = {};

  _getChartDataForHeartHealth({bool isCurrent = false}) async {
    List<String> dates = [];
    // allDays.clear();
    allDays = [];
    for (int i = 0; i <= 6; i++) {
      var currentWeekDates = (isCurrent)
          ? getDate(DateTime.now()
              .subtract(Duration(days: currentDate.weekday - prefSelectedDay!))
              .add(Duration(days: i)))
          : getDate(DateTime.now()
              .subtract(
                  Duration(days: (currentDate.weekday - prefSelectedDay!) + 7))
              .add(Duration(days: i)));
      String formatCurrentWeekDates =
          DateFormat.yMMMd().format(currentWeekDates);

      allDays.add(DateFormat('EEEE', getLocale().languageCode)
          .format(currentWeekDates));

      dates.add(formatCurrentWeekDates);
    }
    totalRunningData = await DataBaseHelper.getHeartHealth(dates);
    mapRunning.clear();
    for (int i = 0; i < dates.length; i++) {
      bool isMatch = false;
      totalRunningData!.forEach((element) {
        if (element.date == dates[i]) {
          if (element.allTotal != null)
            mapRunning.putIfAbsent(element.date!, () => (element.allTotal!));
          isMatch = true;
        }
      });
      if (!isMatch) mapRunning.putIfAbsent(dates[i], () => 0);
    }
    setState(() {});
  }

  List<WaterData>? total;
  Map<String, int> map = {};

  _getChartDataForDrinkWater() async {
    List<String> dates = [];
    // allDays.clear();
    allDays = [];
    for (int i = 0; i <= 6; i++) {
      var currentWeekDates = getDate(DateTime.now()
          .subtract(Duration(days: currentDate.weekday - prefSelectedDay!))
          .add(Duration(days: i)));
      String formatCurrentWeekDates = DateFormat.yMd().format(currentWeekDates);

      allDays.add(DateFormat('EEEE', getLocale().languageCode)
          .format(currentWeekDates));

      dates.add(formatCurrentWeekDates);
    }
    // total = await DataBaseHelper.getTotalDrinkWaterAllDays(dates);
    map.clear();
    for (int i = 0; i < dates.length; i++) {
      bool isMatch = false;
      total!.forEach((element) {
        if (element.date == dates[i]) {
          map.putIfAbsent(element.date!, () => element.total!);
          isMatch = true;
        }
      });
      if (!isMatch) map.putIfAbsent(dates[i], () => 0);
    }
    setState(() {});
  }

  String? drinkWaterAverage;

  // _getDailyDrinkWaterAverage() async {
  //   List<String> dates = [];
  //   for (int i = 0; i <= 6; i++) {
  //     var currentWeekDates = getDate(DateTime.now()
  //         .subtract(Duration(days: currentDate.weekday - 1))
  //         .add(Duration(days: i)));
  //     String formatCurrentWeekDates = DateFormat.yMd().format(currentWeekDates);
  //     dates.add(formatCurrentWeekDates);
  //   }
  //   int? average = await DataBaseHelper.getTotalDrinkWaterAverage(dates);
  //   drinkWaterAverage = (average! ~/ 7).toString();
  //   setState(() {});
  //   Debug.printLog("drinkWaterAverage =====>" + drinkWaterAverage!);
  // }

  RunningData? longestDistance;

  _getBestRecordsDataForDistance() async {
    longestDistance = await DataBaseHelper.getMaxDistance();
    Debug.printLog(
        "Longest Distance =====>" + longestDistance!.distance.toString());
    setState(() {});
    return longestDistance!;
  }

  RunningData? bestPace;

  _getBestRecordsDataForBestPace() async {
    bestPace = await DataBaseHelper.getMaxPace();
    Debug.printLog("Max Pace =====>" + bestPace!.speed.toString());
    setState(() {});
    return bestPace!;
  }

  RunningData? longestDuration;

  _getBestRecordsDataForLongestDuration() async {
    longestDuration = await DataBaseHelper.getLongestDuration();
    Debug.printLog(
        "Longest Duration =====>" + longestDuration!.duration.toString());
    setState(() {});
    return longestDuration!;
  }

  List<WeightData> weightDataList = [];

  _getChartDataForWeight() async {
    weightDataList = await DataBaseHelper.selectWeight();
    if (weightDataList.isNotEmpty) {
      minWeight = weightDataList[0].weightKg!.toInt();
      maxWeight = weightDataList[0].weightKg!.toInt();
    }

    weightDataList.forEach((element) {
      if (minWeight > element.weightKg!.toInt())
        minWeight = element.weightKg!.toInt();

      if (maxWeight < element.weightKg!.toInt())
        maxWeight = element.weightKg!.toInt();

      DateTime date = DateFormat.yMd().parse(element.date!);
      var index =
          data.indexWhere((element) => element.date.isAtSameMomentAs(date));
      if (index > 0) {
        data[index].sales = element.weightKg!.toInt();
      }
    });

    setState(() {});

    return weightDataList;
  }

  _getDates() {
    startDateOfCurrentWeek = getDate(currentDate
        .subtract(Duration(days: currentDate.weekday - prefSelectedDay!)));
    if (prefSelectedDay == 0) {
      endDateOfCurrentWeek =
          getDate(currentDate.add(Duration(days: DateTime.daysPerWeek - 4)));
    } else if (prefSelectedDay == 1) {
      endDateOfCurrentWeek = getDate(currentDate
          .add(Duration(days: DateTime.daysPerWeek - currentDate.weekday)));
    } else if (prefSelectedDay == -1) {
      endDateOfCurrentWeek =
          getDate(currentDate.add(Duration(days: DateTime.daysPerWeek - 5)));
    }
    formatStartDateOfCurrentWeek = DateFormat.MMMd(getLocale().languageCode)
        .format(startDateOfCurrentWeek);
    formatEndDateOfCurrentWeek =
        DateFormat.MMMd(getLocale().languageCode).format(endDateOfCurrentWeek);

    startDateOfPreviousWeek = getDate(currentDate.subtract(
        Duration(days: (currentDate.weekday - prefSelectedDay!) + 7)));
    if (prefSelectedDay == 0) {
      endDateOfPreviousWeek = getDate(currentDate.add(
          Duration(days: (DateTime.daysPerWeek - currentDate.weekday) - 8)));
    } else if (prefSelectedDay == 1) {
      endDateOfPreviousWeek = getDate(currentDate.add(
          Duration(days: (DateTime.daysPerWeek - currentDate.weekday) - 7)));
    } else if (prefSelectedDay == -1) {
      endDateOfPreviousWeek = getDate(currentDate.add(
          Duration(days: (DateTime.daysPerWeek - currentDate.weekday) - 9)));
    }

    formatStartDateOfPreviousWeek = DateFormat.MMMd(getLocale().languageCode)
        .format(startDateOfPreviousWeek);
    formatEndDateOfPreviousWeek =
        DateFormat.MMMd(getLocale().languageCode).format(endDateOfPreviousWeek);
  }

  String? weightAverage;

  _getLast30DaysWeightAverage() async {
    double? average = await DataBaseHelper.getLast30DaysWeightAverage();
    weightAverage =
        (average != null) ? average.toStringAsFixed(2) : 0.0.toString();
    setState(() {});
    Debug.printLog("weightAverage =====>" + weightAverage!);
  }

  RunningData? totalDistance;

  _getTotalDistanceForProgress() async {
    totalDistance = await DataBaseHelper.getSumOfTotalDistance();
    Debug.printLog("total distance: ${totalDistance!.total}");
    setState(() {});
  }

  RunningData? totalHours;

  _getTotalHoursForProgress() async {
    totalHours = await DataBaseHelper.getSumOfTotalDuration();
    Debug.printLog("total duration: ${totalHours!.duration}");

    setState(() {});
    return totalHours!;
  }

  RunningData? totalKcal;

  _getTotaCaloriesForProgress() async {
    totalKcal = await DataBaseHelper.getSumOfTotalCalories();
    Debug.printLog("total calories: ${totalKcal!.total}");
    setState(() {});
    return totalKcal!.total;
  }

  RunningData? avgPace;

  _getAveragePaceForProgress() async {
    avgPace = await DataBaseHelper.getAverageOfSpeed();
    Debug.printLog("average pace: ${avgPace!.total}");
    setState(() {});
    return avgPace!.total;
  }

  @override
  Widget build(BuildContext context) {
    currentDay =
        DateFormat('EEEE', getLocale().languageCode).format(DateTime.now());
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 61, 7, 7),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _runTrackerWidget(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _progressWidget(context),
                    _weightWidget(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _runTrackerWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Color.fromARGB(255, 0, 0, 0),
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Container(
                                // child: Text(
                                //   "RunTracker",
                                //   textAlign: TextAlign.left,
                                //   maxLines: 1,
                                //   overflow: TextOverflow.ellipsis,
                                //   style: TextStyle(
                                //       color: Colur.white,
                                //       fontWeight: FontWeight.w700,
                                //       fontSize: 25),
                                // ),
                                ),
                          ),
                        ],
                      ),
                      // Container(
                      //   margin: const EdgeInsets.only(top: 5.0),
                      //   child: Text(
                      //     "GoFasterSmarter",
                      //     textAlign: TextAlign.left,
                      //     maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,
                      //     style: TextStyle(
                      //         color: Colur.txt_grey,
                      //         fontWeight: FontWeight.w500,
                      //         fontSize: 15),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     Navigator.pushNamed(context, '/profileSettingScreen')
                //         .then((value) => _fillData());
                //   },
                //   child: Container(
                //     padding: const EdgeInsets.all(8.0),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(15.0),
                //       border: Border.all(
                //         color: Colur.gray_border,
                //         width: 1,
                //       ),
                //     ),
                //     child: Image.asset(
                //       "assets/icons/ic_setting_round.png",
                //       scale: 4,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _progressWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      margin: const EdgeInsets.only(top: 8.0),
      width: double.infinity,
      color: Color.fromARGB(255, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "MyProgress",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colur.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                ),
              ),
              // InkWell(
              //   onTap: () => Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => RecentActivitiesScreen())),
              //   child: Text(
              //     "More",
              //     textAlign: TextAlign.left,
              //     maxLines: 1,
              //     overflow: TextOverflow.ellipsis,
              //     style: TextStyle(
              //         color: Colur.txt_purple,
              //         fontWeight: FontWeight.w500,
              //         fontSize: 16),
              //   ),
              // ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 15.0),
            child: AutoSizeText(
              (totalDistance != null && totalDistance!.total != null)
                  ? (kmSelected)
                      ? totalDistance!.total!.toStringAsFixed(2)
                      : Utils.kmToMile(totalDistance!.total!).toStringAsFixed(2)
                  : "0.00",
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 50.0),
            ),
          ),
          Text(
            (kmSelected) ? "TotalKM" : "TotalMile",
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colur.white, fontWeight: FontWeight.w500, fontSize: 14),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15.0),
                        child: AutoSizeText(
                          (totalHours != null && totalHours!.duration! != 0)
                              ? Utils.secToHour(totalHours!.duration!)
                                  .toStringAsFixed(2)
                              : "0.00",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 40.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "TotalHours",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.txt_grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15.0),
                      child: AutoSizeText(
                        (totalKcal != null && totalKcal!.total! != 0)
                            ? totalKcal!.total!.toStringAsFixed(1)
                            : "0.0",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colur.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 40.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "TotalKCAL",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colur.txt_grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          (avgPace != null && avgPace!.total != null)
                              ? (kmSelected)
                                  ? avgPace!.total!.toStringAsFixed(2)
                                  : Utils.minPerKmToMinPerMile(avgPace!.total!)
                                      .toStringAsFixed(2)
                              : "0.00",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 40.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "AvgPace",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colur.txt_grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BarChartGroupData makeHeartHealthGroupData(
  //   int x,
  //   double y, {
  //   bool isTouched = false,
  //   Color barColor = Color.fromARGB(255, 17, 14, 14),
  //   double width = 32,
  // }) {
  //   return BarChartGroupData(
  //     x: x,
  //     barRods: [
  //       BarChartRodData(
  //         y: isTouched ? y + 1 : y,
  //         colors: isTouched ? [Colur.white] : [barColor],
  //         width: width,
  //         borderRadius: BorderRadius.all(Radius.zero),
  //         backDrawRodData: BackgroundBarChartRodData(
  //           show: true,
  //           y: maxHeartHealth!.toDouble(),
  //           colors: [Colur.common_bg_dark],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  List<BarChartGroupData> showingHeartHealthGroups() {
    List<BarChartGroupData> list = [];

    // for (int i = 0; i < mapRunning.length; i++) {
    //   list.add(makeHeartHealthGroupData(
    //       i, Utils.secToMin(mapRunning.entries.toList()[i].value).toDouble(),
    //       isTouched: i == touchedIndexForHartHealthChart));
    // }

    return list;
  }

  _selectedTextStyle() {
    return const TextStyle(
        color: Colur.txt_white, fontWeight: FontWeight.w400, fontSize: 14);
  }

  _unSelectedTextStyle() {
    return const TextStyle(
        color: Colur.txt_grey, fontWeight: FontWeight.w400, fontSize: 14);
  }

  _weightWidget(BuildContext context) {
    series = [
      new charts.Series<LinearSales, DateTime>(
        id: 'Weight',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Colur.purple_gradient_color1),
        domainFn: (LinearSales sales, _) => sales.date,
        measureFn: (LinearSales sales, _) => sales.sales,
        radiusPxFn: (LinearSales sales, _) => 5,
        data: data,
      )
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      margin: const EdgeInsets.only(top: 8.0),
      width: double.infinity,
      color: Color.fromARGB(255, 3, 3, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Weight",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colur.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20.0),
            child: Text(
              (weightAverage != null) ? weightAverage! + "KG" : "0.0" + "KG",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 5.0),
            child: Text(
              "Last30Days",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colur.txt_grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20.0, bottom: 10.0),
            width: double.infinity,
            height: 350,
            child: charts.TimeSeriesChart(
              series!,
              animate: false,
              domainAxis: new charts.DateTimeAxisSpec(
                tickProviderSpec: charts.DayTickProviderSpec(increments: [1]),
                viewport: new charts.DateTimeExtents(
                    start: DateTime.now().subtract(Duration(days: 5)),
                    end: DateTime.now().add(Duration(days: 3))),
                tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                    day: new charts.TimeFormatterSpec(
                        format: 'd', transitionFormat: 'dd/MM')),
                renderSpec: new charts.SmallTickRendererSpec(
                  labelStyle: new charts.TextStyleSpec(
                      fontSize: 15,
                      color: charts.ColorUtil.fromDartColor(Colur.txt_grey)),
                  lineStyle: new charts.LineStyleSpec(
                      color: charts.ColorUtil.fromDartColor(Colur.txt_grey)),
                ),
              ),
              behaviors: [
                new charts.PanBehavior(),
                charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer())
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                    zeroBound: false,
                    dataIsInWholeNumbers: true,
                    desiredTickCount: 5),
                renderSpec: charts.GridlineRendererSpec(
                  lineStyle: new charts.LineStyleSpec(
                      color: charts.ColorUtil.fromDartColor(Colur.txt_grey)),
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 12,
                    fontWeight: FontWeight.w500.toString(),
                    color: charts.ColorUtil.fromDartColor(Colur.txt_grey),
                  ),
                ),
              ),
              selectionModels: [
                charts.SelectionModelConfig(
                    changedListener: (charts.SelectionModel model) {
                  if (model.hasDatumSelection) {
                    final value = model.selectedSeries[0]
                        .measureFn(model.selectedDatum[0].index);
                    CustomCircleSymbolRenderer.value = value.toString();
                  }
                })
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeDrinkWaterGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colur.graph_water,
    double width = 40,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colur.white] : [barColor],
          width: width,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
              topLeft: Radius.circular(3.0),
              topRight: Radius.circular(3.0)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: maxLimitOfDrinkWater!.toDouble(),
            colors: [Colur.common_bg_dark],
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> showingDrinkWaterGroups() {
    List<BarChartGroupData> list = [];

    for (int i = 0; i < map.length; i++) {
      list.add(makeDrinkWaterGroupData(
          i, map.entries.toList()[i].value.toDouble(),
          isTouched: i == touchedIndexForWaterChart));
    }

    return list;
  }
}

class LinearSales {
  DateTime date;
  int? sales;

  LinearSales(this.date, this.sales);
}

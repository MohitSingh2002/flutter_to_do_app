import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertodoapp/dbHelper/dbHelper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  initState() {
    super.initState();

    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Here is your payload"),
        content: new Text("Payload : $payload"),
      ),
    );
  }

  Future _showNotificationWithDefaultSound(String task, String day,String time) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'repeatDailyAtTime  channel id', 'repeatDailyAtTime  channel name', 'repeatDailyAtTime description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Task: ${task}',
      'Schedule Time: ${time} , Schedule Day: ${day}',
      platformChannelSpecifics,
      payload: 'Default_Sound');
  }



  String _isCompletedTaskString = "pending";
  String _date = "";
  String _time = "";
  int _dateYear;
  int _dateMonth;
  int _dateDay;
  int _timeHour;
  int _timeMinute;
  int _timeSecond;
  var myToDoTasks = List();
  List<Widget> child = new List<Widget>();
  bool isValid = true;
  bool isValidUpdateTask = true;
  bool isValidDate = true;
  bool isValidTime = true;
  String task = "";
  String errorTask = "";
  String taskUpdate = "";
  String errorTaskUpdate = "";
  String errorDate = "";
  String errorTime = "";
  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();

  final dbHelper = DatabaseHelperClass.instance;

  addTaskToDB(String task, String date) {

    Map<String, dynamic> row = {
      DatabaseHelperClass.columnName : task,
      DatabaseHelperClass.columnDate : date,
      DatabaseHelperClass.columnStatus : "pending"
    };
    final id = dbHelper.insert(row);
    print(id);
    Navigator.pop(context);
    task = "";
    setState(() {
      isValid = true;
      errorTask = "";
    });

  }

  void query() async {
    var allRows = await dbHelper.queryAll();
    allRows.forEach((element) {print(element);});
  }

  Future<bool> queryAll() async {
    myToDoTasks = [];
    child = [];
    var allRows = await dbHelper.queryAll();
    allRows.forEach((row) {
      myToDoTasks.add(row.toString());
      child.add(GestureDetector(
        onLongPress: () async {
          await dbHelper.deleteSpecific(row['id']);
          setState(() {});
        },
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Update Task',
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        taskUpdate = value;
                      },
                      controller: textEditingController2,
                      decoration: InputDecoration(
                        hintText: "Enter updated task",
                        errorText: isValidUpdateTask ? null : errorTaskUpdate,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Is Completed?",
                      ),
                      onChanged: (value) {
                        _isCompletedTaskString = value;
                      },
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              if(textEditingController2.text.isEmpty) {
                                setState(() {
                                  isValidUpdateTask = false;
                                  errorTaskUpdate = "Can\'t be empty";
                                });
                              } else {
                                await dbHelper.updateSpecific(taskUpdate, _isCompletedTaskString, row['id']);
                                taskUpdate = "";
                                setState(() {
                                  isValidUpdateTask = true;
                                  errorTaskUpdate = "";
                                });
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Update',
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 50,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          );
        },
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20,),
          elevation: 5.0,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Task:',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Asap',
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          row['name'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
//                            fontFamily: 'Staatliches',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    row['date'] != "" ? Row(
                      children: <Widget>[
                        Text(
                          'Date:',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Asap',
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          row['date'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
//                            fontFamily: 'Staatliches',
                          ),
                        ),
                      ],
                    ) : Container(),
                  ],
                ),
                Spacer(),
                Text(
                  'status:',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Asap',
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  row['status'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: row['status'] == "pending" ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    });
    return Future.value(true);
  }

  showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                'Enter a task',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      task = value;
                    },
                    controller: textEditingController1,
                    decoration: InputDecoration(
                      hintText: 'Enter a task',
                      errorText: isValid ? null : errorTask,
                    ),
                  ),
                  TextField(
                    controller: TextEditingController(text: _date == null ? "" : _date),
                    decoration: InputDecoration(
                      errorText: isValidDate ? null : errorDate,
                      hintText: 'Select a date',
                    ),
                    onTap: () {
                      DatePicker.showDatePicker(context,
                      theme: DatePickerTheme(
                        containerHeight: 200,
                      ),
                      showTitleActions: true,
                      minTime: DateTime(2020, 06, 02),
                      maxTime: DateTime(2030, 12, 31),
                      onConfirm: (date) {
                        print(date);
                        setState(() {
                          _date = '${date.year}-${date.month}-${date.day}';
                          _dateYear = date.year;
                          _dateMonth = date.month;
                          _dateDay = date.day;
                        });
                        print(_date);
                      }, currentTime: DateTime.now(), locale: LocaleType.en);
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      errorText: isValidTime ? null : errorTime,
                      hintText: 'Select a time',
                    ),
                    controller: TextEditingController(text: _time == null ? "" : _time),
                    onTap: () {
                      DatePicker.showTimePicker(context,
                          theme: DatePickerTheme(
                            containerHeight: 200,
                          ),
                          showTitleActions: true,
                          onConfirm: (time) {
                            print(time);
                            setState(() {
                              _time = '${time.hour}:${time.minute}:${time.second}';
                              _timeHour = time.hour;
                              _timeMinute = time.minute;
                              _timeSecond = time.second;
                            });
                            print(_time);
                          }, currentTime: DateTime.now(), locale: LocaleType.en);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            if(textEditingController1.text.isEmpty) {
                              setState(() {
                                isValid = false;
                                errorTask = "Can\'t be empty";
                              });
                            } else {
                              addTaskToDB(textEditingController1.text, "${_date} at ${_time}");
                              _showNotificationWithDefaultSound(textEditingController1.text, _date,_time);
                            }
                          },
                          child: Container(
                            width: 50,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Add',
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return FutureBuilder(
      future: queryAll(),
      builder: (context, snapshot) {
        if(snapshot.hasData == null) {
          return Center(
            child: Text(
              'No Data',
            ),
          );
        } else {
          if(myToDoTasks.length == 0) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
//                onPressed: queryAll,
                onPressed: () {
                showAddTaskDialog();
              },
                tooltip: 'Add Task',
                child: Icon(Icons.add,),
              ),
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'My Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: SafeArea(
                child: Center(
                  child: Text(
                    'No tasks available',
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
//                onPressed: query,
                onPressed: () {
                  showAddTaskDialog();
                },
                tooltip: 'Add Task',
                child: Icon(Icons.add,),
              ),
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'My Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: child,
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }
}

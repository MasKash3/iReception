// ignore_for_file: depend_on_referenced_packages

import 'package:facerecognition_flutter/database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:facesdk_plugin/facesdk_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
// import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'about.dart';
import 'settings.dart';
import 'registered_users.dart';
import 'person.dart';
import 'facedetectionview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'iReception',
        theme: ThemeData(
          // Define the default brightness and colors.
          // useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: MyHomePage(title: 'iReception'));
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final String title;
  var personList = <Person>[];

  MyHomePage({super.key, required this.title});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  String _warningState = "";
  bool _visibleWarning = false;

  final _facesdkPlugin = FacesdkPlugin();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    int facepluginState = -1;
    String warningState = "";
    bool visibleWarning = false;

    List<Person> personList =
        await _databaseHelper.getPersonsList(); // Use DatabaseHelper method

    try {
      if (Platform.isAndroid) {
        await _facesdkPlugin
            .setActivation(
                "Os8QQO1k4+7MpzJ00bVHLv3UENK8YEB04ohoJsU29wwW1u4fBzrpF6MYoqxpxXw9m5LGd0fKsuiK"
                "fETuwulmSR/gzdSndn8M/XrEMXnOtUs1W+XmB1SfKlNUkjUApax82KztTASiMsRyJ635xj8C6oE1"
                "gzCe9fN0CT1ysqCQuD3fA66HPZ/Dhpae2GdKIZtZVOK8mXzuWvhnNOPb1lRLg4K1IL95djy0PKTh"
                "BNPKNpI6nfDMnzcbpw0612xwHO3YKKvR7B9iqRbalL0jLblDsmnOqV7u1glLvAfSCL7F5G1grwxL"
                "Yo1VrNPVGDWA/Qj6Z2tPC0ENQaB4u/vXAS0ipg==")
            .then((value) => facepluginState = value ?? -1);
      } else {
        await _facesdkPlugin
            .setActivation(
                "nWsdDhTp12Ay5yAm4cHGqx2rfEv0U+Wyq/tDPopH2yz6RqyKmRU+eovPeDcAp3T3IJJYm2LbPSEz"
                "+e+YlQ4hz+1n8BNlh2gHo+UTVll40OEWkZ0VyxkhszsKN+3UIdNXGaQ6QL0lQunTwfamWuDNx7Ss"
                "efK/3IojqJAF0Bv7spdll3sfhE1IO/m7OyDcrbl5hkT9pFhFA/iCGARcCuCLk4A6r3mLkK57be4r"
                "T52DKtyutnu0PDTzPeaOVZRJdF0eifYXNvhE41CLGiAWwfjqOQOHfKdunXMDqF17s+LFLWwkeNAD"
                "PKMT+F/kRCjnTcC8WPX3bgNzyUBGsFw9fcneKA==")
            .then((value) => facepluginState = value ?? -1);
      }

      if (facepluginState == 0) {
        await _facesdkPlugin
            .init()
            .then((value) => facepluginState = value ?? -1);
      }
    } catch (e) {}

    await SettingsPageState.initSettings();

    final prefs = await SharedPreferences.getInstance();
    int? livenessLevel = prefs.getInt("liveness_level");

    try {
      await _facesdkPlugin
          .setParam({'check_liveness_level': livenessLevel ?? 0});
    } catch (e) {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (facepluginState == -1) {
      warningState = "Invalid license!";
      visibleWarning = true;
    } else if (facepluginState == -2) {
      warningState = "License expired!";
      visibleWarning = true;
    } else if (facepluginState == -3) {
      warningState = "Invalid license!";
      visibleWarning = true;
    } else if (facepluginState == -4) {
      warningState = "No activated!";
      visibleWarning = true;
    } else if (facepluginState == -5) {
      warningState = "Init error!";
      visibleWarning = true;
    }

    setState(() {
      _warningState = warningState;
      _visibleWarning = visibleWarning;
      widget.personList = personList;
    });
  }

  Future<String> insertPerson(Person person) async {
    int name_ = await _databaseHelper.insertPerson(person);
    String name = String.fromCharCode((name_));
    (
      'person',
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    person = Person(
      name: name,
      department: person.department,
      position: person.position,
      email: person.email,
      employeeNumber: person.employeeNumber,
      timeIn: person.timeIn,
      faceJpg: person.faceJpg,
      templates: person.templates,
    );

    setState(() {
      widget.personList.add(person);
    });

    return name;
  }

  Future<Map<String, String>?> getDetailsDialog(BuildContext context) async {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext dialogContext) {
        TextEditingController nameController = TextEditingController();
        TextEditingController departmentController = TextEditingController();
        TextEditingController positionController = TextEditingController();
        TextEditingController emailController = TextEditingController();
        TextEditingController employeeNumberController =
            TextEditingController();

        return AlertDialog(
          title: const Text('Enter Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(hintText: 'Department'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(hintText: 'Position'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              TextField(
                controller: employeeNumberController,
                decoration: const InputDecoration(hintText: 'Employee Number'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final department = departmentController.text;
                final position = positionController.text;
                final email = emailController.text;
                final employeeNumber = employeeNumberController.text;

                if (name.isNotEmpty) {
                  Navigator.pop(dialogContext, {
                    'name': name,
                    'department': department,
                    'position': position,
                    'email': email,
                    'employeeNumber': employeeNumber,
                  });
                } else {
                  // Show an error message or prevent closing the dialog
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future enrollPerson() async {
    try {
      final action = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choose an option'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'camera'),
                child: const Text('Camera'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'gallery'),
                child: const Text('Gallery'),
              ),
            ],
          );
        },
      );

      if (action == 'camera' || action == 'gallery') {
        final image = action == 'camera'
            ? await ImagePicker().pickImage(source: ImageSource.camera)
            : await ImagePicker().pickImage(source: ImageSource.gallery);

        if (image == null) return;

        var rotatedImage =
            await FlutterExifRotation.rotateImage(path: image.path);
        final faces = await _facesdkPlugin.extractFaces(rotatedImage.path);

        if (faces.length == 0) {
          Fluttertoast.showToast(
              msg: "No face detected!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          return;
        }

        for (var face in faces) {
          final details = await getDetailsDialog(context);
          String capitalize(String name) {
            List<String> words = name.split(' ');
            words = words.map((word) {
              if (word.isNotEmpty) {
                return word[0].toUpperCase() + word.substring(1).toLowerCase();
              }
              return word;
            }).toList();
            return words.join(' ');
          }

          if (details != null && details['name'] != null) {
            final name = details['name'];
            final department = details['department'];
            final position = details['position'];
            final email = details['email'];
            final employeeNumber = details['employeeNumber'];
            // Record the current time
            final timeIn = DateTime.now().toString();
            if (name != null) {
              Person person = Person(
                name: capitalize(name), // Use the entered name
                department: department ?? '',
                position: position ?? '',
                email: email ?? '',
                employeeNumber: employeeNumber ?? '',
                timeIn: timeIn,
                faceJpg: face['faceJpg'],
                templates: face['templates'],
              );
              await insertPerson(person);
            }
          }
          Fluttertoast.showToast(
              msg: "Person enrolled!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iReception'),
        toolbarHeight: 70,
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Text('About'),
              ),
              const PopupMenuItem(
                value: 'registered_users',
                child: Text('Registered Users'),
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      homePageState: this,
                    ),
                  ),
                );
              } else if (value == 'about') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              } else if (value == 'registered_users') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RegisteredUsersPage(registeredUsers: widget.personList),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  label: const Text('Register', style: TextStyle(fontSize: 50)),
                  icon: const Icon(Icons.add, size: 30),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  onPressed: enrollPerson,
                ),
                const SizedBox(width: 20), // Add spacing between the buttons
                ElevatedButton.icon(
                  label: const Text('Scan Now', style: TextStyle(fontSize: 50)),
                  icon: const Icon(Icons.search, size: 30),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaceRecognitionView(
                          personList: widget.personList,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

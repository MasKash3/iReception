import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'person.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisteredUsersPage extends StatefulWidget {
  List<Person> registeredUsers;

  RegisteredUsersPage({super.key, required this.registeredUsers});

  @override
  _RegisteredUsersPageState createState() => _RegisteredUsersPageState();
}

class _RegisteredUsersPageState extends State<RegisteredUsersPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _updateRegisteredUsers();
  }

  void _updateRegisteredUsers() async {
    List<Person> users = await _databaseHelper.getPersonsList();
    setState(() {
      widget.registeredUsers = users;
    });
  }

  void _saveRegisteredUsers(List<Person> users) {
    try {
      users.forEach((user) async {
        await _databaseHelper.insertPerson(user);
      });
    } catch (e) {
      // print(e);
    }
  }

  void deletePerson(int index) async {
    try {
      if (index >= 0 && index < widget.registeredUsers.length) {
        // Delete from the persistent storage
        await _databaseHelper.deletePerson(widget.registeredUsers[index].name);

        // Update the UI
        setState(() {
          widget.registeredUsers.removeAt(index);
        });
        Fluttertoast.showToast(
            msg: "Person removed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        // Save the updated list to persistent storage
        _saveRegisteredUsers(widget.registeredUsers);
      }
    } catch (e) {
      // print(e);
    }
  }

  Future<List<Person>> _getUsers() async {
    return _databaseHelper.getPersonsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Users'),
      ),
      body: FutureBuilder<List<Person>>(
        future: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error fetching data');
          } else if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(widget.registeredUsers[index].name),
                    onDismissed: (direction) {
                      deletePerson(index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    child: SizedBox(
                      height: 75,
                      child: Card(
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(28.0),
                              child: Image.memory(
                                widget.registeredUsers[index].faceJpg,
                                width: 56,
                                height: 56,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(widget.registeredUsers[index].name),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deletePerson(index);
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return const Text('No data found');
          }
        },
      ),
    );
  }
}

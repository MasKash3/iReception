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

  void showUserDetails(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Center(
                  child: Image.memory(
                    widget.registeredUsers[index].faceJpg,
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Name: ${widget.registeredUsers[index].name}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Text(
                  'Department: ${widget.registeredUsers[index].department}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Position: ${widget.registeredUsers[index].position}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Email: ${widget.registeredUsers[index].email}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Employee Number: ${widget.registeredUsers[index].employeeNumber}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Time In: ${widget.registeredUsers[index].timeIn}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Users'),
      ),
      body: ListView.builder(
        itemCount: widget.registeredUsers.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              showUserDetails(index);
            },
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
          );
        },
      ),
    );
  }
}

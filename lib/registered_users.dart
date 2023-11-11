import 'package:flutter/material.dart';
import 'person.dart';

class RegisteredUsersPage extends StatefulWidget {
  final List<Person> registeredUsers;

  const RegisteredUsersPage({super.key, required this.registeredUsers});

  @override
  _RegisteredUsersPageState createState() => _RegisteredUsersPageState();
}

class _RegisteredUsersPageState extends State<RegisteredUsersPage> {
  void deletePerson(int index) {
    setState(() {
      if (index >= 0 && index < widget.registeredUsers.length) {
        widget.registeredUsers.removeAt(index);
      }
    });
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
        },
      ),
    );
  }
}

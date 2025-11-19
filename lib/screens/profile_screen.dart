import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    var doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

    firstCtrl.text = doc["firstName"];
    lastCtrl.text = doc["lastName"];
    dobCtrl.text = doc["dob"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: firstCtrl, decoration: const InputDecoration(labelText: "First Name")),
            TextField(controller: lastCtrl, decoration: const InputDecoration(labelText: "Last Name")),
            TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: "Date of Birth")),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                String uid = FirebaseAuth.instance.currentUser!.uid;

                FirebaseFirestore.instance.collection("users").doc(uid).update({
                  "firstName": firstCtrl.text,
                  "lastName": lastCtrl.text,
                  "dob": dobCtrl.text,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Updated!")),
                );
              },
              child: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }
}

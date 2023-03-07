import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/db_helper.dart';

import 'students.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: myApp(),
  ));
}

class myApp extends StatefulWidget {
  const myApp({Key? key}) : super(key: key);

  @override
  State<myApp> createState() => _myAppState();
}

class _myAppState extends State<myApp> {

  late Future<List<Student>> getAllStudents;

  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController courseController = TextEditingController();

  String? name;
  int? age;
  String? course;
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    getAllStudents = DBHelper.dbHelper.fetchAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Base"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getAllStudents,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("ERROR : ${snapshot.error}"));
          } else if (snapshot.hasData) {
            List<Student>? data = snapshot.data;

            return (data != null)
                ? ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        isThreeLine: true,
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: (data[i].image != null)
                              ? MemoryImage(data[i].image as Uint8List)
                              : null,
                        ),
                        title: Text("${data[i].name}"),
                        subtitle: Text(
                            "Age : ${data[i].age} \n Course: ${data[i].course}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                validateAndUpdate(context, data: data[i]);
                              },
                              icon: Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () async {
                                int res = await DBHelper.dbHelper
                                    .delete(id: data[i].id!);

                                if (res == 1) {
                                  setState(() {
                                    getAllStudents =
                                        DBHelper.dbHelper.fetchAllStudents();
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Record Deleted successfully ..."),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Record Deleted failed ..."),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    })
                : Center(
                    child: Text("No Data available..."),
                  );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          validateAndInsert(context);
        },
      ),
    );
  }

  Future<void> validateAndInsert(context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text("Insert Records"),
        ),
        content: Form(
          key: insertFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();

                  XFile? xFile =
                      await picker.pickImage(source: ImageSource.camera);

                  image = await xFile!.readAsBytes();
                },
                child: Text("Pick Image"),
              ),
              TextFormField(
                controller: nameController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter name first...";
                  }
                  return null;
                },
                onSaved: (val) {
                  name = val;
                },
                decoration: InputDecoration(
                  hintText: "Enter name Here..",
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: ageController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter age first...";
                  }
                  return null;
                },
                onSaved: (val) {
                  age = int.parse(val!);
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter age Here..",
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: courseController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter course first...";
                  }
                  return null;
                },
                onSaved: (val) {
                  name = val;
                },
                decoration: InputDecoration(
                  hintText: "Enter course Here..",
                  labelText: "Course",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (insertFormKey.currentState!.validate()) {
                insertFormKey.currentState!.save();

                Student s1 = Student(
                    name: name!, age: age!, course: course!, image: image);

                int res = await DBHelper.dbHelper.insert(data: s1);

                if (res > 0) {
                  setState(() {
                    getAllStudents = DBHelper.dbHelper.fetchAllStudents();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Record Inserted successfully with id: $res ..."),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Record insertion failed ..."),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }

              nameController.clear();
              ageController.clear();
              courseController.clear();

              setState(() {
                name = null;
                age = null;
                course = null;
                image = null;
              });

              Navigator.of(context).pop();
            },
            child: Text("Insert"),
          ),
          ElevatedButton(
            onPressed: () {
              nameController.clear();
              ageController.clear();
              courseController.clear();

              setState(() {
                name = null;
                age = null;
                course = null;
                image = null;
              });
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> validateAndUpdate(context,{required Student data}) async {

    nameController.text = data.name;
    ageController.text = data.age.toString();
    courseController.text = data.course;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text("Update Records"),
        ),
        content: Form(
          key: insertFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();

                  XFile? xFile =
                  await picker.pickImage(source: ImageSource.camera);

                  image = await xFile!.readAsBytes();
                },
                child: Text("Edit Image"),
              ),
              TextFormField(
                controller: nameController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter name first...";
                  }
                  return null;
                },
                onSaved: (val) {
                  name = val;
                },
                decoration: InputDecoration(
                  hintText: "Enter name Here..",
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: ageController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter age first...";
                  }
                  return null;
                },
                onSaved: (val) {
                  age = int.parse(val!);
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter age Here..",
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: courseController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter course first...";
                  }
                  return null;
                },
                onSaved: (val) {
                  name = val;
                },
                decoration: InputDecoration(
                  hintText: "Enter course Here..",
                  labelText: "Course",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (insertFormKey.currentState!.validate()) {
                insertFormKey.currentState!.save();

                Student s1 = Student(
                    name: name!, age: age!, course: course!, image: image);

                int res = await DBHelper.dbHelper.update(data: s1, id: data.id!);

                if (res == 1) {
                  setState(() {
                    getAllStudents = DBHelper.dbHelper.fetchAllStudents();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Record Update successfully ..."),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Record updation failed ..."),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }

              nameController.clear();
              ageController.clear();
              courseController.clear();

              setState(() {
                name = null;
                age = null;
                course = null;
                image = null;
              });

              Navigator.of(context).pop();
            },
            child: Text("Update"),
          ),
          ElevatedButton(
            onPressed: () {
              nameController.clear();
              ageController.clear();
              courseController.clear();

              setState(() {
                name = null;
                age = null;
                course = null;
                image = null;
              });
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }
}

import 'dart:typed_data';

class Student {
  int? id;
  final String name;
  final int age;
  final String course;
  Uint8List? image;


  Student({
    this.id,
    required this.name,
    required this.age,
    required this.course,
    this.image,
});

  factory Student.fromMap({required Map<String,dynamic> data}){
    return Student(
      id: data['id'],
      name: data['name'],
      age: data['age'],
      course: data['course'],
      image: data['image'],
    );
  }
}
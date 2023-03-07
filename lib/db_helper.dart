import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled/students.dart';

class DBHelper {
  DBHelper._();

  static final DBHelper dbHelper = DBHelper._();

  Database? db;

  Future<void> initDB() async {
    String directory = await getDatabasesPath();
    String path = join(directory, "demo.db");

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        String query =
            "CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, age INTEGER NOT NULL, course TEXT NOT NULL, image BLOB);";

        await db.execute(query);

        print("Table Create Successfully...");
      },
    );
  }

  Future<int> insert({required Student data}) async {

    await initDB();

    String query = "INSERT INTO students(name, age, course, image) VALUES (?,?,?,?);";

    List args = [data.name,data.age,data.course,data.image];

    int res = await db!.rawInsert(query ,args);  //retrun inserted record's pk(id)

    return res;
  }

  Future<List<Student>> fetchAllStudents() async {
    await initDB();

    String query = "SELECT * FROM students;";

    List<Map<String,dynamic>> allRecords = await db!.rawQuery(query);

    List<Student> allStudents = allRecords.map((e) => Student.fromMap(data: e)).toList();

    return allStudents;
  }


  Future<int> delete({required int id}) async {

    await initDB();

    String query = "DELETE FROM students WHERE id=?";

    List args = [id];

    int res = await db!.rawDelete(query,args);  //retrun inserted record's delete

    return res;
  }

  Future<int> update({required Student data , required int id}) async {

    await initDB();

    String query = "UPDATE students SET name=? ,age=?,course=?,image=? WHERE id=?;";

    List args = [data.name,data.age,data.course,data.image,id];

    int res = await db!.rawUpdate(query ,args);  //retrun inserted record's pk(id)

    return res;
  }
}

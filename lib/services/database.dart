import 'package:firebase_database/firebase_database.dart';

class DbMetod {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  Future<void> addMedicineDetails(
      String userId,
      String medicineName,
      String day,
      String time,
      Map<String, dynamic> medicineInfo) async {
    try {
      await databaseReference
          .child('users')
          .child(userId)
          .child('medicines')
          .child(medicineName)
          .child('days')
          .child(day)
          .child('times')
          .child(time)
          .set(medicineInfo);
      print('Veri başarıyla eklendi');
    } catch (e) {
      print('Veri eklenirken hata oluştu: $e');
    }
  }
}

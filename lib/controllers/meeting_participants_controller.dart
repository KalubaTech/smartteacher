import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantController extends GetxController {
  var participants = <String>[].obs;  // Observable list of participants
  var initiatorId = ''.obs;  // Observable initiator ID

  // Firestore listener to update participants and initiator
  void listenForParticipants(String schoolId, String teacherUid) {
    FirebaseFirestore.instance
        .collection('teachers')
        .where('school', isEqualTo: schoolId)
        .snapshots()
        .listen((querySnapshot) {
      List<String> tempParticipants = [];
      String? tempInitiatorId;

      for (var doc in querySnapshot.docs) {
        String teacherId = doc.id;
        bool isInitiator = doc.get('isInitiator') ?? false;

        // If this teacher is the initiator, save their ID
        if (isInitiator) {
          tempInitiatorId = teacherId;
        }

        // Add to the list if it's not the current teacher
        if (teacherId != teacherUid) {
          tempParticipants.add(teacherId);
        }
      }

      // Update the observable variables
      participants.value = tempParticipants;
      initiatorId.value = tempInitiatorId ?? '';
    });
  }
}

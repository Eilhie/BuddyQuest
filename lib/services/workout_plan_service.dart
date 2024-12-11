import "package:cloud_firestore/cloud_firestore.dart";
import 'dart:core';


class WorkoutPlanService
{
  final CollectionReference workout_plans = FirebaseFirestore.instance.collection('workout_plan_v2');

  Future<Map<String, dynamic>?> getExcercise(String category, int dayIdx) async
  {
    try
    {
      var querySnapshot = await workout_plans.where("category", isEqualTo: category).get();
      var queryDocumentSnapshot = querySnapshot.docs;
      if(queryDocumentSnapshot.length == 0)
      {
        return null;
      }
      else {
        Map<String, dynamic> objMap = queryDocumentSnapshot[0].data() as Map<String, dynamic>;
        return objMap;
      }
    }
    catch(e)
    {
      print(e);
    }
    return null;

  }
}

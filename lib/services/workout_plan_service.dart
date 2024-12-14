import "package:cloud_firestore/cloud_firestore.dart";
import 'dart:core';


class WorkoutPlanService
{
  final CollectionReference workout_plans = FirebaseFirestore.instance.collection('workout_plan_v2');


  // return map <string, dynamic>
  // kalau null rest day
  // {exercises=list(map), day (str), workout_type (str)}
  Future<Map<String, dynamic>?> getExcerciseByCategoryDay(String category, int dayIdx) async
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
        var isRestDay = ((objMap["days"]) as List<dynamic>).length <= dayIdx;
        return isRestDay?null:objMap["days"][dayIdx];
      }
    }
    catch(e)
    {
      print(e);
    }
    return null;

  }
}
import "package:cloud_firestore/cloud_firestore.dart";
import 'dart:core';


class WorkoutPlanService
{
  final CollectionReference workout_plans = FirebaseFirestore.instance.collection('workout_plan_v2');
  final CollectionReference user_weekly_workout_progress = FirebaseFirestore.instance.collection("user_weekly_workout_progress");


  // return map <string, dynamic>
  // kalau null rest day
  // {exercises=list(map), day (str), workout_type (str)}
  Future<Map<String, dynamic>?> getExcerciseByCategoryDay(String category, int dayIdx) async
  {
    try
    {
      var querySnapshot = await workout_plans.where("category", isEqualTo: category).get();
      var queryDocumentSnapshot = querySnapshot.docs;
      if(queryDocumentSnapshot.isEmpty)
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

  // return List<string> isinya nama workout yg di blackout di hari dayIdx
  Future<List<String>?> getUserProgressByDay(String? uid, int dayIdx) async
  {
    try
    {
      var querySnapshot = await user_weekly_workout_progress.where("uid", isEqualTo: uid).get();
      var queryDocumentSnapshot = querySnapshot.docs;
      if(queryDocumentSnapshot.isEmpty)
      {
        return null;
      }
      else {
        Map<String, dynamic> objMap = queryDocumentSnapshot[0].data() as Map<String, dynamic>;
        List<String> workoutList = List<String>.from(objMap["day$dayIdx"] as List);
        return workoutList;
      }
    }
    catch(e)
    {
      print(e);
    }
    return null;
  }

  // update List<string> workout yang di blackout di hari dayIdx
  Future<void> updateUserProgressByDay(String? uid, int dayIdx, String workoutName) async
  {
    try
    {
      var collectionReference = user_weekly_workout_progress.doc(uid);
      var querySnapshot = await collectionReference.get();
      if(querySnapshot.exists)
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        List<String> progressForDay = List<String>.from(objMap["day$dayIdx"] as List);
        progressForDay.add(workoutName);
        objMap["day$dayIdx"] = progressForDay;
        collectionReference.update(objMap);
      }
      else
      {
        throw "workout progress for day $dayIdx does not exist";
      }
    }
    catch(e)
    {
      print(e);
    }
  }

  // reset workout yg di blackout kalau sudah awal minggu
  Future<void> checkUpdateUserProgress(String? uid) async
  {
    DateTime currDate = DateTime.now();
    DateTime lastMonday = currDate.subtract(Duration(days:(currDate.weekday - 1), hours:(currDate.hour - 0), minutes:(currDate.minute)));
    DateTime nextMonday = currDate.add(Duration(days:(7 - currDate.weekday + 1), hours:(currDate.hour - 0), minutes:(currDate.minute)));
    try
    {
      var collectionReference = user_weekly_workout_progress.doc(uid);
      var querySnapshot = await collectionReference.get();
      if(!querySnapshot.exists)
      {
        return;
      }
      else
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        var lastUpdate = DateTime.fromMillisecondsSinceEpoch((objMap["last_update"] as Timestamp).seconds * 1000);
        if((lastUpdate.weekday == lastMonday.weekday) & (lastUpdate.month == lastMonday.month) & (lastUpdate.year == lastMonday.year))
        {//reset workout progress and set last update to next monday
          for(int i=0;i<7;i++)
          {
            objMap["day$i"] = <String>[];
          }
          objMap["last_update"] = nextMonday;
          collectionReference.update(objMap);
        }
      }
    }
    catch(e)
    {
      print(e);
    }

  }
}
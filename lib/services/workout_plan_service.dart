import "package:cloud_firestore/cloud_firestore.dart";
import 'dart:core';


class WorkoutPlanService
{
  final CollectionReference workout_plans = FirebaseFirestore.instance.collection('workout_plan_v2');
  final CollectionReference user_weekly_workout_progress = FirebaseFirestore.instance.collection("user_weekly_workout_progress");
  final CollectionReference workout_assets = FirebaseFirestore.instance.collection('workout_video');


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
        Map<String, dynamic> workoutProgress = objMap["day$dayIdx"];
        List<String> doneExercises = List<String>.from(workoutProgress["done_exercises"] as List);
        return doneExercises;
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
        Map<String, dynamic> workoutProgressForDay = objMap["day$dayIdx"];
        List<String> doneExercises = List<String>.from(workoutProgressForDay["done_exercises"] as List);
        doneExercises.add(workoutName);
        objMap["day$dayIdx"]["done_exercises"] = doneExercises;
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
    DateTime lastMonday = currDate.subtract(Duration(days:(currDate.weekday - 1), hours:(currDate.hour), minutes:(currDate.minute)));
    DateTime nextMonday = currDate.add(Duration(days:(7 - currDate.weekday + 1))).subtract(Duration(hours:(currDate.hour), minutes:(currDate.minute)));
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
        if((lastUpdate.day == lastMonday.day) & (lastUpdate.month == lastMonday.month) & (lastUpdate.year == lastMonday.year))
        {//reset workout progress and set last update to next monday
          for(int i=0;i<7;i++)
          {
            objMap["day$i"]["done_exercises"] = <String>[];
            objMap["day$i"]["points_earned"] = 0;
          }
          objMap["last_update"] = nextMonday;
          collectionReference.update(objMap);
        }
      }
    }
    catch(e)
    {
      print("Something went wrong in checkUpdateUserProgress");
      print(e);
    }

  }

  // add history pertambahan poin
  Future<void> updateGainedPointsByDay(String uid, int dayIdx, int pointsGained) async
  {
    try
    {
      var collectionReference = user_weekly_workout_progress.doc(uid);
      var querySnapshot = await collectionReference.get();
      if(querySnapshot.exists)
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        objMap["day$dayIdx"]["points_earned"] += pointsGained;
        collectionReference.update(objMap);
      }
    }
    catch(e)
    {
      print("Add point history failed");
      print(e);
    }
  }

  //Data untuk chart
  Future<List<int>?> getPointsList(String uid) async
  {
    try {
      var collectionReference = user_weekly_workout_progress.doc(uid);
      var querySnapshot = await collectionReference.get();
      print("POINTS LIST");
      if (querySnapshot.exists) {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        List<int> pointsList= [];
        for(int i=0;i<7;i++)
        {
          pointsList.add(objMap["day$i"]["points_earned"]);
        }

        print(pointsList);
        return pointsList;
      }
    }catch(e)
    {
      print("Get Points List failed ");
      print(e);
    }
    return null;
  }


  //Data untuk chart
  Future<List<bool>?> getDidWorkoutList(String uid) async
  {
    try {
      var collectionReference = user_weekly_workout_progress.doc(uid);
      var querySnapshot = await collectionReference.get();
      if (querySnapshot.exists) {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        List<bool> doneList= [];
        for(int i=0;i<7;i++)
        {
          List<String> doneExercises = List<String>.from(objMap["day$i"]["done_exercises"] as List);
          doneList.add(doneExercises.isNotEmpty);
        }
        return doneList;
      }
    }catch(e)
    {
      print("Get Done Exercise List failed ");
      print(e);
    }
    return null;
  }

  Future<DateTime?> getNextWorkoutDay(String category, DateTime date) async
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
        List<dynamic> workout_days = objMap["days"];
        // next workout day is next monday
        if((date.weekday) >= workout_days.length)
        {
          return date.add(Duration(days:(7 - date.weekday + 1))).subtract(Duration(hours:(date.hour), minutes:(date.minute)));
        }
        else//next workout day is tomorrow
        {
          return date.add(Duration(days:1));
        }

      }
    }
    catch(e)
    {
      print(e);
    }
    return null;
  }

  Future<String?> getVideoByName(String exerciseName) async
  {
    try
    {
      var collectionReference = workout_assets.doc(exerciseName);
      var querySnapshot = await collectionReference.get();
      if(querySnapshot.exists)
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        String assetString = objMap["asset_path"];
        return assetString;
      }
    }
    catch(e)
    {
      print(e);
    }
    return null;
  }
}
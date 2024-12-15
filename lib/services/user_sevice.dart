import 'dart:core';
import 'dart:math';
import "package:cloud_firestore/cloud_firestore.dart";

class UserService
{
  final user_collection = FirebaseFirestore.instance.collection("users");

  Future<void> registerUserEmail() async {

  }

  //get workout_type / category user
  Future<String?> getUserWorkoutCategory(String uid) async
  {
    try
    {
      var collectionReference = user_collection.doc(uid);
      var querySnapshot = await collectionReference.get();
      if(querySnapshot.exists)
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        String userCategory = objMap["workout_type"];
        return userCategory;
      }
    }
    catch(e)
    {
      print(e);
    }
    return null;
  }

  // update category workout user pakai string cth "1.1" , "2.1"
  Future<void> updateUserWorkoutCategory(String uid, String category) async
  {
    try
    {
      var collectionReference = user_collection.doc(uid);
      var querySnapshot = await collectionReference.get();
      if(querySnapshot.exists)
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        objMap["workout_type"] = category;
        collectionReference.update(objMap);
      }
      else
      {
        throw "workout type for user $uid does not exist";
      }
    }
    catch(e)
    {
      print(e);
    }
  }

  // get user current streak
  Future<int?> getUserCurrentStreak(String uid) async
  {
    try
    {
      var collectionReference = user_collection.doc(uid);
      var querySnapshot = await collectionReference.get();
      if(querySnapshot.exists)
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        int userCurrentStreak = objMap["currentStreak"];
        return userCurrentStreak;
      }
    }
    catch(e)
    {
      print(e);
    }
    return null;
  }

  // hanya cek user streak dan update jika broken
  Future<void> checkUserStreak(String uid) async
  {
    try
    {
      var collectionReference = user_collection.doc(uid);
      var querySnapshot = await collectionReference.get();
      if(querySnapshot.exists)
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        DateTime lastStreakUpdate = DateTime.fromMillisecondsSinceEpoch((objMap["lastStreakUpdate"] as Timestamp).seconds * 1000);
        DateTime currDate = DateTime.now();
        //streak broken
        int currStreak = objMap["currentStreak"];
        if(currDate.difference(lastStreakUpdate).inDays>=1)
        {
          currStreak = 0;
        }
        objMap["currentStreak"] = currStreak;
        collectionReference.update(objMap);

      }
    }
    catch(e)
    {
      print(e);
    }
  }
  //get user point
  Future<int?> getUserPoint(String uid) async
  {
    try
    {
      var collectionReference = user_collection.doc(uid);
      var querySnapshot = await collectionReference.get();
      if(querySnapshot.exists)
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        int userPoint = objMap["points"];
        return userPoint;
      }
    }
    catch(e)
    {
      print(e);
    }
    return null;
  }

  // check jika user masih streak dan update streak dan juga update point
  Future<void> addUserPoints(String uid, int pointsToAdd) async
  {
    try
    {
      var collectionReference = user_collection.doc(uid);
      var querySnapshot = await collectionReference.get();
      if(querySnapshot.exists)
      {
        Map<String, dynamic> objMap = querySnapshot.data() as Map<String, dynamic>;
        DateTime lastStreakUpdate = DateTime.fromMillisecondsSinceEpoch((objMap["lastStreakUpdate"] as Timestamp).seconds * 1000);
        DateTime currDate = DateTime.now();
        //streak broken
        int currStreak;
        int highestStreak = objMap["highestStreak"];
        if(currDate.difference(lastStreakUpdate).inDays>=1)
        {
          currStreak = 1;
        }
        else // still streaking
        {
          currStreak = objMap["currentStreak"];
          if(lastStreakUpdate.weekday != currDate.weekday)
          {
            currStreak+=1;
          }
          highestStreak = max(highestStreak,currStreak);
        }
        lastStreakUpdate = currDate;
        int currPoints = objMap["points"];
        int newPoints = currPoints + ((pointsToAdd + 0.1*min(currStreak-1, 0.7)*pointsToAdd) as int);
        objMap["points"] = newPoints;
        objMap["lastStreakUpdate"] = lastStreakUpdate;
        objMap["currentStreak"] = currStreak;
        objMap["highestStreak"] = highestStreak;
        collectionReference.update(objMap);
      }
    }
    catch(e)
    {
      print(e);
    }
  }



}
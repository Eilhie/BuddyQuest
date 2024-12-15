import 'dart:core';
import "package:cloud_firestore/cloud_firestore.dart";

class UserService
{
  final user_collection = FirebaseFirestore.instance.collection("users");

  Future<void> registerUserEmail() async {

  }

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
}
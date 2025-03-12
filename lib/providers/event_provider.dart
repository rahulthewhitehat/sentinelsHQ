// event_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> get events => _events;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fetch all events
  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('events').get();

      _events = snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load events: ${e.toString()}';
      if (kDebugMode) {
        print("Error fetching events: $e");
      }
      notifyListeners();
    }
  }

  // Add new event
  Future<bool> addEvent(Map<String, dynamic> eventData) async {
    _isLoading = true;
    notifyListeners();

    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('events').add(eventData);

      // Add the new event to the local list
      Map<String, dynamic> newEvent = {
        "id": docRef.id,
        ...eventData,
      };

      _events.add(newEvent);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add event: ${e.toString()}';
      if (kDebugMode) {
        print("Error adding event: $e");
      }
      notifyListeners();
      return false;
    }
  }

  // Update existing event
  Future<bool> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('events').doc(eventId).update(eventData);

      // Update the event in local list
      final index = _events.indexWhere((event) => event["id"] == eventId);
      if (index != -1) {
        _events[index] = {
          "id": eventId,
          ...eventData,
        };
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update event: ${e.toString()}';
      if (kDebugMode) {
        print("Error updating event: $e");
      }
      notifyListeners();
      return false;
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();

      // Remove the event from local list
      _events.removeWhere((event) => event["id"] == eventId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete event: ${e.toString()}';
      if (kDebugMode) {
        print("Error deleting event: $e");
      }
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
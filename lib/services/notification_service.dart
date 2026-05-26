import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  NotificationService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String collectionName =
      'Notifications';

  // Notification Types
  static const String application =
      'Application';

  static const String club = 'Club';

  static const String event = 'Event';

  static const String system = 'System';

  /// Create a notification for one user
  static Future<void> createNotification({
    required String receiverId,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    try {
      if (receiverId.trim().isEmpty ||
          message.trim().isEmpty ||
          type.trim().isEmpty) {
        return;
      }

      await _firestore
          .collection(collectionName)
          .add({
        'receiverId': receiverId,
        'notification_message': message.trim(),
        'notification_type': type,
        'relatedId': relatedId,
        'isRead': false,
        'timestamp':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(
        'Notification creation failed: $e',
      );
    }
  }

  /// Create same notification for multiple users
  static Future<void> createBulkNotification({
    required List<String> receiverIds,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    try {
      if (receiverIds.isEmpty) return;

      final batch =
          _firestore.batch();

      for (final uid in receiverIds) {
        final docRef = _firestore
            .collection(collectionName)
            .doc();

        batch.set(docRef, {
          'receiverId': uid,
          'notification_message':
              message.trim(),
          'notification_type': type,
          'relatedId': relatedId,
          'isRead': false,
          'timestamp':
              FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print(
        'Bulk notification failed: $e',
      );
    }
  }

  /// Mark one notification as read
  static Future<void> markAsRead(
    String notificationId,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(notificationId)
          .update({
        'isRead': true,
      });
    } catch (e) {
      print(
        'Mark as read failed: $e',
      );
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead(
    String receiverId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(
                collectionName,
              )
              .where(
                'receiverId',
                isEqualTo:
                    receiverId,
              )
              .where(
                'isRead',
                isEqualTo: false,
              )
              .get();

      final batch =
          _firestore.batch();

      for (final doc
          in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
        });
      }

      await batch.commit();
    } catch (e) {
      print(
        'Mark all as read failed: $e',
      );
    }
  }

  /// Delete notification
  static Future<void>
  deleteNotification(
    String notificationId,
  ) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(notificationId)
          .delete();
    } catch (e) {
      print(
        'Delete notification failed: $e',
      );
    }
  }
}
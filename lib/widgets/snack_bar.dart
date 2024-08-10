import 'package:flutter/material.dart';

// Enum for SnackBar status
enum SnackBarStatus { create, update, error, deleted }

// Function to get color based on SnackBar status
Color getSnackBarColor(SnackBarStatus status) {
  switch (status) {
    case SnackBarStatus.create:
      return Colors.green;
    case SnackBarStatus.update:
      return Colors.blue;
    case SnackBarStatus.error:
      return Colors.red;
    case SnackBarStatus.deleted:
      return Colors.orange;
    default:
      return Colors.blue; // Default color if none of the above match
  }
}

// Function to show SnackBar
void showSnackBar(BuildContext context, String message, SnackBarStatus status,
    {int seconds = 2}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: getSnackBarColor(status),
      duration: Duration(seconds: seconds),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        },
        textColor: Colors.white,
      ),
    ),
  );
}

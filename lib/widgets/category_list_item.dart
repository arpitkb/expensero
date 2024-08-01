import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CategoryListItem({
    Key? key,
    required this.category,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return ListTile(
  //     title: Text(category.name),
  //     trailing: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         IconButton(
  //           icon: Icon(Icons.edit),
  //           onPressed: onEdit,
  //         ),
  //         IconButton(
  //           icon: Icon(Icons.delete),
  //           onPressed: onDelete,
  //         ),
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: const BoxDecoration(
            border: BorderDirectional(
                bottom: BorderSide(color: Colors.black, width: .5))),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          title: Text(
            category.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          onTap: onEdit,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

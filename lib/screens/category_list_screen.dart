import 'package:expensero/utils/snack_bar.dart';
import 'package:expensero/widgets/category_list_item.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_helper.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  Future<void> _refreshCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return CategoryListItem(
              category: category,
              onDelete: () => _showDeleteCategoryDialog(category),
              onEdit: () => _showAddorUpdateCategoryDialog(category));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddorUpdateCategoryDialog(null);
        },
      ),
    );
  }

  Future<void> _showAddorUpdateCategoryDialog(cat) async {
    final textController = TextEditingController();
    if (cat != null) textController.text = cat.name;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(cat != null ? 'Edit ra' : 'Add Category'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Category name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(cat != null ? 'Update' : 'Add'),
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  try {
                    final category = cat == null
                        ? Category(name: textController.text)
                        : Category(id: cat.id, name: textController.text);
                    if (cat == null) {
                      await DatabaseHelper.instance.insertCategory(category);
                      _refreshCategories();
                      // ignore: use_build_context_synchronously
                      showSnackBar(context, 'Category created successfully!',
                          SnackBarStatus.create,
                          seconds: 2);
                    } else {
                      await DatabaseHelper.instance.updateCategory(category);
                      _refreshCategories();
                      // ignore: use_build_context_synchronously
                      showSnackBar(context, 'Category updated successfully!',
                          SnackBarStatus.update,
                          seconds: 2);
                    }
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    showSnackBar(context, e.toString(), SnackBarStatus.error,
                        seconds: 2);
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteCategoryDialog(Category category) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure you want to Delete?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await DatabaseHelper.instance.deleteCategory(category.id!);
                  _refreshCategories();
                  // ignore: use_build_context_synchronously
                  showSnackBar(context, 'Deleted Category Successfully',
                      SnackBarStatus.deleted,
                      seconds: 2);
                } catch (e) {
                  // print('Error: $e');
                  showSnackBar(
                      // ignore: use_build_context_synchronously
                      context,
                      'Failed to delete the Category, Please try again!',
                      SnackBarStatus.error,
                      seconds: 2);
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

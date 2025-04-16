
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  List<File> _imageFiles = [];
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles = pickedFiles.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  Future<List<String>> uploadImages() async {
    List<String> downloadUrls = [];
    for (var imageFile in _imageFiles) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
      FirebaseStorage.instance.ref().child('listing_images').child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<void> addListing() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one image")),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        List<String> imageUrls = await uploadImages();
        String sellerId =
            FirebaseAuth.instance.currentUser?.email ?? "Unknown";

        await FirebaseFirestore.instance.collection('Listings').add({
          'title': titleController.text,
          'description': descriptionController.text,
          'price': double.tryParse(priceController.text) ?? 0.0,
          'imageUrls': imageUrls,
          'sellerId': sellerId,
          'createdAt': DateTime.now().toIso8601String(),
        });

        titleController.clear();
        descriptionController.clear();
        priceController.clear();
        setState(() {
          _imageFiles = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Listing added successfully")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Row(
          children: [
            Icon(
              Icons.add_business_rounded,
              size: 32,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(width: 10),
            const Text(
              "Add Listing",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      backgroundColor: colorScheme.background,
      body: _isUploading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Preview Section
                _imageFiles.isNotEmpty
                    ? SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _imageFiles[index],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: colorScheme.primary, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      "No images selected",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Select Images Button
                ElevatedButton.icon(
                  onPressed: pickImages,
                  icon: Icon(Icons.image, color: colorScheme.onPrimary),
                  label: const Text("Select Images"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title Field
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Description Field
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Price Field
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a price";
                    }
                    if (double.tryParse(value) == null) {
                      return "Enter a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                // Submit Button
                ElevatedButton(
                  onPressed: addListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Add Listing",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

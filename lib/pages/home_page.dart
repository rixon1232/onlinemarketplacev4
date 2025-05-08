import 'package:flutter/material.dart';
import 'package:marketplaceappv4/components/listing_widgets.dart';
import 'package:marketplaceappv4/components/my_drawer.dart';

class ToggleHomePage extends StatefulWidget {
  const ToggleHomePage({Key? key}) : super(key: key);

  @override
  _ToggleHomePageState createState() => _ToggleHomePageState();
}

class _ToggleHomePageState extends State<ToggleHomePage> {
  bool isGridView = true;
  String searchQuery = "";

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
              'Marketplace',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_agenda : Icons.slideshow,
              color: colorScheme.onPrimary,
            ),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          //banner
          Container(
            width: double.infinity,
            color: Colors.yellow.shade100,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.black54),
                SizedBox(width: 8),
                Expanded(
                  child: Text(

                    'Tips: dont accept online payments and read reviews before buying ',

                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },

              decoration: InputDecoration(
                hintText: "Search listings...",
                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(14),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Header row showing "New Listings"
          Container(
            width: double.infinity,
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              "New Listings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

            ),
          ),
          Expanded(
            child: isGridView
                ? GridListingView(colorScheme: colorScheme, searchQuery: searchQuery)
                : ScrollListingView(colorScheme: colorScheme, searchQuery: searchQuery),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_listing');

        },
        child: Icon(Icons.add, color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}


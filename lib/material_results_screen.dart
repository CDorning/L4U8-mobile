import 'package:flutter/material.dart';
import 'database_helper.dart';

class MaterialResultsScreen extends StatelessWidget {
  final String materialName;
  const MaterialResultsScreen({Key? key, required this.materialName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Where to Recycle: $materialName'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getDistrictsForMaterial(materialName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('This item is not recycled in any trial districts.'));
          }

          final districts = snapshot.data!;
          return ListView.builder(
            itemCount: districts.length,
            itemBuilder: (context, index) {
              final district = districts[index];
              return Card(
                child: ListTile(
                  title: Text(district['name']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
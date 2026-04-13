import 'package:flutter/material.dart';
import 'database_helper.dart';

class DistrictResultsScreen extends StatefulWidget {
  final String districtName;
  const DistrictResultsScreen({Key? key, required this.districtName}) : super(key: key);

  @override
  _DistrictResultsScreenState createState() => _DistrictResultsScreenState();
}

class _DistrictResultsScreenState extends State<DistrictResultsScreen> {
  late Future<List<Map<String, dynamic>>> _recyclingRules;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  void _loadRules() {
    _recyclingRules = DatabaseHelper.instance.getRulesForDistrict(widget.districtName);
  }

  // DISTINCTION FEATURE: Handle the deletion
  void _handleDelete(String materialName) {
    setState(() {
      DatabaseHelper.instance.deleteRule(widget.districtName, materialName);
      // Reload the data from the DB to reflect the change
      _loadRules(); 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$materialName removed from ${widget.districtName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recycling in ${widget.districtName}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recyclingRules,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No information found for this district.'));
          }

          final rules = snapshot.data!;
          return ListView.builder(
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              final material = rule['material_name'];
              final isRecyclable = rule['is_recyclable'] == 1;

              // DISTINCTION FEATURE: Using Dismissible for swipe gesture
              return Dismissible(
                key: Key(material),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                   _handleDelete(material);
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      isRecyclable ? Icons.check_circle : Icons.cancel,
                      color: isRecyclable ? Colors.green : Colors.red,
                    ),
                    title: Text(material),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
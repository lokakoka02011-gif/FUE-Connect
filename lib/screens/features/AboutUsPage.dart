import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});


  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: fueRed.withOpacity(0.05),
                border: const Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.hub_rounded, size: 80, color: fueRed),
                  const SizedBox(height: 16),
                  const Text(
                    "FUE Connect",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: fueRed),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Centralizing Student Life & Opportunities",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700], fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("The Project", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fueRed)),
                  const SizedBox(height: 12),
                  Text(
                    "FUE Connect is a graduation project designed to solve the fragmentation of university communication. By integrating Firebase with Flutter, we created a high-performance hub for the FUE community.",
                    style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),

            const Divider(height: 10, indent: 30, endIndent: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Meet The Team", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fueRed)),
                  const SizedBox(height: 16),
                  
                  // load team members men Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('isTeamMember', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Text("Error loading team.");
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingIndicator();
                      }

                      final teamDocs = snapshot.data!.docs;
                      teamDocs.sort((a, b) {
                        final dataA = a.data() as Map<String, dynamic>;
                        final dataB = b.data() as Map<String, dynamic>;

                        final nameA = "${dataA['firstName'] ?? ''} ${dataA['lastName'] ?? ''}".toLowerCase();
                        final nameB = "${dataB['firstName'] ?? ''} ${dataB['lastName'] ?? ''}".toLowerCase();

                        return nameA.compareTo(nameB);
                      });                      

                      if (teamDocs.isEmpty) {
                        return const Text("No team members found in database.");
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: teamDocs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          var data = teamDocs[index].data() as Map<String, dynamic>;
                          
                          return _buildTeamMember(
                            "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}",
                            data['teamRole'] ?? "Team Member", 
                            description: data['description'] ?? "No bio available.",
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, String role, 
      {required String description}) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.grey[600]),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.normal)),
        subtitle: Text(role, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
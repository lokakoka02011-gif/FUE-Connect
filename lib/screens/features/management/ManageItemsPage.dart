import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fue_connect/screens/features/management/AddItemsPage.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';
import 'package:fue_connect/widgets/filter_pills.dart';

class ManageItemsPage extends StatefulWidget {
  final String title;
  final bool isAdmin;
  final String collectionPath;
  final String? itemType;

  const ManageItemsPage({
    super.key,
    required this.title,
    required this.collectionPath,
    this.isAdmin = false,
    this.itemType,

  });

  @override
  State<ManageItemsPage> createState() => _ManageItemsPageState();
}

class _ManageItemsPageState extends State<ManageItemsPage> {
  // COLLECTION TYPES
  bool get isOpportunities => widget.collectionPath == "opportunities";

  bool get isUsers => widget.collectionPath == "users";

  bool get isPosts => widget.collectionPath == "posts";

  bool get isClubs => widget.collectionPath == "Clubs";

  bool get isEvents => widget.collectionPath == "Events";

  bool get isVolunteering => widget.collectionPath == "volunteering";

  // FILTER
  String selectedFilter = "all";

  // DELETE ITEM
  Future<void> deleteItem(String docId) async {
    final confirm = await _showDeleteDialog();

    if (!confirm) return;

    await FirebaseFirestore.instance
        .collection(widget.collectionPath)
        .doc(docId)
        .delete();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Deleted successfully")));
    }
  }

  // UPDATE STATUS
  Future<void> updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection(widget.collectionPath)
        .doc(docId)
        .update({'status': status});

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Updated to $status")));
    }
  }

  // DELETE DIALOG
  Future<bool> _showDeleteDialog() async {
    return await showDialog(
          context: context,

          builder: (ctx) {
            return AlertDialog(
              title: const Text("Delete Item?"),

              content: const Text("This action cannot be undone."),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),

                  child: const Text("Cancel"),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),

                  child: const Text(
                    "Delete",

                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // STATUS COLOR
  Color getStatusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      case "pending":
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  // OPEN ADD / EDIT PAGE
  void openEditor({String? docId, Map<String, dynamic>? data}) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) => AddEditItemPage(
          collectionPath: widget.collectionPath,

          docId: docId,

          itemData: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),

        backgroundColor: fueRed,

        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // FILTER PILLS
          if (isOpportunities)
            Padding(
              padding: const EdgeInsets.all(12),

              child: FilterPills(
                options: const ["all", "pending", "approved", "rejected"],

                selected: selectedFilter,

                onSelected: (value) {
                  setState(() {
                    selectedFilter = value;
                  });
                },
              ),
            ),

          // LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (() {
                Query query = FirebaseFirestore.instance
                    .collection(widget.collectionPath);

                if (widget.itemType != null) {
                  query = query.where(
                    'type',
                    isEqualTo: widget.itemType,
                  );
                }

                return query
                    .orderBy("createdAt", descending: true)
                    .snapshots();
              })(),
              builder: (context, snapshot) {
                // ERROR
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  );
                }

                // LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                }

                // FILTER DOCS
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (!widget.isAdmin &&
                      isOpportunities &&
                      data['createdBy'] !=
                          FirebaseAuth.instance.currentUser?.uid) {
                    return false;
                  }
                  // USERS
                  if (isUsers && data['role'] != 'student') {
                    return false;
                  }

                  // OPPORTUNITIES FILTER
                  if (isOpportunities && selectedFilter != "all") {
                    return data['status'] == selectedFilter;
                  }

                  return true;
                }).toList();

                // EMPTY
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: const [
                        Icon(Icons.inbox, size: 65, color: Colors.grey),

                        SizedBox(height: 10),

                        Text("No items found"),

                        SizedBox(height: 5),

                        Text(
                          "Tap + to add items",

                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // LIST
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90),

                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    final doc = docs[index];

                    final data = doc.data() as Map<String, dynamic>;

                    final String docId = doc.id;

                    final imageUrl = data['imgUrl'];

                    final String status = data['status'] ?? "pending";

                    // DISPLAY TITLE
                    final displayTitle =
                        // USERS
                        isUsers
                        ? data['fullName'] ??
                              data['studentId'] ??
                              data['id'] ??
                              data['email']?.toString().split("@").first ??
                              "Unknown Student"
                        // POSTS
                        : isPosts
                        ? data['title'] ?? data['clubName'] ?? "Untitled Post"
                        // DEFAULT
                        : data['title'] ?? data['name'] ?? "No Title";

                    // DISPLAY SUBTITLE
                    final displaySubtitle = isUsers
                        ? """
                    Email: ${data['email'] ?? 'N/A'}

                    Phone: ${data['phone'] ?? 'N/A'}

                    Faculty: ${data['faculty'] ?? 'N/A'}

                    Year: ${data['year'] ?? 'N/A'}

                    GPA: ${data['gpa'] ?? 'N/A'}

                    Skills: ${data['skills'] is List ? (data['skills'] as List).join(', ') : data['skills'] ?? 'N/A'}

                    Interests: ${data['interests'] is List ? (data['interests'] as List).join(', ') : data['interests'] ?? 'N/A'}

                    Bio: ${data['bio'] ?? 'N/A'}
                    """
                        : data['description'] ??
                              data['content'] ??
                              data['bio'] ??
                              "";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),

                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Column(
                          children: [
                            ListTile(
                              // IMAGE
                              leading:
                                  imageUrl != null &&
                                      imageUrl.toString().isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),

                                      child: Image.network(
                                        imageUrl,

                                        width: 55,
                                        height: 55,

                                        fit: BoxFit.cover,

                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 55,

                                                height: 55,

                                                color: Colors.grey[300],

                                                child: const Icon(
                                                  Icons.broken_image,

                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                      ),
                                    )
                                  : Container(
                                      width: 55,
                                      height: 55,

                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: Icon(
                                        isUsers
                                            ? Icons.person
                                            : isPosts
                                            ? Icons.article
                                            : isClubs
                                            ? Icons.groups
                                            : isEvents
                                            ? Icons.event
                                            : Icons.image,

                                        color: Colors.grey,
                                      ),
                                    ),

                              // TITLE
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayTitle,

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,

                                        fontSize: 16,
                                      ),
                                    ),
                                  ),

                                  // STATUS BADGE
                                  if (isOpportunities)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),

                                      decoration: BoxDecoration(
                                        color: getStatusColor(status),

                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      child: Text(
                                        status.toUpperCase(),

                                        style: const TextStyle(
                                          color: Colors.white,

                                          fontSize: 11,

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              // SUBTITLE
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const SizedBox(height: 6),

                                  Text(
                                    displaySubtitle,

                                    maxLines: isUsers ? 20 : 2,

                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 8),

                                  // TYPE
                                  if (data['type'] != null)
                                    Text(
                                      data['type'],

                                      style: const TextStyle(
                                        fontSize: 12,

                                        color: Colors.grey,
                                      ),
                                    ),

                                  // CATEGORY
                                  if (data['category'] != null)
                                    Text(
                                      data['category'],

                                      style: const TextStyle(
                                        fontSize: 12,

                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // APPROVE / REJECT
                            if (isOpportunities && widget.isAdmin)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),

                                child: Row(
                                  children: [
                                    // APPROVE
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),

                                        onPressed: status == "approved"
                                            ? null
                                            : () => updateStatus(
                                                docId,
                                                "approved",
                                              ),

                                        child: const Text(
                                          "APPROVE",

                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    // REJECT
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),

                                        onPressed: status == "rejected"
                                            ? null
                                            : () => updateStatus(
                                                docId,
                                                "rejected",
                                              ),

                                        child: const Text(
                                          "REJECT",

                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ACTIONS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,

                              children: [
                                // EDIT
                                if (!isUsers)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),

                                    onPressed: () {
                                      openEditor(docId: docId, data: data);
                                    },
                                  ),

                                // DELETE
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,

                                    color: fueRed,
                                  ),

                                  onPressed: () => deleteItem(docId),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ADD BUTTON
      floatingActionButton: isUsers
          ? null
          : FloatingActionButton(
              backgroundColor: fueRed,

              child: const Icon(Icons.add, color: Colors.white),

              onPressed: () {
                openEditor();
              },
            ),
    );
  }
}

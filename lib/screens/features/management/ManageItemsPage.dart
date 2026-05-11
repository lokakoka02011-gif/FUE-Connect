import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fue_connect/screens/features/management/AddItemsPage.dart';
import 'package:fue_connect/widgets/loading_indicator.dart';

class ManageItemsPage extends StatefulWidget {

  final String title;
  final bool isAdmin;
  final String collectionPath;

  const ManageItemsPage({
    super.key,
    required this.title,
    required this.collectionPath,
    this.isAdmin = false
  });

  @override
  State<ManageItemsPage> createState() =>
      _ManageItemsPageState();
}

class _ManageItemsPageState
    extends State<ManageItemsPage> {

  bool get isOpportunities =>
      widget.collectionPath ==
      "opportunities";

  Future<void> deleteItem (
    String docId,
  ) async {

    bool confirm =
        await _showDeleteDialog();

  if (confirm) {

      await FirebaseFirestore
          .instance
          .collection(
            widget.collectionPath,
          )
          .doc(docId)
          .delete();

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Item deleted successfully",
            ),
          ),
        );
      }
    };
  }

  Future<void> updateStatus(
    String docId,
    String status,
  ) async {

    await FirebaseFirestore.instance
        .collection(
          widget.collectionPath,
        )
        .doc(docId)
        .update({

      'status': status,
    });

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(

            "Opportunity $status",
          ),
        ),
      );
    }
  }

  Future<bool> _showDeleteDialog() async {

    return await showDialog(

          context: context,

          builder: (ctx) => AlertDialog(

            title:
                const Text("Delete Item?"),

            content: const Text(
              "This action cannot be undone.",
            ),

            actions: [

              TextButton(

                onPressed: () =>
                    Navigator.pop(
                  ctx,
                  false,
                ),

                child:
                    const Text("Cancel"),
              ),

              TextButton(

                onPressed: () =>
                    Navigator.pop(
                  ctx,
                  true,
                ),

                child: const Text(

                  "Delete",

                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Color getStatusColor(
    String status,
  ) {

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

  @override
  Widget build(BuildContext context) {

    const Color fueRed =
        Color(0xffb1170c);

    return Scaffold(

      appBar: AppBar(

        title: Text( widget.title,
        ),

        backgroundColor: fueRed,

        foregroundColor:
            Colors.white,
      ),

      body:
          StreamBuilder<QuerySnapshot>(

        stream:
            FirebaseFirestore.instance

                .collection(
                  widget.collectionPath,
                )

                .snapshots(),

        builder: (
          context,
          snapshot,
        ) {

          if (snapshot.hasError) {

            return const Center(
              child:
                  Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
                  LoadingIndicator(),
            );
          }

          final docs =
              snapshot.data!.docs;

          if (docs.isEmpty) {

            return Center(

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: const [

                  Icon(
                    Icons.inbox,
                    size: 60,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 10),

                  Text("No items yet"),

                  Text(

                    "Tap + to add new data",

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(

            itemCount: docs.length,

            itemBuilder: (
              context,
              index,
            ) {

              final data =
                  docs[index].data()
                      as Map<String, dynamic>;

              final String docId =
                  docs[index].id;

              final String status =
                  data['status'] ??
                      "pending";

              return Card(

                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),

                elevation: 3,

                child: Padding(

                  padding:
                      const EdgeInsets.all(
                    8,
                  ),

                  child: Column(

                    children: [

                      ListTile(

                        leading:
                            data['imageUrl'] !=
                                    null

                                ? ClipRRect(

                                    borderRadius:
                                        BorderRadius.circular(
                                      8,
                                    ),

                                    child:
                                        Image.network(

                                      data['imageUrl'],

                                      width: 55,
                                      height: 55,

                                      fit: BoxFit.cover,
                                    ),
                                  )

                                : const Icon(
                                    Icons.image,
                                    size: 40,
                                  ),

                        title: Row(

                          children: [

                            Expanded(

                              child: Text(

                                data['title'] ??

                                    data['name'] ??

                                    'No Title',

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            if (isOpportunities)

                              Container(

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      getStatusColor(
                                    status,
                                  ),

                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: Text(

                                  status
                                      .toUpperCase(),

                                  style:
                                      const TextStyle(

                                    color:
                                        Colors.white,

                                    fontSize: 11,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        subtitle: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const SizedBox(
                                height: 5),

                            Text(

                              data['description'] ??

                                  data['Description'] ??

                                  '',

                              maxLines: 2,

                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),

                            const SizedBox(
                                height: 6),

                            Text(

                              data['type'] ??
                                  'Unknown',

                              style:
                                  const TextStyle(

                                fontSize: 12,

                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isOpportunities && widget.isAdmin)

                        Padding(

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),

                          child: Row(

                            children: [

                              // APPROVE
                              Expanded(

                                child:
                                    ElevatedButton(

                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.green,
                                  ),

                                  onPressed:
                                      status ==
                                              "approved"

                                          ? null

                                          : () =>
                                              updateStatus(
                                                docId,
                                                "approved",
                                              ),

                                  child:
                                      const Text(
                                    "APPROVE",
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 10),

                              // REJECT
                              Expanded(

                                child:
                                    ElevatedButton(

                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.red,
                                  ),

                                  onPressed:
                                      status ==
                                              "rejected"

                                          ? null

                                          : () =>
                                              updateStatus(
                                                docId,
                                                "rejected",
                                              ),

                                  child:
                                      const Text(
                                    "REJECT",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // EDIT + DELETE
                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.end,

                        children: [

                          IconButton(

                            icon: const Icon(
                              Icons.edit,
                              color:
                                  Colors.blue,
                            ),

                            onPressed: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      AddEditItemPage(

                                    collectionPath:
                                        widget.collectionPath,

                                    docId: docId,

                                    itemData:
                                        data,
                                  ),
                                ),
                              );
                            },
                          ),

                          IconButton(

                            icon: const Icon(

                              Icons.delete_outline,

                              color: fueRed,
                            ),

                            tooltip:
                                "Delete",

                            onPressed: () =>
                                deleteItem(
                              docId,
                            ),
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

      floatingActionButton:
          FloatingActionButton(

        backgroundColor: fueRed,

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  AddEditItemPage(

                collectionPath:
                    widget.collectionPath,
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ode2code/dashboard/product_util.dart';
import 'package:ode2code/utils.dart';

class AllProducts extends StatelessWidget {
  AllProducts({Key? key, this.index}) : super(key: key);
  String? index;

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamQuery() {
    if (index == null || index!.isEmpty) {
      return FirebaseFirestore.instance.collection('products').snapshots();
    }
    return FirebaseFirestore.instance
        .collection('products')
        .where("tag",
            arrayContains: index.toString().removeAllWhitespace.toLowerCase())
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController();
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    splashColor: Colors.orange,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                    ),
                    iconSize: 30,
                  ),
                  Text(
                    "Back",
                    style: normaltextsyle(size: 17),
                  )
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: getStreamQuery(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // return const SliverToBoxAdapter(child: Text("Hello"));
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    mainAxisSpacing: 15.0,
                    crossAxisSpacing: 0.0,
                    childAspectRatio: 0.6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      DocumentSnapshot _doc = snapshot.data!.docs[index];
                      Product product = Product();
                      product.fromSnapshot(_doc);
                      return productBox(product);
                    },
                    childCount: snapshot.data!.size,
                  ),
                );
              } else {
                return const SliverToBoxAdapter(child: Text("No data"));
              }
            },
          ),
        ],
      ),
    );
  }
}

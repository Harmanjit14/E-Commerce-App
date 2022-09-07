import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ode2code/dashboard/product_util.dart';
import 'package:ode2code/utils.dart';

class Order {
  String? image, title, subtitle, id, paymentId, status;
  int? price;

  fromSnapshot(DocumentSnapshot data) {
    try {
      image = data.get("image") ?? "";
      title = data.get("title") ?? "";
      subtitle = data.get("subtitle") ?? "";
      price = data.get("price") ?? 0;
      id = data.get("id") ?? "";
      paymentId = data.get("paymentId");
      status = data.get("status");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Your Past orders",
                style: boldtextsyle(size: 22, shadow: true),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("orders")
                .where("userId",
                    isEqualTo:
                        FirebaseAuth.instance.currentUser!.uid.toString())
                .snapshots(),
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
                      Order product = Order();
                      product.fromSnapshot(_doc);
                      return orderBox(product);
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

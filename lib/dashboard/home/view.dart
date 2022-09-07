import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ode2code/dashboard/all_products.dart';
import 'package:ode2code/dashboard/chat.dart';
import 'package:ode2code/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ListView(
      shrinkWrap: true,
      children: [
        SeachBar(_searchController),
        const TopNavbar(),
        const OffersList(),
        const PageStrip(),
      ],
    );
  }
}

class SeachBar extends StatefulWidget {
  final TextEditingController _searchController;
  const SeachBar(this._searchController, {super.key});

  @override
  State<SeachBar> createState() => _SeachBarState();
}

class _SeachBarState extends State<SeachBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 65,
      width: double.maxFinite,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: const [BoxShadow(blurRadius: 1, color: Colors.grey)]),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              Icons.search,
              color: Colors.orange[800],
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextFormField(
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'type anything to continue';
                  }
                  return null;
                },
                controller: widget._searchController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    hintText: "Search anything ...",
                    border: InputBorder.none,
                    hintStyle: normaltextsyle(
                      size: 16,
                      color: Colors.grey[700],
                    )
                    // prefixIcon: Icon(Icons.email)
                    ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.camera, color: Colors.orange[800]),
            ),
            IconButton(
              onPressed: () {
                Get.to(()=>const Chat());
              },
              icon: Icon(Icons.mic, color: Colors.orange[800]),
            ),
          ],
        ),
      ),
    );
  }
}

class TopNavbar extends StatefulWidget {
  const TopNavbar({super.key});

  @override
  State<TopNavbar> createState() => _TopNavbarState();
}

class _TopNavbarState extends State<TopNavbar> {
  final _navList = [
    "Mobile",
    "Electronics",
    "Fashion",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ListView.builder(
        itemCount: _navList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: ((context, index) {
          return Container(
            width: 90,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.grey, blurRadius: 1)
                ]),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/${_navList[index].toLowerCase()}.png",
                    height: 50,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    _navList[index],
                    style: normaltextsyle(size: 12),
                  )
                ],
              ),
              onTap: () {
                Get.to(() => AllProducts(
                      index: _navList[index],
                    ));
              },
            ),
          );
        }),
      ),
    );
  }
}

class OffersList extends StatefulWidget {
  const OffersList({super.key});

  @override
  State<OffersList> createState() => _OffersListState();
}

class _OffersListState extends State<OffersList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("offers").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.orange[800],
              ),
              const SizedBox(height: 15),
              const Text("Loading.."),
            ],
          ));
        } else if (snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.all(15),
          height: 190,
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Offers for you!",
                style: boldtextsyle(size: 22, shadow: true),
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    String text = data["text"];
                    String code = data["code"];
                    double length_text = (18 * 42) / text.length;
                    return Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 7, 0),
                      child: InkWell(
                        onTap: ()async {
                          Get.to(() => AllProducts(
                                index: code.removeAllWhitespace,
                              ));
                        },
                        child: Container(
                          width: 250,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.orange[800],
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 2,
                                  color: Colors.grey,
                                )
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                text,
                                textAlign: TextAlign.center,
                                style: boldtextsyle(
                                    size: 20,
                                    color: Colors.white,
                                    shadow: true),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Use Code",
                                      style: normaltextsyle(
                                          size: 10, color: Colors.black),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "#$code",
                                      style: boldtextsyle(
                                          size: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PageStrip extends StatefulWidget {
  const PageStrip({super.key});

  @override
  State<PageStrip> createState() => _PageStripState();
}

class _PageStripState extends State<PageStrip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 0),
      width: double.maxFinite,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              Get.to(() => AllProducts());
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 2,
                      color: Colors.grey,
                    ),
                  ]),
              child: Text(
                "All Products",
                style: boldtextsyle(
                    size: MediaQuery.of(context).size.width / 20,
                    color: Colors.black),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Get.to(AllProducts(
                index: "accessories",
              ));
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 2,
                      color: Colors.grey,
                    ),
                  ]),
              child: Text(
                "All Accessories",
                style: boldtextsyle(
                    size: MediaQuery.of(context).size.width / 20,
                    color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ode2code/dashboard/product_util.dart';
import 'package:ode2code/utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

const keyId = "rzp_test_i8d2uKfBweeePq";
const keySecret = "awN41fbQ6XNNYWbqQIz4QKEZ";

class ProductInfo extends GetxController {
  RxInt selectedSize = (-1).obs;
}

class ProductScreen extends StatefulWidget {
  ProductScreen(
    this.product, {
    Key? key,
  }) : super(key: key);
  final Product? product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final productInfo = Get.put(ProductInfo());

  late final _controller;
  final _razorpay = Razorpay();

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    var user = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('orders').add({
      'orderId': response.orderId,
      'paymentId': response.paymentId,
      'userId': user,
      'title': widget.product!.title,
      'subtitle': widget.product!.subtitle,
      'price': widget.product!.price,
      'status':"Order Placed",
      'image':widget.product!.image
    });
    await Fluttertoast.showToast(
        msg: "Your Order is placed Successfully!",
        gravity: ToastGravity.BOTTOM);
    return;
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    // Do something when payment fails
    await Fluttertoast.showToast(
        msg:
            "Failed to place order. If amount deducted from bank, will be reverted back in 3-7 days.",
        gravity: ToastGravity.BOTTOM);
    return;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  Future<void> generateODID(int amount) async {
    var orderOptions = {
      'amount': amount * 100, // amount in the smallest currency unit
      'currency': "INR",
      'receipt': "order_rcptid_11"
    };
    final client = HttpClient();
    final request =
        await client.postUrl(Uri.parse('https://api.razorpay.com/v1/orders'));
    request.headers
        .set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}';
    request.headers.set(HttpHeaders.authorizationHeader, basicAuth);
    request.add(utf8.encode(json.encode(orderOptions)));
    final response = await request.close();
    response.transform(utf8.decoder).listen((contents) {
      debugPrint('ORDERID$contents');
      String orderId = contents.split(',')[0].split(":")[1];
      orderId = orderId.substring(1, orderId.length - 1);

      Fluttertoast.showToast(
          msg: "ORDERID: $orderId", toastLength: Toast.LENGTH_SHORT);

      Map<String, dynamic> checkoutOptions = {
        'key': keyId,
        'amount': amount * 100,
        'name': widget.product!.title!,
        'description': 'Test payment for product ${widget.product!.title!}',
        'prefill': {
          'contact': '7888742774',
          'email': 'singhgagandeep8056@gmail.com'
        },
      };
      try {
        _razorpay.open(checkoutOptions);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _controller = YoutubePlayerController(
      initialVideoId: widget.product!.video ?? "MV_WiHaUEbQ",
      flags: const YoutubePlayerFlags(
        startAt: 0,
        autoPlay: false,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      bottomSheet: SizedBox(
        height: 70,
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: MaterialButton(
                      elevation: 5,
                      onPressed: () {
                        generateODID(widget.product!.price!);
                      },
                      color: Colors.orange.shade800,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.creditCard,
                            color: Colors.grey[300],
                            size: 20,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            "Buy",
                            style:
                                boldtextsyle(size: 14, color: Colors.grey[300]),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
            ],
            backgroundColor: Colors.white,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mi',
                  style: boldtextsyle(size: 20, color: Colors.black),
                ),
              ],
            ),
            stretch: true,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  PageView.builder(
                      itemCount: widget.product!.imagelist!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: size.width,
                          height: double.maxFinite,
                          child: Image.network(
                            widget.product!.imagelist![index],
                            fit: BoxFit.contain,
                          ),
                        );
                      }),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(blurRadius: 4, color: Colors.grey)
                              ]),
                          height: 30,
                          width: 70,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${widget.product!.rating!}",
                                style:
                                    boldtextsyle(size: 15, color: Colors.black),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.green,
                                size: 17,
                              )
                            ],
                          )),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          "(swipe to see more pics)",
                          style: normaltextsyle(size: 10),
                        )),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 5, color: Colors.grey)
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.product!.title!,
                        style: boldtextsyle(size: 20),
                      ),
                      const SizedBox(
                        height: 0,
                        width: 5,
                      ),
                      Text(
                        widget.product!.subtitle!,
                        style:
                            mediumtextsyle(size: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Rs. ${widget.product!.price!}",
                    style: boldtextsyle(
                        size: 22, shadow: false, color: Colors.orange[800]),
                  ),
                  Text(
                    "(inclusive all taxes)",
                    style: normaltextsyle(size: 13, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ),
          if (widget.product!.sizes!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(blurRadius: 5, color: Colors.grey)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Available Sizes",
                      style: boldtextsyle(size: 16),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.product!.sizes!.length,
                          itemBuilder: (context, index) {
                            List<dynamic> proSize = widget.product!.sizes ?? [];
                            return Obx(
                              () => Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                child: FloatingActionButton(
                                  heroTag: "$index",
                                  backgroundColor:
                                      (productInfo.selectedSize.value == index)
                                          ? Colors.orange[800]
                                          : Colors.white,
                                  onPressed: () {
                                    productInfo.selectedSize.value = index;
                                  },
                                  child: Text(
                                    "${widget.product!.sizes![index]}'",
                                    style: boldtextsyle(
                                      size: 13,
                                      color: (productInfo.selectedSize.value ==
                                              index)
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.product!.colors!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(blurRadius: 5, color: Colors.grey)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Available Colors",
                      style: boldtextsyle(size: 16),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.product!.colors!.length,
                          itemBuilder: (context, index) {
                            List<dynamic> proSize =
                                widget.product!.colors ?? [];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: FloatingActionButton(
                                heroTag: "color$index",
                                backgroundColor:
                                    Color(widget.product!.colors![index]),
                                onPressed: () {},
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.product!.details!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(blurRadius: 5, color: Colors.grey)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Product Details",
                      style: boldtextsyle(size: 16),
                    ),
                    SizedBox(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: widget.product!.details!.length,
                          itemBuilder: (context, index) {
                            return Text(
                              "${index + 1}. ${widget.product!.details![index]}",
                              style: boldtextsyle(
                                size: 13,
                                color: Colors.grey[700],
                              ),
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Build",
                      style: boldtextsyle(size: 16),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      "Plastic",
                      style: boldtextsyle(
                        size: 13,
                        color: Colors.grey[700],
                      ),
                    )
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 5, color: Colors.grey)
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Product Video",
                    style: boldtextsyle(
                        size: 16, shadow: false, color: Colors.black),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: YoutubePlayer(
                        aspectRatio: 4 / 3,
                        controller: _controller,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 5, color: Colors.grey)
                  ]),
              child: Flex(
                direction: Axis.vertical,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Comments and Reviews",
                    style: boldtextsyle(
                        size: 16, shadow: false, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "From People you may Know..",
                    style: mediumtextsyle(size: 14, color: Colors.orange[900]),
                  ),
                  Text(
                    "(Swipe to view more...)",
                    style: normaltextsyle(size: 11, color: Colors.orange[900]),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 100,
                    child:
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection("products")
                          .doc(widget.product!.id!
                              .toString()
                              .removeAllWhitespace)
                          .snapshots(),
                      builder: (context, snapshot) {
                        // print(snapshot.data!.data());
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          );
                        } else if (snapshot.hasError ||
                            snapshot.data.isBlank!) {
                          return Center(
                            child: Text(
                              "No Data...",
                              style:
                                  boldtextsyle(size: 15, color: Colors.black),
                            ),
                          );
                        } else if (snapshot.data!.get("comments").length == 0) {
                          return Center(
                            child: Text(
                              "No Data...",
                              style:
                                  boldtextsyle(size: 15, color: Colors.black),
                            ),
                          );
                        }
                        return PageView.builder(
                            // physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                (snapshot.data!.get("comments").length < 10)
                                    ? snapshot.data!.get("comments").length
                                    : 10,
                            itemBuilder: (context, index) {
                              Map<dynamic, dynamic> map =
                                  snapshot.data!.get("comments")[index];
                              // print(map.values.elementAt(index));

                              return SizedBox(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "${map["name"]}",
                                              style: mediumtextsyle(
                                                  size: 14,
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              "(${map["job"]})",
                                              style: normaltextsyle(
                                                  size: 10,
                                                  color: Colors.grey[700]),
                                            ),
                                          ],
                                        ),
                                        starbuilder(map["rating"]),
                                      ],
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      "\"${map["comment"]}\"",
                                      style: boldtextsyle(
                                          size: 15, color: Colors.grey[800]),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                    ),
                  ),
                  TextButton.icon(
                      style: const ButtonStyle(
                          //  splashFactory: InkSplash,
                          ),
                      onPressed: () {
                        _showMyDialog(context, widget.product!);
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.comments,
                        color: Colors.orange[900],
                      ),
                      label: Text(
                        "Add Comment",
                        style:
                            boldtextsyle(size: 16, color: Colors.orange[900]),
                      ))
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
            ),
          )
        ],
      ),
    );
  }
}

class RatingStars extends GetxController {
  RxInt stars = 0.obs;
}

Future<void> _showMyDialog(BuildContext context, Product product) async {
  final obj = Get.put(RatingStars());
  int star = 0;
  TextEditingController controller = TextEditingController();
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Comment'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rate it',
                    style: mediumtextsyle(size: 13),
                  ),
                  Obx(
                    () => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            obj.stars.value = 1;
                          },
                          child: Icon(
                            Icons.star,
                            size: 20,
                            color: (obj.stars.value < 1)
                                ? Colors.grey
                                : Colors.green,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            obj.stars.value = 2;
                          },
                          child: Icon(
                            Icons.star,
                            size: 20,
                            color: (obj.stars.value < 2)
                                ? Colors.grey
                                : Colors.green,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            obj.stars.value = 3;
                          },
                          child: Icon(
                            Icons.star,
                            size: 20,
                            color: (obj.stars.value < 3)
                                ? Colors.grey
                                : Colors.green,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            obj.stars.value = 4;
                          },
                          child: Icon(
                            Icons.star,
                            size: 20,
                            color: (obj.stars.value < 4)
                                ? Colors.grey
                                : Colors.green,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            obj.stars.value = 5;
                          },
                          child: Icon(
                            Icons.star,
                            size: 20,
                            color: (obj.stars.value < 5)
                                ? Colors.grey
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                maxLines: 3,
                controller: controller,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    hintText: "start typing your review here...",
                    border: InputBorder.none,
                    hintStyle:
                        normaltextsyle(size: 14, color: Colors.grey[700])),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: boldtextsyle(size: 15),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange[800])),
            child: Text(
              'Submit',
              style: boldtextsyle(size: 15, color: Colors.white),
            ),
            onPressed: () async {
              List comments = product.comments ?? [];
              Map data = {
                "comment": controller.text.toString(),
                "name": "Harman", //user.name,
                "job": "SDE at cisco", //user.jobType,
                "rating": obj.stars.value,
              };

              comments.add(data);
              // comments.addAll(finalData);
              print(comments);
              try {
                await FirebaseFirestore.instance
                    .collection("products")
                    .doc(product.id.toString().removeAllWhitespace)
                    .update({"comments": comments}).then((value) {
                  Navigator.pop(context);
                });
              } catch (e) {
                print(e);
              }
            },
          ),
        ],
      );
    },
  );
}

Widget starbuilder(var value) {
  int count = value as int;
  return SizedBox(
    // color: Colors.amber,
    height: 15,
    width: 75,
    child: Flex(
      direction: Axis.horizontal,
      children: [
        SizedBox(
          width: count * 15,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              itemBuilder: (context, index) {
                return const Icon(
                  Icons.star,
                  color: Colors.green,
                  size: 15,
                );
              }),
        ),
        SizedBox(
          width: (5 - count) * 15,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5 - count,
              itemBuilder: (context, index) {
                return const Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: 15,
                );
              }),
        ),
      ],
    ),
  );
}

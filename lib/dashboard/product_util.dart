import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ode2code/dashboard/orders/view.dart';
import 'package:ode2code/dashboard/single_product.dart';
import 'package:ode2code/utils.dart';

class Product {
  String? image, title, subtitle, video, id;
  int? price;
  double? rating;
  List<dynamic>? colors, imagelist, sizes, details, comments;

  fromSnapshot(DocumentSnapshot data) {
    try {
      image = data.get("image") ?? "";
      title = data.get("title") ?? "";
      subtitle = data.get("subtitle") ?? "";
      price = data.get("price") ?? 0;
      video = data.get("video") ?? "";
      rating = data.get("rating") ?? 0;
      colors = data.get("colors") ?? [];
      id = data.get("id") ?? "";
      imagelist = data.get("imagelist") ?? [image];
      sizes = data.get("sizes") ?? [];
      details = data.get("details") ?? [];
      comments = data.get("comments") ?? [];

      debugPrint(
          "***********************************\n$colors\n $comments\n $details\n $id\n $image\n $imagelist\n $price\n $rating\n $sizes\n $subtitle\n $title\n $video\n $rating\n");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

product() {
  return SizedBox(
    height: 150,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5)],
        ),
      ),
    ),
  );
}

productBox(Product product) {
  return SizedBox(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: InkWell(
        onTap: () {
          Get.to(() => ProductScreen(product));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5)],
          ),
          child: Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: SizedBox(
                      // height:100,
                      child: Image.network(
                        product.image!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  product.title ?? "Title",
                  style: boldtextsyle(size: 16, shadow: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  product.subtitle ?? "",
                  style: normaltextsyle(size: 13, color: Colors.grey.shade600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text("Rs. ${product.price}",
                    style: boldtextsyle(
                        size: 18, shadow: true, color: Colors.orange[800])),
              ),
              const SizedBox(
                height: 7,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

orderBox(Order product) {
  return SizedBox(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 5)],
        ),
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  child: SizedBox(
                    // height:100,
                    child: Image.network(
                      product.image!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                product.title ?? "Title",
                style: boldtextsyle(size: 16, shadow: true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                product.subtitle ?? "",
                style: normaltextsyle(size: 13, color: Colors.grey.shade600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text("Rs. ${product.price}",
                  style: boldtextsyle(
                      size: 18, shadow: true, color: Colors.orange[800])),
            ),
            const SizedBox(
              height: 7,
            ),
            
          ],
        ),
      ),
    ),
  );
}

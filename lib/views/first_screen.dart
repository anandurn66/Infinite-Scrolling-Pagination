import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:scrollpage/models/product.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final ScrollController scrollController = ScrollController();
  final Dio dio = Dio();
  @override
  List<Product> products = [];
  int totalProducts = 1000;
  bool isLoading = false;
  @override
  void initState() {
    getProducts();
    // TODO: implement initState
    super.initState();
    scrollController.addListener(loadMoreData);
  }

  Widget build(BuildContext contsext) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyStore'),
      ),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: false,
          controller: scrollController,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final Product = products[index];
            return Column(
              children: [
                ListTile(
                  leading: Text(Product.id.toString()),
                  title: Text(Product.title.toString()),
                  subtitle: Text("\$${Product.price.toString()}"),
                  trailing: Image(
                      width: 150,
                      fit: BoxFit.cover,
                      image: NetworkImage(Product.thumbnail!)),
                ),
                if (index == products.length - 1 && isLoading)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(),
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  void loadMoreData() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        products.length < totalProducts) {
      getProducts();
    }
  }

  Future<void> getProducts() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await dio.get(
          "https://dummyjson.com/products?limit=15&skip=${products.length}&select=title,price,thumbnail");
      final List data = response.data["products"];
      final List<Product> newProducts =
          data.map((p) => Product.fromJson(p)).toList();
      setState(() {
        isLoading = false;
        totalProducts = response.data["total"];
        products.addAll(newProducts);
      });
      print(newProducts);
    } catch (e) {
      print(e);
    }
  }
}

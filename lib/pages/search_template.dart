import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchTemplate extends StatefulWidget {
  List ptdList;
  SearchTemplate({required this.ptdList});
  @override
  _SearchTemplateState createState() => _SearchTemplateState();
}

class _SearchTemplateState extends State<SearchTemplate> {
  List filteredProduct = []; /* USED TO HOLD THE SEARCHED PRODUCT */

  void _filterPtd(value) {
    if (value == '') {
      setState(() {
        filteredProduct = [];
      });
    } else {
      setState(() {
        filteredProduct = widget.ptdList
            .where((ptd) =>
                ptd['name'].toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFF40C4FF),
            Color(0xFFA7FFEB),
          ])),
        ),
        elevation: 0,
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 45,
              ),
              child: TextField(
                enableSuggestions: true,
                autofocus: true,
                onChanged: (value) {
                  _filterPtd(value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search by product name',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: filteredProduct.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {},
              title: Text(
                filteredProduct.toList()[index]['name'].toString(),
                style: GoogleFonts.publicSans(fontSize: 15)
                    .copyWith(overflow: TextOverflow.ellipsis),
                maxLines: 2,
              ),
              subtitle: Text(
                filteredProduct.toList()[index]['category'].toString(),
                style: GoogleFonts.publicSans(fontSize: 11)
                    .copyWith(overflow: TextOverflow.fade),
                maxLines: 1,
              ),
            );
          }),
    );
  }
}

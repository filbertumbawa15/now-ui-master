import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:now_ui_flutter/providers/services.dart';
import 'package:provider/provider.dart';

class FavoritesList extends StatefulWidget {
  final String param;
  const FavoritesList({Key key, this.param}) : super(key: key);

  @override
  State<FavoritesList> createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataFavorit();
    });
    print(widget.param);
  }

  void getDataFavorit() async {
    Provider.of<MasterProvider>(context, listen: false).callFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF747474),
            ),
          ),
          title: Text(
            "List Favorit Tempat",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              fontFamily: 'Nunito-Medium',
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Color(0xFFE6E6E6),
        body: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Consumer<MasterProvider>(
            builder: (context, data, _) {
              if (data.onSearch == true) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (data.datafavorit.length == 0) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                      Container(
                        child: Image.asset(
                          "assets/imgs/trucking.png",
                          width: 200,
                          height: 200,
                        ),
                      ),
                      Text(
                        "BELUM ADA LIST FAVORIT",
                        style: TextStyle(
                            color: Color.fromARGB(255, 187, 187, 187),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      )
                    ],
                  ),
                );
              } else {
                return ListView.separated(
                  itemCount: data.datafavorit.length,
                  itemBuilder: (BuildContext context, index) {
                    return ListTile(
                      title: Text(
                        data.datafavorit[index].labelName.toString(),
                        style: TextStyle(
                          fontFamily: 'Nunito-Medium',
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Text(
                        data.datafavorit[index].alamat.toString(),
                        style: TextStyle(
                          fontFamily: 'Nunito-Medium',
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
                      trailing: widget.param == 'List'
                          ? IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                Provider.of<MasterProvider>(context,
                                        listen: false)
                                    .deleteFavoritesData(
                                        data.datafavorit[index].id);
                                Fluttertoast.showToast(
                                    msg: "Data favorit berhasil dihapus",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              },
                            )
                          : SizedBox(height: 1.0),
                      onTap: () {
                        if (widget.param == 'List') {
                          return false;
                        } else {
                          Navigator.pop(
                            context,
                            {
                              '_placeid': data.datafavorit[index].placeid,
                              '_pelabuhanid':
                                  data.datafavorit[index].pelabuhanid,
                              'alamat': data.datafavorit[index].alamat,
                              'customer': data.datafavorit[index].customer,
                              'notelp': data.datafavorit[index].notelpcustomer,
                              'latitude_place':
                                  data.datafavorit[index].latitudeplace,
                              'longitude_place':
                                  data.datafavorit[index].longitudeplace,
                              'namapelabuhan':
                                  data.datafavorit[index].namapelabuhan,
                              'note': data.datafavorit[index].note,
                            },
                          );
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      thickness: 0.5,
                      color: Colors.black26,
                    );
                  },
                );
              }
            },
          ),
        ));
  }
}

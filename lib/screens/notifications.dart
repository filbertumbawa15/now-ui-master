import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:now_ui_flutter/providers/services.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataNotifications();
    });
  }

  void getDataNotifications() async {
    await Provider.of<MasterProvider>(context, listen: false)
        .callNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context, '/order');
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFB7B7B7),
            )),
        title: Text(
          "Notifikasi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            fontFamily: 'Nunito-Medium',
          ),
        ),
        backgroundColor: Colors.white,
        // backButton: true,
        // rightOptions: false,
      ),
      backgroundColor: Color(0xFFF1F1EF),
      body: Container(
        padding: EdgeInsets.all(14.0),
        child: Consumer<MasterProvider>(
          builder: (context, data, _) {
            if (data.onSearch == true) {
              return Center(child: CircularProgressIndicator());
            } else if (data.datanotif.length == 0) {
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
                      "BELUM ADA HISTORI NOTIFIKASI",
                      style: TextStyle(
                          color: Color.fromARGB(255, 187, 187, 187),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: data.datanotif.length,
                itemBuilder: ((BuildContext context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(
                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                .parse(data.datanotif[index].tgl)),
                        style: TextStyle(
                          fontFamily: 'Nunito-Extrabold',
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.datanotif[index].dataNotifikasi.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, index2) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              tileColor: Color.fromARGB(255, 228, 228, 228),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              leading: Column(
                                children: [
                                  Icon(Icons.notifications),
                                  SizedBox(height: 10.0),
                                  Text(
                                    // data.datanotif[index]
                                    //       .dataNotifikasi[index2]['created_at']
                                    DateFormat('HH:mm:ss').format(
                                        DateFormat('yyyy-MM-ddTHH:mm:ss').parse(
                                      data.datanotif[index]
                                          .dataNotifikasi[index2]['created_at'],
                                    )),
                                  ),
                                ],
                              ),
                              title: Text(data.datanotif[index]
                                  .dataNotifikasi[index2]['header']),
                              subtitle: Text(data.datanotif[index]
                                  .dataNotifikasi[index2]['text']),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),
              );
            }
          },
        ),
      ),
    );
  }
}

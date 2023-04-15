import 'package:flutter/material.dart';
import 'package:now_ui_flutter/providers/services.dart';
import 'package:now_ui_flutter/screens/tracking.dart';
import 'package:now_ui_flutter/widgets/navbar.dart';
import 'package:provider/provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class ListQty extends StatefulWidget {
  final String nobukti;
  const ListQty({
    Key key,
    this.nobukti,
  }) : super(key: key);

  @override
  State<ListQty> createState() => _ListQtyState();
}

class _ListQtyState extends State<ListQty> {
  SimpleFontelicoProgressDialog _dialog;

  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _showDialog(context, SimpleFontelicoProgressDialogType.normal, 'Normal');
      getListQty();
    });
  }

  void getListQty() async {
    await Provider.of<MasterProvider>(context, listen: false)
        .getListQty(widget.nobukti)
        .then((value) {
      setState(() {});
    });
    setState(() {
      _dialog.hide();
    });
  }

  void _showDialog(BuildContext context, SimpleFontelicoProgressDialogType type,
      String text) async {
    if (_dialog == null) {
      _dialog = SimpleFontelicoProgressDialog(
          context: context, barrierDimisable: false);
    }
    if (type == SimpleFontelicoProgressDialogType.custom) {
      _dialog.show(
          message: text,
          type: type,
          width: 150.0,
          height: 75.0,
          loadingIndicator: Text(
            'C',
            style: TextStyle(fontSize: 24.0),
          ));
    } else {
      _dialog.show(
          message: text,
          type: type,
          horizontal: true,
          width: 150.0,
          height: 75.0,
          hideText: true,
          indicatorColor: Colors.blue);
    }
    // await Future.delayed(Duration(seconds: 2));
    // _dialog.hide();
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
          "List Qty",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            fontFamily: 'Nunito-Medium',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        // backButton: true,
        // rightOptions: false,
      ),
      backgroundColor: Color(0xFFF1F1EF),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 5), () {});
        },
        child: Container(
          child: Consumer<MasterProvider>(builder: (context, data, _) {
            return ListView.builder(
                itemCount: data.dataqty.length,
                itemBuilder: (context, i) {
                  return Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No. Job: ',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 7, 3, 3),
                            ),
                          ),
                          Text(
                            data.dataqty[i].jobemkl,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 7, 3, 3),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'No. Container: ',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 7, 3, 3),
                            ),
                          ),
                          Text(
                            data.dataqty[i].nocont,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 7, 3, 3),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15.0),
                          Text(
                            'No. Pesanan:',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            data.dataqty[i].nobukti,
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 15.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            _showDialog(
                                context,
                                SimpleFontelicoProgressDialogType.normal,
                                'Normal');
                            await Future.delayed(const Duration(seconds: 2));
                            await _dialog.hide();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Tracking(
                                          kode_container:
                                              data.dataqty[i].nocont,
                                          nobukti: data.dataqty[i].nobukti,
                                          qty: data.dataqty[i].qty,
                                          jobemkl: data.dataqty[i].jobemkl,
                                        )));
                          },
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.only(
                                left: 1, right: 1, top: 1, bottom: 1),
                            backgroundColor: Color(0xFFB7B7B7),
                            elevation: 0,
                            shape: CircleBorder(),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }),
        ),
      ),
    );
  }
}

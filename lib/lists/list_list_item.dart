import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screensite/lists/lists_page.dart';
import 'package:screensite/providers/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class ListItem extends ConsumerWidget {
  final String entityId;
  const ListItem(this.entityId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(docSP('list/' + entityId)).when(
        loading: () => Container(),
        error: (e, s) => ErrorWidget(e),
        data: (entityDoc) => entityDoc.exists == false
            ? Center(child: Text('No entity data exists'))
            : Card(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                ListTile(
                  title: Text(
                    (entityDoc.data()!['uiName'] != null)
                        ? entityDoc.data()!['uiName']
                        : (entityDoc.data()!['name'] != null)
                            ? entityDoc.data()!['name']
                            : 'undefined list name',
                  ),
                  subtitle: Text('Last changed: ' +
                      Jiffy(entityDoc.data()!['lastUpdateTime'] == null
                              ? DateTime(0001, 1, 1, 00, 00)
                              : entityDoc.data()!['lastUpdateTime'].toDate())
                          .format() +
                      '\n' +
                      'Last updated: ' +
                      Jiffy(entityDoc.data()!['lastUpdateTime'] == null
                              ? DateTime(0001, 1, 1, 00, 00)
                              : entityDoc.data()!['lastUpdateTime'].toDate())
                          .format()),
                  isThreeLine: true,
                  onTap: () {
                    ref.read(activeList.notifier).value = entityId;
                  },
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text.rich(TextSpan(
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                              //make link underline
                              text: "View source page",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  //on tap code here, you can navigate to other page or URL
                                  final url = Uri.parse(
                                      entityDoc.data()!['domainURL'] ?? '#');
                                  var urllaunchable = await canLaunchUrl(
                                      url); //canLaunch is from url_launcher package
                                  if (urllaunchable) {
                                    await launchUrl(
                                        url); //launch is from url_launcher package to launch URL
                                  } else {
                                    print("URL can't be launched.");
                                  }
                                })))
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text.rich(TextSpan(
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                              //make link underline
                              text: "View source list",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  //on tap code here, you can navigate to other page or URL
                                  final url = Uri.parse(
                                      entityDoc.data()!['listURL'] ?? '#');
                                  var urllaunchable = await canLaunchUrl(
                                      url); //canLaunch is from url_launcher package
                                  if (urllaunchable) {
                                    await launchUrl(
                                        url); //launch is from url_launcher package to launch URL
                                  } else {
                                    print("URL can't be launched.");
                                  }
                                })))
                    ]),
                InkWell(
                    child: Icon(Icons.edit),
                    // onTap: () {
                    //   //ToDo
                    //   print("Edit icon clicked");
                    // },
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              title: Text('Sanction list entity fields'),
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        // controller: id_inp,
                                        decoration: InputDecoration(
                                            labelText: 'Entity Name'),
                                      ),
                                      TextFormField(
                                        // controller: name_inp,
                                        decoration: InputDecoration(
                                          labelText: 'Entity address',
                                        ),
                                      ),
                                      TextFormField(
                                        // controller: desc_inp,
                                        decoration: InputDecoration(
                                          labelText: 'Data Source',
                                        ),
                                      ),
                                      TextFormField(
                                        // controller: desc_inp,
                                        decoration: InputDecoration(
                                          labelText: 'Website',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                    child: Text("Done"),
                                    onPressed: () {
                                      // FirebaseFirestore.instance
                                      //     .collection('batch')
                                      //     .add({
                                      //   'id': id_inp.text.toString(),
                                      //   'name': name_inp.text.toString(),
                                      //   'desc': desc_inp.text.toString(),
                                      //   'time Created':
                                      //       FieldValue.serverTimestamp(),
                                      //   'author': FirebaseAuth
                                      //       .instance.currentUser!.uid,
                                      // }).then((value) => {
                                      //           if (value != null)
                                      //             {
                                      //               FirebaseFirestore.instance
                                      //                   .collection('batch')
                                      //             }
                                      //         });

                                      // Navigator.of(context).pop();
                                    })
                              ],
                            );
                          });
                    }),
              ])));
  }

  Future<bool> CheckSelected() async {
    var batchRef = await FirebaseFirestore.instance.collection('batch').get();
    for (var element in batchRef.docs) {
      var selectList = await FirebaseFirestore.instance
          .collection('batch')
          .doc(element.id)
          .collection('SelectedEntity')
          .doc(entityId)
          .get();
      if (selectList.exists) {
        print("sample data temp1: ${selectList.exists}");
        //temp = false;
        return selectList.exists;
      }
    }
    return false;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:providers/firestore.dart';
import 'package:widgets/col_stream_widget.dart';
import 'package:widgets/doc_print.dart';
import 'package:widgets/doc_stream_widget.dart';

class MatchesWidget extends ConsumerWidget {
  final DR docRef;
  final TextEditingController searchCtrl = TextEditingController();

  MatchesWidget(this.docRef);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
        child: Card(
            child: ColStreamWidget<Widget>(
                colSP(docRef.collection('search').path),
                (context, snapshot, items) => Column(children: items),
                (context, doc) => Column(
                      children: [
                        Text(doc.data()!['target']),
                        ColStreamWidget<Widget>(
                            colSP(doc.reference.collection('res').path),
                            (context, snapshot, items) =>
                                Column(children: items),
                            (context, doc) => DocStreamWidget(
                                docSP((doc.data()!['ref'] as DocumentReference)
                                    .path),
                                (context, sanctionDoc) =>
                                    DocPrintWidget(sanctionDoc.reference)))
                      ],
                    ))));
  }
}

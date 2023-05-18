import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '/src/pages/profile_page.dart';
import 'package:wya_final/src/utils/constants.dart';
import '/src/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  static String id = 'search_screen';

  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: kWYATeal,
          title: Form(
            child: TextFormField(
              controller: searchController,
              decoration:
              const InputDecoration(labelText: 'Search for a user...', labelStyle: TextStyle(color: Colors.white, fontSize: 20)),
              onFieldSubmitted: (String _) {
                setState(() {
                  isShowUsers = true;
                });
              },
            ),
          ),
        ),
        body: isShowUsers
            ? FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('userData')
              .where(
            'username',
            isGreaterThanOrEqualTo: searchController.text,
          )
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: (snapshot.data! as dynamic).docs.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if(appState.userData.uid == (snapshot.data! as dynamic).docs[index]['uid']){
                      context.go('/account');
                    }else{
                      Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                uid: (snapshot.data! as dynamic).docs[index]['uid'],
                              )));
                    }
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        (snapshot.data! as dynamic).docs[index]['photoUrl'],
                      ),
                      radius: 16,
                    ),
                    title: Text(
                      (snapshot.data! as dynamic).docs[index]['username'],
                    ),
                  ),
                );
              },
            );
          },
        ) : const Center(),

        bottomNavigationBar: const BottomAppBarCustom(current: 'search'),
      ),
    );
  }
}
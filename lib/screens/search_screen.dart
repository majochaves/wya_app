import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '/screens/profile_screen.dart';
import 'package:wya_final/utils/constants.dart';
import '/widgets/widgets.dart';

class SearchScreen extends StatefulWidget {
  static String id = 'search_screen';

  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
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
                    if(userProvider.uid! == (snapshot.data! as dynamic).docs[index]['uid']){
                      context.go('/account');
                    }else{
                      Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
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

        bottomNavigationBar: const CustomBottomAppBar(current: 'search'),
    );
  }
}
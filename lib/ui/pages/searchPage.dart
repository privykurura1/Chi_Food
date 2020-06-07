import 'dart:async';

import 'package:chifood/model/baseUser.dart';
import 'package:chifood/model/restaurants.dart';
import 'package:chifood/model/yelpReview.dart';
import 'package:chifood/service/apiService.dart';
import 'package:chifood/ui/pages/home.dart';
import 'package:chifood/ui/widgets/getRating.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CustomSearchPage extends StatefulWidget {
  Dio client;

  CustomSearchPage(this.client,);

  @override
  _CustomSearchPageState createState() => _CustomSearchPageState();
}

class _CustomSearchPageState extends State<CustomSearchPage> with SingleTickerProviderStateMixin {
  List<String> hintList=[
    'Search by restaurant name or location','Search by location to find review','Search username'
  ];
  String entity_id;
  String entity_type;
  TabController _controller;
  FocusNode node;
  final TextEditingController _searchQuery = TextEditingController();
  bool _isSearching = false;
  String _error;
  List<Restaurants> resRdesult;
  List<YelpReview> reviewResult;
  List<BaseUser> userResult;
  int default_int=0;
  Timer debounceTimer;
  ScrollController _scrollController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    node=new FocusNode();

    _controller=new TabController(length: 3, vsync: this);
    _controller.addListener((){
      if(_controller.indexIsChanging){
        default_int=_controller.index;
        setState(() {

        });
      }
    });
    _scrollController=new ScrollController();
    _scrollController.addListener((){
      if(_scrollController.offset>1.0&&node.hasFocus){
        node.unfocus();
      }
    });
    _searchQuery.addListener((){
      if (debounceTimer != null) {
        debounceTimer.cancel();
      }
      debounceTimer = Timer(Duration(milliseconds: 1500), () {
        if (this.mounted) {
          performSearch(_searchQuery.text);
        }
      });
    });


  }

  void performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _error = null;

      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;

    });

    final repos = await searchRestaurants(widget.client, query,entity_id,entity_type);
    if (this._searchQuery.text == query && this.mounted) {
      setState(() {
        _isSearching = false;
        if (repos != null) {
          resRdesult = repos;
        } else {
          _error = 'Error searching repos';
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    SearchArg a=ModalRoute.of(context).settings.arguments;
    setState(() {
      entity_id=a.entity_id;
      entity_type=a.entity_type;
    });
    return Scaffold(
        body:SafeArea(
          top: true,
          bottom: false,
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.75),
                          child: TextField(
                            controller: _searchQuery,
                            focusNode: node,
                            decoration: InputDecoration(
                                hintText: hintList[default_int],
                                hintStyle: TextStyle(fontSize: 14.0,color: Colors.black),
                                contentPadding: EdgeInsets.symmetric(vertical:0.0,horizontal: 10.0),
                                filled: true,
                                focusColor: Colors.white,

                                fillColor:node.hasFocus?Colors.white: Color(0xffd3d3d3).withOpacity(0.4),
                                border: OutlineInputBorder(
                                  gapPadding: 0.0,

                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(20.0),
                                  ),
                                )
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: ()=>Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 35.0,vertical: 7.0),
                              child: Text('Check nearby restaurants',textAlign: TextAlign.center,),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xffd3d3d3).withOpacity(0.3),offset: Offset(1.6,1.7),spreadRadius: 2.0,blurRadius: 4.0
                                  )
                                ]
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        TabBar(
                          controller: _controller,
                          tabs: <Widget>[
                            Tab(text: 'Restaurants',),
                            Tab(text: 'Reviews',),
                            Tab(text:'User')
                          ],
                          indicatorColor: Colors.orange,
                          labelStyle: TextStyle(color: Theme.of(context).primaryColor,fontSize: 15.0,fontWeight: FontWeight.w700),
                          unselectedLabelStyle: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.w700),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _controller,
                            children: <Widget>[
                              Container(), Container(), Container(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              !_isSearching&&_searchQuery.text.length!=0?Positioned(
                top: 70,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(itemBuilder: (BuildContext context,int index){

                    Restaurants res=resRdesult[index];
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.2)))
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.store),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Text(res.name),
                                Row(
                                  children: <Widget>[
                                    StarRating(rating: double.parse(res.user_rating.aggregate_rating),),
                                    SizedBox(width: 5,),
                                    Text(res.user_rating.votes)
                                  ],
                                ),
                              Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(res.cuisines.split(', ')[0]),
                                  Container(
                                    width: 1,
                                    height: 10,
                                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                                    color: Colors.grey,
                                  ),

                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 230),
                                    child: Text(res.location.address,overflow: TextOverflow.ellipsis,),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },itemCount: resRdesult?.length,controller: _scrollController,),
                ),
              ):SizedBox()

            ],
          ),
        ),
    );
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();

}

class _KlimaticState extends State<Klimatic> {

  String _cityEntered = util.defaultCity;
  String _lastCity;

  Future _goToNextScreen(BuildContext context) async{
    Map results = await Navigator.of(context).push(
      new MaterialPageRoute<Map>(
          builder: (BuildContext context) {
            return new ChangeCity();
          }
      )
    );
    if(results != null && results.containsKey("cityEntered")){
      _lastCity = results["cityEntered"];
      _cityEntered = _lastCity;
    }else{
      //print("default City");
      _cityEntered = _lastCity;
    }
  }

  void showStuff() async {
    //print("hello");
    Map data = await getWeather(util.appId, util.defaultCity);
    //print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Klimatic"),
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {_goToNextScreen(context);},
          )
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/umbrella.png',
              width: 490.0,
              fit: BoxFit.cover,
              height: 1200.0,
            ),
          ),
          new Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: new Text(
              _cityEntered,
              style: cityStyle,
            ),
          ),
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Image.asset('images/light_rain.png'),
                  ]),
              new Row(
                children: <Widget>[
                  new Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 20.0),
                      child: updateTempWidget(_cityEntered))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Map> getWeather(String appId, String city) async {
  String apiUrl = Uri.https("api.openweathermap.org", "/data/2.5/find",
      {"q": "$city", "units": "metric", "appid": "$appId"}).toString();
  print(apiUrl);
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body);
}

Widget updateTempWidget(String city) {
  //print("Hello");
  return new FutureBuilder(
      future: getWeather(util.appId, city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        try{
          Map content = snapshot.data;
          print("Hello : " + content.toString());
          return new Column(
            children: <Widget>[
              new Text(
                "${content["list"][0]['main']['temp'].toString()} °C",
                style: tempStyle,
              ),
              new Text(
                "Humidity: ${content["list"][0]['main']['humidity'].toString()}",
                style: extraInfoStyle,
              ),
              new Text(
                "Min: ${content["list"][0]['main']['temp_min'].toString()} °C",
                style: extraInfoStyle,
              ),
              new Text(
                "Max: ${content["list"][0]['main']['temp_max'].toString()} °C",
                style: extraInfoStyle,
              ),
            ],
          );
        } catch(e) {
          return new Column(
            children: <Widget>[
              Text(
                "",
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white
                ),
              ),
            ],
          );
        }
      });
}

class ChangeCity extends StatelessWidget {

  var _newCityFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: new Text('Change City'),
        centerTitle: true,
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/white_snow.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(
                    hintText: 'Enter City'
                  ),
                  controller: _newCityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              new ListTile(
                title: new RaisedButton(
                    onPressed:(){
                      Navigator.pop(context, {"cityEntered": _newCityFieldController.text});
                    },
                    color: Colors.redAccent,
                    textColor: Colors.white70,
                    child: new Text(
                      'Get Weather',

                    )
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}


final cityStyle =
    TextStyle(color: Colors.white, fontSize: 22.9, fontStyle: FontStyle.italic);

final tempStyle = TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 50.0);

final extraInfoStyle = TextStyle(
    color: Colors.white70,
    fontStyle: FontStyle.normal,
    fontSize: 20.0);

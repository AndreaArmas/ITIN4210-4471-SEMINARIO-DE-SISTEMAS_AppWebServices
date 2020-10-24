import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Country {
  final String name;
  final String capital;
  final String subregion;
  final int population;

  Country({this.name, this.capital, this.subregion, this.population});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
        name: json['name'],
        capital: json['capital'],
        subregion: json['subregion'],
        population: json['population']
    );
  }
}

Future<List<Country>> fetchCountry() async {
  final response = await http.get('https://restcountries.eu/rest/v2/lang/es');

  var countries=List<Country>();

  if (response.statusCode == 200) {
    var countriesJason=json.decode(response.body);
    for(var countryJason in countriesJason){
      countries.add(Country.fromJson(countryJason));
    }
    return countries;
  } else {
    throw Exception('No se pueden cargar los países');
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lectura de Web Services',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey,
        accentColor: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Lectura de Web Services'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Country> _countries=List<Country>();
  List<Country> _countriesForDisplay=List<Country>();

  @override
  void initState() {
    fetchCountry().then((value) {
      setState(() {
        _countries.addAll(value);
        _countriesForDisplay = _countries;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemBuilder: (context, index){
          return index==0 ?  _searchBar() : _listItem(index-1);
        },
        itemCount:_countriesForDisplay.length+1,
      ),
    );
  }

  _searchBar(){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: InputDecoration(hintText: 'Buscar'),
        onChanged: (text){
          text = text.toLowerCase();
          setState(() {
            _countriesForDisplay=_countries.where((country){
              var contName = country.name.toLowerCase();
              return contName.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  _listItem(index){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_countriesForDisplay[index].name,
              style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
            Text(_countriesForDisplay[index].capital,
              style: TextStyle(fontSize: 20, color: Colors.grey.shade600),),
            Text(_countriesForDisplay[index].subregion,
              style: TextStyle(fontSize: 20, color: Colors.grey.shade600),),
            Text(_countriesForDisplay[index].population.toString(),
              style: TextStyle(fontSize: 20, color: Colors.grey.shade600),),
          ],
        ),
      ),
    );
  }

}
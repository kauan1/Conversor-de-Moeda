import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //possibilita as requisições
import 'dart:async'; //faz as requisições e não precisa ficar esperando essa requisições
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?format=json&key=ad145a0d';
/*
* http.Response response- Resposta do servidor
*http.get(request) - Solicitação ao servidor de alguma coisa(que demora algum tempo 10 milisegundos ou mais
* await - Espera os dados chegarem e coloca na resposta*/
void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
    debugShowCheckedModeBanner: false,
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realcontroller = TextEditingController();
  final dolarcontroller = TextEditingController();
  final eurocontroller = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarcontroller.text = (real/dolar).toStringAsFixed(2);
    eurocontroller.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realcontroller.text = (dolar*this.dolar).toStringAsFixed(2);
    eurocontroller.text = (dolar*this.dolar/euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realcontroller.text = (euro*this.euro).toStringAsFixed(2);
    dolarcontroller.text = (euro*this.euro/dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    realcontroller.text = "";
    dolarcontroller.text = "";
    eurocontroller.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(" \$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando dados",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    "Erro ao carregar dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        buildTextField("Reais", "R\$", realcontroller, _realChanged),
                        Divider(),
                        buildTextField("Dolares", "US\$", dolarcontroller, _dolarChanged),
                        Divider(),
                        buildTextField("Euros", "€", eurocontroller, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}
Widget buildTextField (String label, String prefix, TextEditingController c, Function f){
  return TextField(
    decoration: InputDecoration(
      labelText: "$label",
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: "$prefix"
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0
    ),
    controller: c,
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PrinterDevice> devices = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchDevices();
  }

  void searchDevices() {
    PrinterManager.instance
        .discovery(type: PrinterType.network)
        .listen((device) {
      setState(() {
        devices.add(device);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var md = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Clique em um dispositivo conectado para se conectar com ele',
            ),
            const Text(
              'Dispositivos encontrados:',
            ),
            SizedBox(
              height: md.height * 0.5,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () async {
                        bool result = await PrinterManager.instance.connect(
                          type: PrinterType.network,
                          model: TcpPrinterInput(
                            ipAddress: devices[index].address!,
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result
                                ? 'Impressora conectada com sucesso'
                                : 'Falha ao se conectar a impressora'),
                          ),
                        );
                      },
                      child: Text('----> ${devices[index].name}'));
                },
                itemCount: devices.length,
                shrinkWrap: true,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                bool result = await PrinterManager.instance.send(
                  type: PrinterType.network,
                  bytes: 'Impressão para teste'.codeUnits,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result
                        ? 'Informações enviadas'
                        : 'Falha ao enviar informações'),
                  ),
                );
              },
              child: Text(
                'Enviar impressão de teste',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

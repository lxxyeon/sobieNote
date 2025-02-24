import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
 const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyWidget(), // home에 Stateful 위젯 넣기
    );
  }
}

// Stateful 위젯 만들기
class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyWidget();
}

class _MyWidget extends State<MyWidget> {

  @override
  Widget build(BuildContext context) {
    // 현재 선택된 탭 인덱스 관리할 변수
    int _selectedIndex = 0; 

    // 탭 될때 인덱스 변수 변경할 함수
    void _onItemTapped(int index) { 
      setState(() {
        _selectedIndex = index;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('BottomNavigationBar Sample'),
      ),
      body: Center(
      ),
      // bottomNavigationBar 속성 추가 후 탭 요소가 될 item들 추가
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'tab1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'tab2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.usb_rounded),
            label: 'tab3',
          ),
        ],
      ),
    );
  }
}
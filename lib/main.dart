import 'dart:ui';

import 'package:card_flip_carousel/card_data.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}): super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 20.0,
          ),
          Expanded(
            child: CardFlipper(
              cards: demoCards,
            ),
          ),
          Container(
            width: double.infinity,
            height: 50.0,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}

class CardFlipper extends StatefulWidget {
  CardFlipper({Key key, this.cards}): super(key: key);

  final List<CardViewModel> cards;

  @override
  _CardFlipperState createState() => _CardFlipperState();
}

class _CardFlipperState extends State<CardFlipper> with TickerProviderStateMixin {
  var _cardCount = 0;
  var _scrollPercent = 0.0;
  var _scrollStart = 0.0;
  var _finishScrollStart = 0.0;
  var _finishSCrollEnd = 0.0;
  AnimationController _finishScrollController;

  @override
  void initState() {
    super.initState();
    _cardCount = widget.cards.length;

    _finishScrollController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150))
      ..addListener(() {
        setState(() {
          _scrollPercent = lerpDouble(_finishScrollStart, _finishSCrollEnd, _finishScrollController.value);
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _finishScrollController.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _scrollStart = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final _scrollCurrent = details.globalPosition.dx;
    final _dragDistance = _scrollStart - _scrollCurrent;
    final _singleCardScrollPercent = _dragDistance / context.size.width;
    _scrollStart = _scrollCurrent;

    setState(() {
      _scrollPercent = (_scrollPercent + _singleCardScrollPercent / _cardCount).clamp(0.0, 1.0 - 1 / _cardCount);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _finishScrollStart = _scrollPercent;
    _finishSCrollEnd = (_finishScrollStart * _cardCount).round() / _cardCount;
    _finishScrollController.forward(from: 0.0);

    setState(() {
      _scrollStart = 0.0;
      _scrollPercent = 0.0;
    });
  }

  List<Widget> _buildCards() {
    var index = 0;

    return widget.cards.map((card) {
      return _buildCard(index++, card);
    }).toList();
  }

  Widget _buildCard(int index, CardViewModel card) {
    final cardScrollPercent = _scrollPercent / (1 / _cardCount);
    final parallaxPercent = _scrollPercent - (index / _cardCount);

    return FractionalTranslation(
      translation: Offset(index - cardScrollPercent, 0.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(card: card, parallaxPercent: parallaxPercent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: _buildCards(),
      ),
    );
  }
}

class Card extends StatelessWidget {
  Card({
    Key key,
    this.card,
    this.parallaxPercent = 0.0,
  }): super(key: key);

  final card;
  final parallaxPercent;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: <Widget>[
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FractionalTranslation(
          translation: Offset(parallaxPercent, 0.0),
          child: OverflowBox(
            maxWidth: double.infinity,
            child: Image.asset(
              card.backdropAssetPath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  card.address.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontFamily: 'petita',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${card.minHeightInFeet} - ${card.maxHeightInFeet}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 140.0,
                      fontFamily: 'petita',
                      letterSpacing: -5.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 5.0),
                    child: Text(
                      'FT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontFamily: 'petita',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Icon(
                      Icons.wb_sunny,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${card.tempInDegrees}°',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: 'petita',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  )
                ],
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(
                width: 1.5,
                color: Colors.white,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    card.weatherType,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: 'petita',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Icon(
                      Icons.wb_cloudy,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${card.windSpeedInMph}mph ${card.cardinalDirection}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontFamily: 'petita',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ]);
  }
}

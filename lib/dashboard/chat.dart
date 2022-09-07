import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart' as dialogflowLib;
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';

dialogflowLib.DialogflowGrpcV2Beta1? dialogflow;
SpeechToText? speechToText;
RecognitionConfig? config;
String languageCode = "en";

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();

  final RecorderStream _recorder = RecorderStream();

  bool recognizing = false;
  bool recognizeFinished = false;
  String text = '';
  StreamSubscription<List<int>>? _audioStreamSubscription;
  BehaviorSubject<List<int>>? _audioStream;

  @override
  void initState() {
    super.initState();
    initPlugin();
    _recorder.initialize();
  }

  @override
  void dispose() {
    _audioStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> initPlugin() async {
    await Future.wait([_recorder.initialize()]);
    final serviceAccount = dialogflowLib.ServiceAccount.fromString(
        (await rootBundle.loadString('assets/key.json')));
    final serviceAccount2 = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/key.json')));
    dialogflow =
        dialogflowLib.DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);

    speechToText = SpeechToText.viaServiceAccount(serviceAccount2);
  }

  RecognitionConfig _getConfig() => RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: languageCode);

  void handleSubmitted(text) async {
    _textController.clear();

    ChatMessage message = ChatMessage(
      text: text,
      name: "You",
      type: true,
      image: false,
    );

    setState(() {
      _messages.insert(0, message);
    });
    debugPrint(text);

    DetectIntentResponse data =
        await dialogflow!.detectIntent(text, languageCode);
    String fulfillmentText = data.queryResult.fulfillmentText;
    List<String> resp = fulfillmentText.split("@");
    debugPrint("DialogFlow");
    debugPrint(fulfillmentText);
    if (fulfillmentText.isNotEmpty && resp.length == 1) {
      ChatMessage botMessage = ChatMessage(
        text: fulfillmentText,
        name: "Bot",
        type: false,
        image: false,
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    } else {
      ChatMessage botMessage1 = ChatMessage(
        text: resp[0],
        name: "Bot",
        type: false,
        image: false,
      );
      ChatMessage botMessage2 = ChatMessage(
        text: resp[1],
        name: "Bot",
        type: false,
        image: false,
      );
      ChatMessage botMessage3 = ChatMessage(
        text: resp[2],
        name: "Bot",
        type: false,
        image: false,
      );
      ChatMessage botMessage4 = ChatMessage(
        text: resp[3],
        name: "Bot",
        type: false,
        image: true,
      );

      setState(() {
        _messages.insert(0, botMessage1);
        _messages.insert(0, botMessage2);
        _messages.insert(0, botMessage3);
        _messages.insert(0, botMessage4);
      });
    }
    return;
  }

  void streamingRecognize() async {
    config = _getConfig();
    _audioStream = BehaviorSubject<List<int>>();
    _audioStreamSubscription = _recorder.audioStream.listen((event) {
      _audioStream!.add(event);
    });

    await _recorder.start();

    setState(() {
      recognizing = true;
    });

    final responseStream = speechToText!.streamingRecognize(
        StreamingRecognitionConfig(config: config!, interimResults: true),
        _audioStream!);

    var responseText = '';

    responseStream.listen((data) {
      final currentText =
          data.results.map((e) => e.alternatives.first.transcript).join('\n');

      if (data.results.first.isFinal) {
        responseText += '\n$currentText';
        setState(() {
          text = responseText;
          recognizeFinished = true;
        });
      } else {
        setState(() {
          text = '$responseText\n$currentText';
          recognizeFinished = true;
        });
      }
    }, onDone: () {
      setState(() {
        handleSubmitted(responseText);
        recognizing = false;
      });
    });
  }

  void stopRecording() async {
    await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
    setState(() {
      recognizing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Flexible(
            child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
        )),
        const Divider(height: 1.0),
        Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).colorScheme.primary),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        controller: _textController,
                        onSubmitted: handleSubmitted,
                        decoration: const InputDecoration.collapsed(
                            hintText: "Send a message"),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => handleSubmitted(_textController.text),
                      ),
                    ),
                    IconButton(
                      iconSize: 30.0,
                      icon: Icon(recognizing ? Icons.mic_off : Icons.mic),
                      onPressed:
                          recognizing ? stopRecording : streamingRecognize,
                    ),
                  ],
                ),
              ),
            )),
      ]),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({Key? key, this.text, this.name, this.type, this.image})
      : super(key: key);

  final String? text;
  final String? name;
  final bool? type;
  final bool? image;

  List<Widget> otherMessage(context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(
            backgroundColor: Colors.orange[800],
            child: Text(
              name!,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            )),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name!, style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text!, style: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> imageBox(context) {
    // print(text);
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(
            backgroundColor: Colors.orange[800],
            child: Text(
              name!,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            )),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name!, style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              width: 200,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(text!),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(name!, style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text!, style: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
            backgroundColor: Colors.orange[800],
            child: Text(
              name!,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            )),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (image!)
            ? imageBox(context)
            : type!
                ? myMessage(context)
                : otherMessage(context),
      ),
    );
  }
}

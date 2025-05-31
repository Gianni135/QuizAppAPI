// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as htmlParser;
import 'dart:convert';
import 'dart:async';
import 'package:helloworld/widget/sballobutton.dart';
import 'package:confetti/confetti.dart';

// Colori per la modalità chiara
class LightColors {
  static const primary = Colors.blue;
  static const secondary = Color(0xFF03DAC6);
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const error = Colors.red;
  static const onPrimary = Colors.white;
  static const onBackground = Colors.black87;
  static const buttonColor = Color(0xFF90CAF9);
  static const correctAnswer = Color(0xFF4CAF50);
  static const wrongAnswer = Color(0xFFF44336);
}

// Colori per la modalità scura
class DarkColors {
  static const primary = Color(0xFF1F1F3D);
  static const secondary = Color(0xFF03DAC6);
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF242424);
  static const error = Color(0xFFCF6679);
  static const onPrimary = Colors.white;
  static const onBackground = Colors.white;
  static const buttonColor = Color(0xFF1E88E5);
  static const correctAnswer = Color(0xFF2E7D32);
  static const wrongAnswer = Color(0xFFC62828);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Supersballo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _try = 2;
  int _score = 0;
  bool _loading = true;
  bool _isDarkMode = false;
  bool _isFlashing = false;
  bool _showWelcome = true;
  String _selectedQuizType = '';
  Color _flashColor = Colors.transparent;
  late ConfettiController _confettiController;
  final url_string =
      'https://raw.githubusercontent.com/Gianni135/QuizAppAPI/refs/heads/main/domandeTPSIT.json';
  final url_string2 =
      'https://raw.githubusercontent.com/Gianni135/QuizAppAPI/refs/heads/main/domandeStoria.json';
  final url_string3 =
      'https://raw.githubusercontent.com/Gianni135/QuizAppAPI/refs/heads/main/domandeInglese.json';
  var _questionIndex = 0;
  late var jsonquestions;
  late List<String> listAnswers;
  

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    // Non avviamo il quiz immediatamente, mostriamo prima la schermata di benvenuto
    setState(() {
      _loading = false;
    });
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  
  // Metodo il flash sullo sfondo
  void _triggerFlash(bool correct) {
    setState(() {
      _isFlashing = true;
      _flashColor = correct 
          ? getColor(LightColors.correctAnswer, DarkColors.correctAnswer) 
          : getColor(LightColors.wrongAnswer, DarkColors.wrongAnswer);
    });
    
    // Coriandoli per congratulare l'utente (festeggiamento della risposta corretta)
    if (correct) {
      _confettiController.play();
    }
    
    Timer(const Duration(milliseconds: 700), () {
      setState(() {
        _isFlashing = false;
        // Ritorno al colore trasparente dopo il flash
        _flashColor = Colors.transparent;
      });
    });
  }

  void doGet(String url) {
    setState(() {
      _loading = true; // Inizia il caricamento
    });
    
    http.get(Uri.parse(url)).then((response) {
      var jsondata = json.decode(response.body);

      setState(() {
        // Limitazione del quiz a 10 domande per motivi di comodità durante lo sviluppo
        var results = jsondata['results'];
        if (results.length > 10) {
          jsonquestions = results.sublist(0, 10);
        } else {
          jsonquestions = results;
        }
        listAnswers = shuffleAnswers();
        _loading = false;
        _showWelcome = false;
      });
    });
  }

  String htmlParse(String s) {
    return htmlParser.DocumentFragment.html(s).text.toString();
  }
  
  // Dark mode
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }
  // Funzione per ottenere i colori corretti in base al tema
  Color getColor(Color lightColor, Color darkColor) {
    return _isDarkMode ? darkColor : lightColor;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void _setCounter(int n) {
    setState(() {
      if (_try > 0) {
        _counter = n;
        _try--;
      }
    });
  }
  
  // Aggiornamento del punteggio
  void _updateScore(bool correct) {
    setState(() {
      if (correct) {
        _score += 10;
      }
    });
  }
  
  // Funzione per visualizzare il punteggio finale e schermata Game Over
  void _mostraPunteggioFinale() {
    int totalQuestions = (jsonquestions as List<dynamic>).length;
    int maxScore = totalQuestions * 10;
    int currentScore = _score;
    double percentCorrect = currentScore / maxScore * 100;
    String risultato;
    Color colorRisultato;
    IconData iconRisultato;
    
    // Messaggio personalizzato in base al punteggio
    if (percentCorrect == 100) {
      risultato = '🏆 Supersballo!! Hai risposto correttamente a tutto! 🏆';
      colorRisultato = Colors.green;
      iconRisultato = Icons.emoji_events;
    } else if (percentCorrect >= 80) {
      risultato = '🎉 Risultato sballo ma non supersballo! 🎉';
      colorRisultato = Colors.blue;
      iconRisultato = Icons.star;
    } else if (percentCorrect >= 60) {
      risultato = 'Risultato decente! Puoi migliorare!';
      colorRisultato = Colors.amber;
      iconRisultato = Icons.thumb_up;
    } else if (percentCorrect >= 40) {
      risultato = 'Risultato bah. Continua a studiare!';
      colorRisultato = Colors.orange;
      iconRisultato = Icons.trending_up;
    } else {
      risultato = 'Continua a esercitarti, puoi migliorare!';
      colorRisultato = Colors.red;
      iconRisultato = Icons.refresh;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (ctx) => AlertDialog(
        backgroundColor: getColor(Colors.grey[100]!, DarkColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorRisultato, width: 3),
        ),
        title: Column(
          children: [
            Text('GAME OVER', style: TextStyle(
              color: getColor(Colors.red, DarkColors.error),
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 1.5,
            )),
            Divider(thickness: 2, color: getColor(Colors.grey, Colors.grey[700]!)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconRisultato, size: 50, color: colorRisultato),
            SizedBox(height: 10),
            
            Text('Quiz Completato!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Ridotto font
            SizedBox(height: 15),
            
            Container(
              height: 100,
              width: 100, 
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getColor(Colors.white, DarkColors.primary),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentScore',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorRisultato,
                      ),
                    ),
                    Text(
                      'su $maxScore',
                      style: TextStyle(
                        fontSize: 14,
                        color: getColor(Colors.grey[700]!, Colors.grey[300]!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            Text(
              risultato,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorRisultato,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.close),
            label: Text('Chiudi'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: getColor(Colors.grey[800]!, Colors.grey[300]!),
            ),
          ),
          TextButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('Gioca Ancora'),
            style: TextButton.styleFrom(
              backgroundColor: getColor(Colors.green, DarkColors.secondary),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _ricominciaDaCapo();
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.swap_horiz),
            label: Text('Cambia Quiz'),
            style: TextButton.styleFrom(
              backgroundColor: getColor(Colors.purple, Colors.deepPurple[700]!),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _tornaBenvenuto();
            },
          ),
        ],
      ),
    );
  }
  
  // Reset del quiz
  void _ricominciaDaCapo() {
    setState(() {
      _questionIndex = 0;
      _counter = 0;
      _score = 0;
      _try = 2;
      listAnswers = shuffleAnswers();
    });
  }

  // Funzione per tornare indietro alla schermata welcome
  void _tornaBenvenuto() {
    setState(() {
      _showWelcome = true;
      _questionIndex = 0;
      _counter = 0;
      _score = 0;
      _try = 2;
    });
  }
  
  List<String> shuffleAnswers() {
    List<String> list = [
      jsonquestions[_questionIndex]['correct_answer'] as String,
      ...jsonquestions[_questionIndex]['incorrect_answers']
          .map<String>((item) => item.toString())
          .toList()
    ];
    list.shuffle();
    return list;
  }

  bool checkAnswer(String answer) {
    return (answer ==
        jsonquestions[_questionIndex]['correct_answer'] as String);
  }

  Widget LoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: getColor(LightColors.primary, DarkColors.primary),
          ),
          SizedBox(height: 20),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 30,
              color: getColor(LightColors.onBackground, DarkColors.onBackground),
            ),
          )
        ],
      ),
    );
  }

  // Widget per la schermata di benvenuto e selezione del quiz
  Widget welcomeScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getColor(
              LightColors.surface.withOpacity(0.9),
              DarkColors.surface.withOpacity(0.9),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: getColor(LightColors.primary, DarkColors.primary),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.quiz,
                size: 60,
                color: getColor(LightColors.primary, DarkColors.primary),
              ),
              SizedBox(height: 10),
              Text(
                'Benvenuto al Quiz!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: getColor(LightColors.onBackground, DarkColors.onBackground),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Scegli la materia sulla quale vuoi essere interrogato:',
                style: TextStyle(
                  fontSize: 16,
                  color: getColor(LightColors.onBackground, DarkColors.onBackground),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20),
        
        _buildQuizCategoryButton(
          'TPSIT',
          'Quiz su Tecnologie e Progettazione di Sistemi Informatici',
          Icons.computer,
          Colors.blue,
          url_string,
        ),
        SizedBox(height: 10),
        _buildQuizCategoryButton(
          'Storia',
          'Quiz di storia sulla guerra fredda e altro',
          Icons.history_edu,
          Colors.brown,
          url_string2,
        ),
        SizedBox(height: 10),
        _buildQuizCategoryButton(
          'Inglese',
          'Quiz su argomenti inglese di quinta',
          Icons.language,
          Colors.green,
          url_string3,
        ),
      ],
    );
  }
  
  Widget _buildQuizCategoryButton(String title, String description, IconData icon, Color accentColor, String quizUrl) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedQuizType = title;
          });
          doGet(quizUrl);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: getColor(accentColor, accentColor.withOpacity(0.7)),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget mainScreen() {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _isFlashing ? 0.8 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              color: _flashColor,
              gradient: _isFlashing && _flashColor != Colors.transparent ? RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  _flashColor.withOpacity(0.9),
                  _flashColor.withOpacity(0.5),
                ],
              ) : null,
            ),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
        // Indicatore di progresso del quiz
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(
            'Domanda ${_questionIndex + 1} di ${(jsonquestions as List<dynamic>).length}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: getColor(LightColors.primary, Colors.white),
            ),
          ),
        ),
        
        // Barra di progresso visiva
        Container(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 20), 
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)), 
            child: LinearProgressIndicator(
              value: (_questionIndex + 1) / (jsonquestions as List<dynamic>).length,
              minHeight: 8, 
              backgroundColor: getColor(Colors.grey[200]!, DarkColors.surface),
              valueColor: AlwaysStoppedAnimation<Color>(
                getColor(LightColors.secondary, DarkColors.secondary),
              ),
            ),
          ),
        ),
        
        Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          padding: EdgeInsets.all(12),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.18), // Ridotta altezza massima a 18%
          decoration: BoxDecoration(
            color: getColor(
              LightColors.surface.withOpacity(0.7),
              DarkColors.surface.withOpacity(0.7),
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: getColor(
                LightColors.primary.withOpacity(0.3),
                DarkColors.primary.withOpacity(0.3),
              ),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            child: Text(
              htmlParse(jsonquestions[_questionIndex]['question'] as String),
              style: TextStyle(
                fontSize: 20,
                color: getColor(LightColors.onBackground, DarkColors.onBackground),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ...(listAnswers).map((answer) {
          return SballoButton(
            text: htmlParse(answer),
            action: () {
              if (_counter == 0) {
                bool isCorrect = checkAnswer(answer);
                setState(() {
                  if (isCorrect) {
                    _counter = 1;
                    _updateScore(true);
                  } else {
                    _counter = -1;
                  }
                });
                _triggerFlash(isCorrect);
              }
            },
            bkColor: getColor(LightColors.buttonColor, DarkColors.buttonColor),
            fgColor: getColor(LightColors.onPrimary, DarkColors.onPrimary),
          );
        }),
        SballoButton(
          text: (_questionIndex == (jsonquestions as List<dynamic>).length - 1 && _counter != 0) 
              ? 'Termina Quiz' 
              : 'Next',
          fontSize: 18,
          verticalPadding: 12,
          action: () {
            if (_counter != 0) {
              int currentIndex = _questionIndex;
              bool isLastQuestion = currentIndex == (jsonquestions as List<dynamic>).length - 1;
              
              if (isLastQuestion) {
                // Se è l'ultima domanda, mostra il Game Over con punteggio finale
                _mostraPunteggioFinale();
                
              } else {
                setState(() {
                  _questionIndex = _questionIndex + 1;
                  _counter = 0;
                  listAnswers = shuffleAnswers();
                });
              }
              
              print("Numero di domande: ${(jsonquestions as List<dynamic>).length}, Domanda corrente: ${_questionIndex + 1}");
            }
          },
          bkColor: (_questionIndex == (jsonquestions as List<dynamic>).length - 1 && _counter != 0)
              ? getColor(LightColors.error, DarkColors.error)
              : getColor(LightColors.secondary, DarkColors.secondary),
          fgColor: getColor(LightColors.onPrimary, DarkColors.onPrimary),
        ),
        if (_counter > 0)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.03, 
              numberOfParticles: 40,    
              gravity: 0.08,            
              shouldLoop: false,
              maxBlastForce: 5,
              minBlastForce: 2,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
                Colors.red,
                Colors.cyan,
              ],
            ),
          ),
        if (_try == 0)
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: getColor(
                LightColors.primary.withOpacity(0.1),
                DarkColors.primary.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: getColor(LightColors.primary, DarkColors.primary),
                width: 1,
              ),
            ),
            child: Text(
              'Hai esaurito i tentativi!!!',
              style: TextStyle(
                color: getColor(LightColors.primary, DarkColors.primary),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
        SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsante per ricominciare il quiz in qualsiasi momento
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 8, right: 4),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text(
                    'Ricomincia',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getColor(Colors.orange, Colors.deepOrange[700]!),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    minimumSize: Size(100, 36),
                  ),
            onPressed: () {
              // Conferma prima di ricominciare il quiz
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: getColor(LightColors.surface, DarkColors.surface),
                  title: Text(
                    'Ricominciare?',
                    style: TextStyle(
                      color: getColor(LightColors.onBackground, DarkColors.onBackground),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Vuoi davvero ricominciare il quiz? Perderai il tuo punteggio attuale.',
                    style: TextStyle(
                      color: getColor(LightColors.onBackground, DarkColors.onBackground),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Annulla'),
                      style: TextButton.styleFrom(
                        foregroundColor: getColor(LightColors.primary, DarkColors.primary),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _ricominciaDaCapo();
                      },
                      child: Text('Sì, Ricomincia'),
                      style: TextButton.styleFrom(
                        foregroundColor: getColor(LightColors.error, DarkColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
                ),
              ),
            ),
            
            // Pulsante per cambiare quiz (tornare alla schermata di benvenuto)
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 8, left: 4),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.swap_horiz, size: 18),
                  label: Text(
                    'Cambia Quiz',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getColor(Colors.purple, Colors.deepPurple[700]!),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    minimumSize: Size(100, 36),
                  ),
                  onPressed: () {
                    // Conferma prima di cambiare quiz
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: getColor(LightColors.surface, DarkColors.surface),
                        title: Text(
                          'Cambiare Quiz?',
                          style: TextStyle(
                            color: getColor(LightColors.onBackground, DarkColors.onBackground),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Vuoi davvero tornare al menu di selezione? Perderai il tuo punteggio attuale.',
                          style: TextStyle(
                            color: getColor(LightColors.onBackground, DarkColors.onBackground),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Annulla'),
                            style: TextButton.styleFrom(
                              foregroundColor: getColor(LightColors.primary, DarkColors.primary),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _tornaBenvenuto();
                            },
                            child: Text('Sì, Cambia Quiz'),
                            style: TextButton.styleFrom(
                              foregroundColor: getColor(Colors.purple, Colors.purple[300]!),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CastoQuiz', style: TextStyle(fontSize: 26)),
        backgroundColor: getColor(LightColors.primary, DarkColors.primary),
        foregroundColor: getColor(LightColors.onPrimary, DarkColors.onPrimary),
        actions: [
          // Widget per mostrare il punteggio (solo quando non siamo nella schermata di benvenuto)
          if (!_showWelcome) 
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  'Punteggio: $_score',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          // Pulsante dark mode
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
            tooltip: _isDarkMode ? 'Passa alla modalità chiara' : 'Passa alla modalità scura',
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 10),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              getColor(LightColors.background, DarkColors.background),
              getColor(
                Color.lerp(LightColors.background, LightColors.primary.withOpacity(0.1), 0.1)!, 
                Color.lerp(DarkColors.background, DarkColors.primary.withOpacity(0.1), 0.1)!
              ),
            ],
          ),
        ),
        child: _loading 
            ? LoadingScreen() 
            : (_showWelcome ? welcomeScreen() : mainScreen()),
      ),
    );
  }
}

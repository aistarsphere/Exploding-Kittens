abstract class AppStrings {
  // Lobby
  String get title;
  String get subtitle;
  String get connecting;
  String get yourName;
  String get namePlaceholder;
  String get createRoom;
  String get joinRoom;
  String get roomCode;
  String get codePlaceholder;
  String get join;
  String get back;
  String get room;
  String get youAreMaster;
  String get waitingForMaster;
  String get you;
  String get master;
  String get offline;
  String get startGame;
  String get leave;
  String get shareHint;
  String get errEnterName;
  String get errEnterCode;
  String get errFailed;
  String get errFailedStart;
  // Game
  String get loading;
  String get gameOver;
  String get draw;
  String get discard;
  String get playSelected;
  String get drawEndTurn;
  String get yourTurn;
  String get couldNotRejoin;
  String get leaveGame;
  String get cannotPlay;
  String turnText(String name, bool isMe, int turns, String dir);
  // GameOver
  String wins(String name);
  String get gameOverTitle;
  String get playAgain;
  String get backToLobby;
  // NopeBanner
  String played(String name, String card);
  String nopeChain(int n);
  String get nope;
  // PickTarget / PromptModal
  String get pickAPlayer;
  String get cancel;
  // Opponents
  String cards(int n);
  String get out;
  // PromptModal
  String waitingFor(String name);
  String respondingTo(String type);
  String get seeFuture;
  String get top3Cards;
  String get ok;
  String get alterFuture;
  String get clickCardsOrder;
  String get newOrder;
  String get reset;
  String get confirm;
  String get favor;
  String giveCardTo(String name);
  String get pickTarget;
  String get stealRandom;
  String get nameCardSteal;
  String get nameACard;
  String get nameCardTake;
  String get defuse;
  String get reinsertKitten;
  String positionFromTop(int pos, int size);
  String positionHint(int size);
  String get reinsert;
}

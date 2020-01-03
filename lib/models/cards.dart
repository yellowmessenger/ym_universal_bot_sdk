class CardResponse {
  List<Cards> cards;

  CardResponse({this.cards});

  CardResponse.fromJson(Map<String, dynamic> json) {
    if (json['cards'] != null) {
      cards = List<Cards>();
      json['cards'].forEach((v) {
        cards.add(Cards.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.cards != null) {
      data['cards'] = this.cards.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cards {
  String title;
  String text;
  String image;
  List<Actions> actions;

  Cards({this.title, this.text, this.image, this.actions});

  Cards.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    text = json['text'];
    image = json['image'];
    if (json['actions'] != null) {
      actions = List<Actions>();
      json['actions'].forEach((v) {
        actions.add(Actions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = this.title;
    data['text'] = this.text;
    data['image'] = this.image;
    if (this.actions != null) {
      data['actions'] = this.actions.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Cards.fromMap(Map<String, dynamic> map) {
    title = map['card_title'];
    text = map['card_text'];
    image = map['card_image'];
    if (map['card_actions'] != null) {
      actions = List<Actions>();
      map['card_actions'].forEach((v) {
        actions.add(Actions.fromMap(v));
      });
    }
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['card_title'] = this.title;
    data['card_text'] = this.text;
    data['card_image'] = this.image;
    if (this.actions != null) {
      data['card_actions'] = this.actions.map((v) => v.toMap()).toList();
    }
    return data;
  }
}

class Actions {
  String title;
  String text;
  String url;

  Actions({this.title, this.text, this.url});

  Actions.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    text = json['text'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = this.title;
    data['text'] = this.text;
    data['url'] = this.url;
    return data;
  }

  Actions.fromMap(Map<String, dynamic> json) {
    title = json['title'];
    text = json['text'];
    url = json['url'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = this.title;
    data['text'] = this.text;
    data['url'] = this.url;
    return data;
  }
}

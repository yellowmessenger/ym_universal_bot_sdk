class QuickReplies {
  String title;
  bool multiSelect;
  List<Options> options;

  QuickReplies({this.title, this.options, this.multiSelect});

  QuickReplies.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if(json['multiSelect']!= null) multiSelect = json['multiSelect'];
    else multiSelect = false;
    if (json['options'] != null) {
      options = new List<Options>();
      json['options'].forEach((v) {
        options.add(new Options.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    if (this.options != null) {
      data['options'] = this.options.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Options {
  String title;
  String text;
  String url;
  String image;

  Options({this.title, this.text, this.url, this.image});

  Options.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    text = json['text'];
    url = json['url'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['text'] = this.text;
    data['url'] = this.url;
    data['image'] = this.image;
    return data;
  }
}
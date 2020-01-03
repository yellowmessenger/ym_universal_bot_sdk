class BotMapping {
	bool success;
	String message;
	Data data;

	BotMapping({this.success, this.message, this.data});

	BotMapping.fromJson(Map<String, dynamic> json) {
		success = json['success'];
		message = json['message'];
		data = json['data'] != null ? new Data.fromJson(json['data']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['success'] = this.success;
		data['message'] = this.message;
		if (this.data != null) {
      data['data'] = this.data.toJson();
    }
		return data;
	}
}

class Data {
	WelcomeOptions welcomeOptions;
	String botName;
	String botTitle;
	String userName;
	String botDesc;
	String botIntro;
	String botIcon;
	Skin skin;
	Skins skins;
	List<Null> promotions;
	String botType;
	List<Null> languages;

	Data({this.welcomeOptions, this.botName, this.botTitle, this.userName, this.botDesc, this.botIcon, this.skin, this.skins, this.promotions, this.botType, this.languages});

	Data.fromJson(Map<String, dynamic> json) {
		// welcomeOptions = json['welcomeOptions'] != null ? new WelcomeOptions.fromJson(json['welcomeOptions']) : null;
		botName = json['botName'];
		botTitle = json['botTitle'];
		userName = json['userName'];
		botDesc = json['botDesc'];
		botIntro = json['botIntro'];
		botIcon = json['botIcon'];
		skin = json['skin'] != null ? new Skin.fromJson(json['skin']) : null;
		skins = json['skins'] != null ? new Skins.fromJson(json['skins']) : null;
		// if (json['promotions'] != null) {
		// 	promotions = new List<String>();
		// 	json['promotions'].forEach((v) { promotions.add(new String.fromJson(v)); });
		// }
		botType = json['botType'];
		// if (json['languages'] != null) {
		// 	languages = new List<String>();
		// 	json['languages'].forEach((v) { languages.add(new String.fromJson(v)); });
		// }
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		// if (this.welcomeOptions != null) {
    //   data['welcomeOptions'] = this.welcomeOptions.toJson();
    // }
		data['botName'] = this.botName;
		data['botTitle'] = this.botTitle;
		data['userName'] = this.userName;
		data['botDesc'] = this.botDesc;
		data['botIntro'] = this.botIntro;
		data['botIcon'] = this.botIcon;
		if (this.skin != null) {
      data['skin'] = this.skin.toJson();
    }
		if (this.skins != null) {
      data['skins'] = this.skins.toJson();
    }
		// if (this.promotions != null) {
    //   data['promotions'] = this.promotions.map((v) => v.toJson()).toList();
    // }
		data['botType'] = this.botType;
		// if (this.languages != null) {
    //   data['languages'] = this.languages.map((v) => v.toJson()).toList();
    // }
		return data;
	}
}

class WelcomeOptions {
	List<Null> options;

	WelcomeOptions({this.options});

	// WelcomeOptions.fromJson(Map<String, dynamic> json) {
	// 	if (json['options'] != null) {
	// 		options = new List<Null>();
	// 		json['options'].forEach((v) { options.add(new Null.fromJson(v)); });
	// 	}
	// }

	// Map<String, dynamic> toJson() {
	// 	final Map<String, dynamic> data = new Map<String, dynamic>();
	// 	if (this.options != null) {
  //     data['options'] = this.options.map((v) => v.toJson()).toList();
  //   }
	// 	return data;
	// }
}

class Skin {
	String titleBackgroundColor;
	String titleTextColor;
	String titleSubColor;
	String buttonTextColor;
	String buttonBorderColor;
	String buttonHoverTextColor;
	String buttonPrimaryHoverBackgroundColor;
	String buttonPrimaryHoverBorderColor;
	String buttonPrimaryHoverTextColor;
	String buttonPrimaryTextColor;
	String buttonPrimaryBorderColor;
	String buttonPrimaryBackgroundColor;
	String buttonHoverBackgroundColor;
	String buttonBackgroundColor;
	String cardBackgroundColor;
	String cardTitleBackGroundColor;
	String productDescColor;
	String cardTitleColor;
	String primaryTextColor;
	String inputActionColor;
	String primaryColor;
	String secondaryColor;
	String chatBackgroundGradient1;
	String chatBackgroundGradient2;
	String chatBackgroundGradient3;
	String primaryBorderRadius;
	String secondaryBorderRadius;
	String backgroundVisibility;
	String botClickIcon;
	bool leftAlignUserMessages;
	String fontBoldItalicUrl;
	String fontBoldUrl;
	String buttonTextSize;
	String secondaryFontSize;
	String primaryFontSize;
	bool hideMic;
	bool scrollToBottomAlways;
	bool noScroll;
	String primaryBorderColor;
	bool topBarMobile;
	String productTitleColor;
	String customHomeButtonMessage;
	bool slowMessages;
	String chatBackground;
	bool sendButton;
	bool carousel;
	bool hideUpload;
	bool refreshContext;
	String secondaryTextColor;
	WelcomeOptions welcomeOptions;
	String buttonWidth;
	String cardWidth;
	bool oneCardRow;
	bool enableAutoComplete;
	String fontUrl;
	String iconSize;
	bool hideBranding;

	Skin({this.titleBackgroundColor, this.titleTextColor, this.titleSubColor, this.buttonTextColor, this.buttonBorderColor, this.buttonHoverTextColor, this.buttonPrimaryHoverBackgroundColor, this.buttonPrimaryHoverBorderColor, this.buttonPrimaryHoverTextColor, this.buttonPrimaryTextColor, this.buttonPrimaryBorderColor, this.buttonPrimaryBackgroundColor, this.buttonHoverBackgroundColor, this.buttonBackgroundColor, this.cardBackgroundColor, this.cardTitleBackGroundColor, this.productDescColor, this.cardTitleColor, this.primaryTextColor, this.inputActionColor, this.primaryColor, this.secondaryColor, this.chatBackgroundGradient1, this.chatBackgroundGradient2, this.chatBackgroundGradient3, this.primaryBorderRadius, this.secondaryBorderRadius, this.backgroundVisibility, this.botClickIcon, this.leftAlignUserMessages, this.fontBoldItalicUrl, this.fontBoldUrl, this.buttonTextSize, this.secondaryFontSize, this.primaryFontSize, this.hideMic, this.scrollToBottomAlways, this.noScroll, this.primaryBorderColor, this.topBarMobile, this.productTitleColor, this.customHomeButtonMessage, this.slowMessages, this.chatBackground, this.sendButton, this.carousel, this.hideUpload, this.refreshContext, this.secondaryTextColor, this.welcomeOptions, this.buttonWidth, this.cardWidth, this.oneCardRow, this.enableAutoComplete, this.fontUrl, this.iconSize, this.hideBranding});

	Skin.fromJson(Map<String, dynamic> json) {
		titleBackgroundColor = json['titleBackgroundColor'];
		titleTextColor = json['titleTextColor'];
		titleSubColor = json['titleSubColor'];
		buttonTextColor = json['buttonTextColor'];
		buttonBorderColor = json['buttonBorderColor'];
		buttonHoverTextColor = json['buttonHoverTextColor'];
		buttonPrimaryHoverBackgroundColor = json['buttonPrimaryHoverBackgroundColor'];
		buttonPrimaryHoverBorderColor = json['buttonPrimaryHoverBorderColor'];
		buttonPrimaryHoverTextColor = json['buttonPrimaryHoverTextColor'];
		buttonPrimaryTextColor = json['buttonPrimaryTextColor'];
		buttonPrimaryBorderColor = json['buttonPrimaryBorderColor'];
		buttonPrimaryBackgroundColor = json['buttonPrimaryBackgroundColor'];
		buttonHoverBackgroundColor = json['buttonHoverBackgroundColor'];
		buttonBackgroundColor = json['buttonBackgroundColor'];
		cardBackgroundColor = json['cardBackgroundColor'];
		cardTitleBackGroundColor = json['cardTitleBackGroundColor'];
		productDescColor = json['productDescColor'];
		cardTitleColor = json['cardTitleColor'];
		primaryTextColor = json['primaryTextColor'];
		inputActionColor = json['inputActionColor'];
		primaryColor = json['primaryColor'];
		secondaryColor = json['secondaryColor'];
		chatBackgroundGradient1 = json['chatBackgroundGradient1'];
		chatBackgroundGradient2 = json['chatBackgroundGradient2'];
		chatBackgroundGradient3 = json['chatBackgroundGradient3'];
		primaryBorderRadius = json['primaryBorderRadius'];
		secondaryBorderRadius = json['secondaryBorderRadius'];
		backgroundVisibility = json['backgroundVisibility'];
		botClickIcon = json['botClickIcon'];
		leftAlignUserMessages = json['leftAlignUserMessages'];
		fontBoldItalicUrl = json['fontBoldItalicUrl'];
		fontBoldUrl = json['fontBoldUrl'];
		buttonTextSize = json['buttonTextSize'];
		secondaryFontSize = json['secondaryFontSize'];
		primaryFontSize = json['primaryFontSize'];
		hideMic = json['hideMic'];
		scrollToBottomAlways = json['scrollToBottomAlways'];
		noScroll = json['noScroll'];
		primaryBorderColor = json['primaryBorderColor'];
		topBarMobile = json['topBarMobile'];
		productTitleColor = json['productTitleColor'];
		customHomeButtonMessage = json['customHomeButtonMessage'];
		slowMessages = json['slowMessages'];
		chatBackground = json['chatBackground'];
		sendButton = json['sendButton'];
		carousel = json['carousel'];
		hideUpload = json['hideUpload'];
		refreshContext = json['refreshContext'];
		secondaryTextColor = json['secondaryTextColor'];
		// welcomeOptions = json['welcomeOptions'] != null ? new WelcomeOptions.fromJson(json['welcomeOptions']) : null;
		buttonWidth = json['buttonWidth'];
		cardWidth = json['cardWidth'];
		oneCardRow = json['oneCardRow'];
		enableAutoComplete = json['enableAutoComplete'];
		fontUrl = json['fontUrl'];
		iconSize = json['iconSize'];
		hideBranding = json['hideBranding'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['titleBackgroundColor'] = this.titleBackgroundColor;
		data['titleTextColor'] = this.titleTextColor;
		data['titleSubColor'] = this.titleSubColor;
		data['buttonTextColor'] = this.buttonTextColor;
		data['buttonBorderColor'] = this.buttonBorderColor;
		data['buttonHoverTextColor'] = this.buttonHoverTextColor;
		data['buttonPrimaryHoverBackgroundColor'] = this.buttonPrimaryHoverBackgroundColor;
		data['buttonPrimaryHoverBorderColor'] = this.buttonPrimaryHoverBorderColor;
		data['buttonPrimaryHoverTextColor'] = this.buttonPrimaryHoverTextColor;
		data['buttonPrimaryTextColor'] = this.buttonPrimaryTextColor;
		data['buttonPrimaryBorderColor'] = this.buttonPrimaryBorderColor;
		data['buttonPrimaryBackgroundColor'] = this.buttonPrimaryBackgroundColor;
		data['buttonHoverBackgroundColor'] = this.buttonHoverBackgroundColor;
		data['buttonBackgroundColor'] = this.buttonBackgroundColor;
		data['cardBackgroundColor'] = this.cardBackgroundColor;
		data['cardTitleBackGroundColor'] = this.cardTitleBackGroundColor;
		data['productDescColor'] = this.productDescColor;
		data['cardTitleColor'] = this.cardTitleColor;
		data['primaryTextColor'] = this.primaryTextColor;
		data['inputActionColor'] = this.inputActionColor;
		data['primaryColor'] = this.primaryColor;
		data['secondaryColor'] = this.secondaryColor;
		data['chatBackgroundGradient1'] = this.chatBackgroundGradient1;
		data['chatBackgroundGradient2'] = this.chatBackgroundGradient2;
		data['chatBackgroundGradient3'] = this.chatBackgroundGradient3;
		data['primaryBorderRadius'] = this.primaryBorderRadius;
		data['secondaryBorderRadius'] = this.secondaryBorderRadius;
		data['backgroundVisibility'] = this.backgroundVisibility;
		data['botClickIcon'] = this.botClickIcon;
		data['leftAlignUserMessages'] = this.leftAlignUserMessages;
		data['fontBoldItalicUrl'] = this.fontBoldItalicUrl;
		data['fontBoldUrl'] = this.fontBoldUrl;
		data['buttonTextSize'] = this.buttonTextSize;
		data['secondaryFontSize'] = this.secondaryFontSize;
		data['primaryFontSize'] = this.primaryFontSize;
		data['hideMic'] = this.hideMic;
		data['scrollToBottomAlways'] = this.scrollToBottomAlways;
		data['noScroll'] = this.noScroll;
		data['primaryBorderColor'] = this.primaryBorderColor;
		data['topBarMobile'] = this.topBarMobile;
		data['productTitleColor'] = this.productTitleColor;
		data['customHomeButtonMessage'] = this.customHomeButtonMessage;
		data['slowMessages'] = this.slowMessages;
		data['chatBackground'] = this.chatBackground;
		data['sendButton'] = this.sendButton;
		data['carousel'] = this.carousel;
		data['hideUpload'] = this.hideUpload;
		data['refreshContext'] = this.refreshContext;
		data['secondaryTextColor'] = this.secondaryTextColor;
		// if (this.welcomeOptions != null) {
    //   data['welcomeOptions'] = this.welcomeOptions.toJson();
    // }
		data['buttonWidth'] = this.buttonWidth;
		data['cardWidth'] = this.cardWidth;
		data['oneCardRow'] = this.oneCardRow;
		data['enableAutoComplete'] = this.enableAutoComplete;
		data['fontUrl'] = this.fontUrl;
		data['iconSize'] = this.iconSize;
		data['hideBranding'] = this.hideBranding;
		return data;
	}
}

class Skins {

	Skins.fromJson(Map<String, dynamic> json) {
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		return data;
	}
}
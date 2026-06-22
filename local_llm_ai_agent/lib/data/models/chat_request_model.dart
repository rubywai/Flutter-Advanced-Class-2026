class ChatRequestModel {
  ChatRequestModel({
    this.model,
    this.messages,
    this.tools,
    this.stream,
    this.think,
  });

  ChatRequestModel.fromJson(dynamic json) {
    model = json['model'];
    if (json['messages'] != null) {
      messages = [];
      json['messages'].forEach((v) {
        messages?.add(Messages.fromJson(v));
      });
    }
    if (json['tools'] != null) {
      tools = [];
      json['tools'].forEach((v) {
        tools?.add(Tools.fromJson(v));
      });
    }
    stream = json['stream'];
    think = json['think'];
  }

  String? model;
  List<Messages>? messages;
  List<Tools>? tools;
  bool? stream;
  bool? think;

  ChatRequestModel copyWith({
    String? model,
    List<Messages>? messages,
    List<Tools>? tools,
    bool? stream,
    bool? think,
  }) => ChatRequestModel(
    model: model ?? this.model,
    messages: messages ?? this.messages,
    tools: tools ?? this.tools,
    stream: stream ?? this.stream,
    think: think ?? this.think,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['model'] = model;
    if (messages != null) {
      map['messages'] = messages?.map((v) => v.toJson()).toList();
    }
    if (tools != null) {
      map['tools'] = tools?.map((v) => v.toJson()).toList();
    }
    map['stream'] = stream;
    map['think'] = think;
    return map;
  }
}

class Tools {
  Tools({this.type, this.function});

  Tools.fromJson(dynamic json) {
    type = json['type'];
    function = json['function'] != null
        ? FunctionTools.fromJson(json['function'])
        : null;
  }

  String? type;
  FunctionTools? function;

  Tools copyWith({String? type, FunctionTools? function}) =>
      Tools(type: type ?? this.type, function: function ?? this.function);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    if (function != null) {
      map['function'] = function?.toJson();
    }
    return map;
  }
}

class FunctionTools {
  FunctionTools({this.name, this.description, this.parameters});

  FunctionTools.fromJson(dynamic json) {
    name = json['name'];
    description = json['description'];
    parameters = json['parameters'] != null
        ? Parameters.fromJson(json['parameters'])
        : null;
  }

  String? name;
  String? description;
  Parameters? parameters;

  FunctionTools copyWith({
    String? name,
    String? description,
    Parameters? parameters,
  }) => FunctionTools(
    name: name ?? this.name,
    description: description ?? this.description,
    parameters: parameters ?? this.parameters,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['description'] = description;
    if (parameters != null) {
      map['parameters'] = parameters?.toJson();
    }
    return map;
  }
}

class Parameters {
  Parameters({
    this.type,
    this.properties,
    this.required,
    this.additionalProperties,
  });

  Parameters.fromJson(dynamic json) {
    type = json['type'];
    properties = json['properties'] != null
        ? Properties.fromJson(json['properties'])
        : null;
    required = json['required'] != null ? json['required'].cast<String>() : [];
    additionalProperties = json['additionalProperties'];
  }

  String? type;
  Properties? properties;
  List<String>? required;
  bool? additionalProperties;

  Parameters copyWith({
    String? type,
    Properties? properties,
    List<String>? required,
    bool? additionalProperties,
  }) => Parameters(
    type: type ?? this.type,
    properties: properties ?? this.properties,
    required: required ?? this.required,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    if (properties != null) {
      map['properties'] = properties?.toJson();
    }
    map['required'] = required;
    map['additionalProperties'] = additionalProperties;
    return map;
  }
}

class Properties {
  Properties({this.title, this.content});

  Properties.fromJson(dynamic json) {
    title = json['title'] != null ? Title.fromJson(json['title']) : null;
    content = json['content'] != null
        ? Content.fromJson(json['content'])
        : null;
  }

  Title? title;
  Content? content;

  Properties copyWith({Title? title, Content? content}) =>
      Properties(title: title ?? this.title, content: content ?? this.content);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) {
      map['title'] = title?.toJson();
    }
    if (content != null) {
      map['content'] = content?.toJson();
    }
    return map;
  }
}

class Content {
  Content({this.type, this.description});

  Content.fromJson(dynamic json) {
    type = json['type'];
    description = json['description'];
  }

  String? type;
  String? description;

  Content copyWith({String? type, String? description}) => Content(
    type: type ?? this.type,
    description: description ?? this.description,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['description'] = description;
    return map;
  }
}

class Title {
  Title({this.type, this.description});

  Title.fromJson(dynamic json) {
    type = json['type'];
    description = json['description'];
  }

  String? type;
  String? description;

  Title copyWith({String? type, String? description}) => Title(
    type: type ?? this.type,
    description: description ?? this.description,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['description'] = description;
    return map;
  }
}

class Messages {
  Messages({this.role, this.content});

  Messages.fromJson(dynamic json) {
    role = json['role'];
    content = json['content'];
  }

  String? role;
  String? content;

  Messages copyWith({String? role, String? content}) =>
      Messages(role: role ?? this.role, content: content ?? this.content);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['role'] = role;
    map['content'] = content;
    return map;
  }
}

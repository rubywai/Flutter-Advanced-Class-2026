class ResponseModel {
  ResponseModel({
    this.model,
    this.createdAt,
    this.message,
    this.done,
    this.doneReason,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
    this.promptEvalDuration,
    this.evalCount,
    this.evalDuration,
  });

  ResponseModel.fromJson(dynamic json) {
    model = json['model'];
    createdAt = json['created_at'];
    message = json['message'] != null
        ? Message.fromJson(json['message'])
        : null;
    done = json['done'];
    doneReason = json['done_reason'];
    totalDuration = json['total_duration'];
    loadDuration = json['load_duration'];
    promptEvalCount = json['prompt_eval_count'];
    promptEvalDuration = json['prompt_eval_duration'];
    evalCount = json['eval_count'];
    evalDuration = json['eval_duration'];
  }

  String? model;
  String? createdAt;
  Message? message;
  bool? done;
  String? doneReason;
  num? totalDuration;
  num? loadDuration;
  num? promptEvalCount;
  num? promptEvalDuration;
  num? evalCount;
  num? evalDuration;

  ResponseModel copyWith({
    String? model,
    String? createdAt,
    Message? message,
    bool? done,
    String? doneReason,
    num? totalDuration,
    num? loadDuration,
    num? promptEvalCount,
    num? promptEvalDuration,
    num? evalCount,
    num? evalDuration,
  }) => ResponseModel(
    model: model ?? this.model,
    createdAt: createdAt ?? this.createdAt,
    message: message ?? this.message,
    done: done ?? this.done,
    doneReason: doneReason ?? this.doneReason,
    totalDuration: totalDuration ?? this.totalDuration,
    loadDuration: loadDuration ?? this.loadDuration,
    promptEvalCount: promptEvalCount ?? this.promptEvalCount,
    promptEvalDuration: promptEvalDuration ?? this.promptEvalDuration,
    evalCount: evalCount ?? this.evalCount,
    evalDuration: evalDuration ?? this.evalDuration,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['model'] = model;
    map['created_at'] = createdAt;
    if (message != null) {
      map['message'] = message?.toJson();
    }
    map['done'] = done;
    map['done_reason'] = doneReason;
    map['total_duration'] = totalDuration;
    map['load_duration'] = loadDuration;
    map['prompt_eval_count'] = promptEvalCount;
    map['prompt_eval_duration'] = promptEvalDuration;
    map['eval_count'] = evalCount;
    map['eval_duration'] = evalDuration;
    return map;
  }
}

class Message {
  Message({this.role, this.content, this.toolCalls});

  Message.fromJson(dynamic json) {
    role = json['role'];
    content = json['content'];
    if (json['tool_calls'] != null) {
      toolCalls = [];
      json['tool_calls'].forEach((v) {
        toolCalls?.add(ToolCalls.fromJson(v));
      });
    }
  }

  String? role;
  String? content;
  List<ToolCalls>? toolCalls;

  Message copyWith({
    String? role,
    String? content,
    List<ToolCalls>? toolCalls,
  }) => Message(
    role: role ?? this.role,
    content: content ?? this.content,
    toolCalls: toolCalls ?? this.toolCalls,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['role'] = role;
    map['content'] = content;
    if (toolCalls != null) {
      map['tool_calls'] = toolCalls?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ToolCalls {
  ToolCalls({this.id, this.function});

  ToolCalls.fromJson(dynamic json) {
    id = json['id'];
    function = json['function'] != null
        ? FunctionTool.fromJson(json['function'])
        : null;
  }

  String? id;
  FunctionTool? function;

  ToolCalls copyWith({String? id, FunctionTool? function}) =>
      ToolCalls(id: id ?? this.id, function: function ?? this.function);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    if (function != null) {
      map['function'] = function?.toJson();
    }
    return map;
  }
}

class FunctionTool {
  FunctionTool({this.index, this.name, this.arguments});

  FunctionTool.fromJson(dynamic json) {
    index = json['index'];
    name = json['name'];
    arguments = json['arguments'];
  }

  num? index;
  String? name;
  Map? arguments;

  FunctionTool copyWith({num? index, String? name, Map? arguments}) =>
      FunctionTool(
        index: index ?? this.index,
        name: name ?? this.name,
        arguments: arguments ?? this.arguments,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['index'] = index;
    map['name'] = name;
    if (arguments != null) {
      map['arguments'] = arguments;
    }
    return map;
  }
}

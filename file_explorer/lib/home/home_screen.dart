import 'dart:io';

import 'package:file_explorer/home/delete_confirm_dialog.dart';
import 'package:file_explorer/home/text_edit_screen.dart';
import 'package:flutter/material.dart';

import '../file_services/file_services.dart';
import 'create_new_file_dialog.dart';
import 'create_or_rename_folder_dialog.dart';

class HomeScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileServices _fileServices = FileServices();
  List<Directory> _currentFolderList = [];
  List<File> _currentFileList = [];
  String _currentLocation = "";

  @override
  void initState() {
    super.initState();
    _loadFileAndFolder(_currentLocation);
  }

  Widget _buildPathSegments() {
    if (_currentLocation.isEmpty) {
      return Text("/");
    }

    List<String> segments = _currentLocation
        .split("/")
        .where((s) => s.isNotEmpty)
        .toList();
    List<Widget> widgets = [];

    widgets.add(
      GestureDetector(
        onTap: () {
          setState(() => _currentLocation = "");
          _loadFileAndFolder("");
        },
        child: Text(
          "/",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );

    for (int i = 0; i < segments.length; i++) {
      String path = segments.sublist(0, i + 1).join("/");
      bool isLast = i == segments.length - 1;

      widgets.add(
        GestureDetector(
          onTap: isLast
              ? null
              : () {
                  setState(() => _currentLocation = path);
                  _loadFileAndFolder(path);
                },
          child: Text(
            "${segments[i]}${isLast ? "" : "/"}",
            style: TextStyle(
              color: isLast ? null : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return Row(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("File Explorer"),
        actions: [
          IconButton(
            tooltip: 'Creat new Folder',
            onPressed: () async {
              _createNewFolder("");
            },
            icon: Icon(Icons.create_new_folder),
          ),
          IconButton(
            tooltip: 'Create new File',
            onPressed: () async {
              _createNewFile("");
            },
            icon: Icon(Icons.note_add_outlined),
          ),
          PopupMenuButton<ThemeMode>(
            onSelected: (ThemeMode mode) {
              widget.onThemeChanged(mode);
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: ThemeMode.light,
                  child: Text("Light Theme"),
                ),
                PopupMenuItem(value: ThemeMode.dark, child: Text("Dark Theme")),
                PopupMenuItem(value: ThemeMode.system, child: Text("System")),
              ];
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ListTile(
              leading: IconButton(
                onPressed: _currentLocation == ""
                    ? null
                    : () {
                        List<String> directory = _currentLocation.split("/");
                        directory.removeLast();
                        _currentLocation = directory.join("/");
                        _loadFileAndFolder(_currentLocation);
                      },
                icon: Icon(Icons.arrow_back_ios),
              ),
              title: _buildPathSegments(),
            ),
          ),
          SliverList.builder(
            itemCount: _currentFolderList.length,
            itemBuilder: (context, index) {
              Directory directory = _currentFolderList[index];
              String folderName = directory.path.split("/").last;
              String folderLocation = "$_currentLocation/$folderName";
              return ListTile(
                onTap: () {
                  _currentLocation = folderLocation;
                  _loadFileAndFolder(folderLocation);
                },
                leading: Icon(Icons.folder),
                title: Text(directory.path.split('/').last),
                subtitle: Text(directory.statSync().changed.toString()),
                trailing: PopupMenuButton<String>(
                  onSelected: (String str) async {
                    if (str == 'delete') {
                      bool isDelete = await showDialog(
                        context: context,
                        builder: (context) {
                          return DeleteConfirmDialog(
                            title: "Delete Folder",
                            content: "Are you sure to delete $folderName",
                          );
                        },
                      );
                      if (isDelete && context.mounted) {
                        _deleteFolder(
                          folderLocation: folderLocation,
                          folderName: folderName,
                          context: context,
                        );
                      }
                    } else if (str == 'rename') {
                      _renameFolder("", folderName);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<String>(
                        value: "rename",
                        child: Text("Rename"),
                      ),
                      PopupMenuItem<String>(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ];
                  },
                ),
              );
            },
          ),
          SliverList.builder(
            itemCount: _currentFileList.length,
            itemBuilder: (context, index) {
              File file = _currentFileList[index];
              String fileName = file.path.split("/").last;
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return TextEditScreen(
                          currentFileLocation: '$_currentLocation/$fileName',
                        );
                      },
                    ),
                  );
                },
                leading: Icon(Icons.file_copy_outlined),
                title: Text(fileName),
                subtitle: Text(file.statSync().changed.toString()),
                trailing: PopupMenuButton<String>(
                  onSelected: (String str) async {
                    if (str == 'delete') {
                      bool isDelete = await showDialog(
                        context: context,
                        builder: (context) {
                          return DeleteConfirmDialog(
                            title: "Delete File",
                            content: "Are you sure to delete $fileName",
                          );
                        },
                      );
                      if (isDelete && context.mounted) {
                        _deleteFile(
                          fileLocation: '$_currentLocation/$fileName',
                          fileName: fileName,
                          context: context,
                        );
                      }
                    } else if (str == 'rename') {
                      _renameFile(fileName);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<String>(
                        value: "rename",
                        child: Text("Rename"),
                      ),
                      PopupMenuItem<String>(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _loadFileAndFolder(String path) async {
    _currentFolderList = await _fileServices.getFolderList(path);
    _currentFileList = await _fileServices.getFileList(path);
    setState(() {});
  }

  void _createNewFolder(String path) async {
    bool isOK = await showDialog(
      context: context,
      builder: (context) {
        return CreateOrRenameFolderDialog(
          currentLocation: "$_currentLocation/",
        );
      },
    );
    if (isOK) {
      _loadFileAndFolder(_currentLocation);
    }
  }

  void _renameFolder(String path, String oldName) async {
    bool isOK = await showDialog(
      context: context,
      builder: (context) {
        return CreateOrRenameFolderDialog(
          currentLocation: "$_currentLocation/",
          oldName: oldName,
        );
      },
    );
    if (isOK) {
      _loadFileAndFolder(_currentLocation);
    }
  }

  void _renameFile(String oldName) async {
    final TextEditingController controller = TextEditingController(
      text: oldName,
    );
    bool? isOK = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rename File"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "New file name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Rename"),
            ),
          ],
        );
      },
    );
    if (isOK == true && context.mounted) {
      final newName = controller.text.trim();
      if (newName.isNotEmpty && newName != oldName) {
        try {
          final oldFile = File('$_currentLocation/$oldName');
          await oldFile.rename('$_currentLocation/$newName');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text("Rename success to $newName"),
              ),
            );
          }
          _loadFileAndFolder(_currentLocation);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text("Rename failed"),
              ),
            );
          }
        }
      }
    }
  }

  void _createNewFile(String path) async {
    bool isOK = await showDialog(
      context: context,
      builder: (context) {
        return CreateNewFileDialog(currentLocation: '$_currentLocation/');
      },
    );
    if (isOK) {
      _loadFileAndFolder(_currentLocation);
    }
  }

  void _deleteFolder({
    required String folderLocation,
    required String folderName,
    required BuildContext context,
  }) async {
    try {
      await _fileServices.deleteFolder(folderLocation);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Delete success $folderName"),
          ),
        );
      }
      _loadFileAndFolder(_currentLocation);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Delete Failed $folderName"),
          ),
        );
      }
    }
  }

  void _deleteFile({
    required String fileLocation,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      await _fileServices.deleteFile(fileLocation);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Delete success $fileName"),
          ),
        );
      }
      _loadFileAndFolder(_currentLocation);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Delete Failed $fileName"),
          ),
        );
      }
    }
  }
}

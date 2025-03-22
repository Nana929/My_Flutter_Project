import 'package:flutter/material.dart';
import 'database.dart';
import 'concert_dao.dart';
import 'concert_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class NewConcertPage extends StatefulWidget {
  final AppDatabase database;
  final ConcertItem? concertToEdit; 

  const NewConcertPage({Key? key, required this.database, this.concertToEdit})
      : super(key: key);

  @override
  _NewConcertPageState createState() => _NewConcertPageState();
}

class _NewConcertPageState extends State<NewConcertPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late ConcertDao _concertDao;
  List<ConcertItem> _concerts = [];
  bool _isEditMode = false;
  ConcertItem? _selectedConcert;
  bool _allFieldsValid = false;

  @override
  void initState() {
    super.initState();
    _concertDao = widget.database.concertDao;
    _loadConcerts();

    // Check if we're editing an existing concert
    if (widget.concertToEdit != null) {
      _isEditMode = true;
      _selectedConcert = widget.concertToEdit;

      // Populate form with existing data
      _nameController.text = widget.concertToEdit!.name;
      _locationController.text = widget.concertToEdit!.location;
      _dateController.text = widget.concertToEdit!.date;

      // If your ConcertItem model doesn't have these fields, you can ignore them
      // or handle them differently
      _timeController.text = '';
      _descriptionController.text = '';
    }

    // Add listeners to check form validity
    _nameController.addListener(_validateForm);
    _locationController.addListener(_validateForm);
    _dateController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _allFieldsValid = _nameController.text.isNotEmpty &&
          _locationController.text.isNotEmpty &&
          _dateController.text.isNotEmpty;
    });
  }

  /// **📌 加载数据库中的演唱会**
  Future<void> _loadConcerts() async {
    final concerts = await _concertDao.findAllConcerts();
    setState(() {
      _concerts = concerts;
    });
  }

  /// **📌 添加新演唱会**
  Future<void> _saveConcert() async {
    if (!_allFieldsValid) {
      _showError("All fields must be filled!");
      return;
    }

    try {
      if (_isEditMode && _selectedConcert != null) {
        // Update existing concert
        final updatedConcert = _selectedConcert!.copyWith(
          name: _nameController.text,
          location: _locationController.text,
          date: _dateController.text,
        );

        await _concertDao.updateConcert(updatedConcert);
      } else {
        // Add new concert
        final newConcert = ConcertItem(
          name: _nameController.text,
          location: _locationController.text,
          date: _dateController.text,
        );

        await _concertDao.insertConcert(newConcert);

        // Save concert data to SharedPreferences for future use
        await _saveConcertToPrefs(newConcert);
      }

      await _loadConcerts();
      Navigator.pop(context, true); // Return true to indicate changes were made
    } catch (e) {
      _showError("Error saving concert: $e");
    }
  }

  /// **📌 删除演唱会**
  Future<void> _deleteConcert() async {
    if (_isEditMode && _selectedConcert != null) {
      try {
        await _concertDao.deleteConcert(_selectedConcert!);
        Navigator.pop(
            context, true); // Return true to indicate changes were made
      } catch (e) {
        _showError("Error deleting concert: $e");
      }
    }
  }

  /// **📌 保存演唱会数据到SharedPreferences**
  Future<void> _saveConcertToPrefs(ConcertItem concert) async {
    try {
      final storage = FlutterSecureStorage();

      // 创建 JSON 对象
      final concertData = jsonEncode({
        'name': _nameController.text,
        'location': _locationController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'description': _descriptionController.text,
      });

      await storage.write(
          key: 'last_concert', value: concertData); // 🔥 存储整个 JSON
    } catch (e) {
      print("Error saving to SharedPreferences: $e");
    }
  }

  /// **📌 从SharedPreferences加载上一次的演唱会数据**
  Future<void> _loadPreviousConcert() async {
    try {
      final storage = FlutterSecureStorage();
      final concertJson = await storage.read(key: 'last_concert');

      if (concertJson == null) {
        _showError(
            "No previous concert data found"); // 🔥 避免 `jsonDecode(null)`
        return;
      }

      // 🔥 确保 `jsonDecode` 安全运行
      final Map<String, dynamic> concertMap = jsonDecode(concertJson);

      setState(() {
        _nameController.text = concertMap['name'] ?? '';
        _locationController.text = concertMap['location'] ?? '';
        _dateController.text = concertMap['date'] ?? '';
        _timeController.text = concertMap['time'] ?? '';
        _descriptionController.text = concertMap['description'] ?? '';
      });

      _validateForm(); // 🔥 确保按钮状态正确
    } catch (e) {
      _showError("Error loading previous concert: $e");
    }
  }

  /// **📌 清空表单**
  void _clearFields() {
    setState(() {
      _nameController.clear();
      _locationController.clear();
      _dateController.clear();
      _timeController.clear();
      _descriptionController.clear();
    });
  }

  /// **📌 显示错误消息**
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Edit Concert" : "New Concert"),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: Icon(Icons.copy),
              tooltip: "Copy from previous concert",
              onPressed: _loadPreviousConcert,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Concert Name:"),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter concert name",
                errorText: _nameController.text.isEmpty &&
                        _nameController.text.isNotEmpty
                    ? "Name is required"
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text("Location:"),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: "Enter location",
                errorText: _locationController.text.isEmpty &&
                        _nameController.text.isNotEmpty
                    ? "Location is required"
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text("Date:"),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                hintText: "Enter date (YYYY-MM-DD)",
                errorText: _dateController.text.isEmpty &&
                        _nameController.text.isNotEmpty
                    ? "Date is required"
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text("Time (Optional):"),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                hintText: "Enter time (HH:MM)",
              ),
            ),
            const SizedBox(height: 12),
            Text("Description (Optional):"),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: "Enter description",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_isEditMode)
                  ElevatedButton(
                    onPressed: _deleteConcert,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Delete"),
                  ),
                ElevatedButton(
                  onPressed: _allFieldsValid ? _saveConcert : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 204, 161, 106),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isEditMode ? "Update" : "Submit"),
                ),
                if (!_isEditMode)
                  ElevatedButton(
                    onPressed: _clearFields,
                    child: Text("Clear"),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (!_isEditMode)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Recent Concerts",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: _concerts.isEmpty
                          ? Center(child: Text("No concerts yet."))
                          : ListView.builder(
                              itemCount: _concerts.length,
                              itemBuilder: (context, index) {
                                final concert = _concerts[index];
                                return ListTile(
                                  title: SelectableText(
                                      "${concert.date}  ${concert.name}"),
                                  subtitle:
                                      SelectableText("Location: ${concert.location}"),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

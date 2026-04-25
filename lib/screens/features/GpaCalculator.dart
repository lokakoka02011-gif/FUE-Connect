import 'package:flutter/material.dart';

class GpaCalculator extends StatefulWidget {
  const GpaCalculator({super.key});

  @override
  State<GpaCalculator> createState() => _GpaCalculatorState();
}

class _GpaCalculatorState extends State<GpaCalculator> {
  // FUE Grading Scale Mapping
  final Map<String, double> gradingScale = {
    'A': 4.0, 'A-': 3.7, 'B+': 3.3, 'B': 3.0, 'B-': 2.7,
    'C+': 2.3, 'C': 2.0, 'C-': 1.7, 'D+': 1.3, 'D': 1.0, 'F': 0.0,
  };

  // Mode 1: Quick CGPA Predictor Controllers
  final TextEditingController currentCgpaController = TextEditingController();
  final TextEditingController completedHoursController = TextEditingController();
  final TextEditingController expectedSemesterGpaController = TextEditingController();
  final TextEditingController semesterHoursController = TextEditingController();
  double? quickResult;

  // Mode 2: Semester Planner Data (with name controllers)
  List<Map<String, dynamic>> subjects = [
    {'nameController': TextEditingController(text: 'Subject 1'), 'hours': 3, 'grade': 'A'},
  ];

  // Logic for Mode 1
  void calculateQuickCgpa() {
    double currentCgpa = double.tryParse(currentCgpaController.text) ?? 0.0;
    double completedHours = double.tryParse(completedHoursController.text) ?? 0.0;
    double expectedGpa = double.tryParse(expectedSemesterGpaController.text) ?? 0.0;
    double semesterHours = double.tryParse(semesterHoursController.text) ?? 0.0;

    double totalPoints = (currentCgpa * completedHours) + (expectedGpa * semesterHours);
    double totalHours = completedHours + semesterHours;

    setState(() {
      quickResult = totalHours == 0 ? 0.0 : totalPoints / totalHours;
    });
  }

  // Logic for Mode 2
  double calculateSemesterGpa() {
    double totalPoints = 0;
    double totalHours = 0;
    for (var sub in subjects) {
      totalPoints += (gradingScale[sub['grade']]! * sub['hours']);
      totalHours += sub['hours'];
    }
    return totalHours == 0 ? 0.0 : totalPoints / totalHours;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("FUE GPA Planner"),
          backgroundColor: const Color(0xffb1170c),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Semester Planner", icon: Icon(Icons.list_alt)),
              Tab(text: "Quick CGPA", icon: Icon(Icons.bolt)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSemesterPlanner(),
            _buildQuickCalculator(),
          ],
        ),
      ),
    );
  }

  // --- UI FOR MODE 2: SEMESTER PLANNER ---
  Widget _buildSemesterPlanner() {
    double currentGpa = calculateSemesterGpa();

    return Column(
      children: [
        const SizedBox(height: 25),
        // Animated Circle Display
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: currentGpa / 4.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
          builder: (context, value, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffb1170c)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (value * 4.0).toStringAsFixed(2),
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const Text("GPA", style: TextStyle(color: Colors.grey, letterSpacing: 1.2)),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 25),

        Expanded(
          child: ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      // Editable Name
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: subjects[index]['nameController'],
                          decoration: const InputDecoration(
                            hintText: "Subject Name",
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Credits Dropdown
                      DropdownButton<int>(
                        value: subjects[index]['hours'],
                        underline: const SizedBox(),
                        items: [1, 2, 3, 4].map((h) => DropdownMenuItem(value: h, child: Text("$h Hrs"))).toList(),
                        onChanged: (val) => setState(() => subjects[index]['hours'] = val),
                      ),
                      const SizedBox(width: 8),
                      // Grade Dropdown
                      DropdownButton<String>(
                        value: subjects[index]['grade'],
                        underline: const SizedBox(),
                        items: gradingScale.keys.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (val) => setState(() => subjects[index]['grade'] = val),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                        onPressed: () => setState(() => subjects.removeAt(index)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Action Footer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => setState(() => subjects.add({
              'nameController': TextEditingController(text: 'New Subject'),
              'hours': 3,
              'grade': 'A'
            })),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add Subject", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // --- UI FOR MODE 1: QUICK PREDICTOR ---
  Widget _buildQuickCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildInputField(currentCgpaController, "Current CGPA", Icons.analytics_outlined),
          _buildInputField(completedHoursController, "Total Completed Hours", Icons.history),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(thickness: 1),
          ),
          _buildInputField(expectedSemesterGpaController, "Expected Semester GPA", Icons.stars_outlined),
          _buildInputField(semesterHoursController, "This Semester's Hours", Icons.add_chart),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: calculateQuickCgpa,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffb1170c),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Predict New CGPA", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          if (quickResult != null) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xffb1170c)),
              ),
              child: Column(
                children: [
                  const Text("Estimated Total CGPA", style: TextStyle(color: Colors.black54)),
                  Text(
                    quickResult!.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xffb1170c)),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xffb1170c)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xffb1170c), width: 2),
          ),
        ),
      ),
    );
  }
}
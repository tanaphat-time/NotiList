import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notilist/models/controller.dart';
import 'package:notilist/pages/add_task_page.dart';
import 'package:notilist/weather.dart';
import 'package:weather/weather.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final TodoController nc = Get.put(TodoController());

  DateTime today = DateTime.now();
  final src =
      'https://variety.com/wp-content/uploads/2023/03/john-wick-chapter-4-keanu.jpg?w=1000&h=563&crop=1';
  String date = DateFormat("MMMM d, yyyy").format(DateTime.now());
  final auth = FirebaseAuth.instance;
  final WeatherFactory wf = WeatherFactory(api);
  Weather? weather;
  @override
  void initState() {
    super.initState();
    wf.currentWeatherByCityName("Bangkok").then((w) {
      setState(() {
        weather = w;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 255, 255, 255), // Set the background color to transparent
      appBar: AppBar(
        backgroundColor: const Color(0xffff7a00).withOpacity(0.3),
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'My To Do List,',
                        style: TextStyle(
                            color: Color(0xff7a2d2d),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Adamina'),
                      ),
                      Text(
                        auth.currentUser?.email ?? 'No email available',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(src),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.device_thermostat),
                  if (weather != null)
                    Text(
                      "${weather?.temperature!.celsius!.toStringAsFixed(2)} °C  |  $date",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  if (weather == null)
                    Text(
                      'N/A °C  |  $date',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              )
            ],
          ),
        ),
        toolbarHeight: 140,
        elevation: 0.0,
        flexibleSpace: Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 30.0),
          height: double.maxFinite,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black45,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'unique1',
        backgroundColor: Colors.white,
        onPressed: () {
          Get.to(() => MyTodo());
        }, // Add a unique heroTag for the FloatingActionButton
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xffff7a00).withOpacity(0.3),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color(0xffffefdb),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 16, right: 16, top: 5, bottom: 5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: date_picker(),
                ),
                getTodoList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DatePicker date_picker() {
    return DatePicker(
      today,
      height: 84,
      width: 60,
      initialSelectedDate: today,
      selectionColor: const Color(0xffffdec8),
      selectedTextColor: Colors.black,
      dateTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      onDateChange: (selectedDate) {
        today = selectedDate;
      },
    );
  }

  Widget getTodoList() {
    return Obx(
      () => nc.tasks.isEmpty
          ? Container(
              margin: EdgeInsets.only(top: 10),
              child: Text('No tasks yet'),
            )
          : Expanded(
              child: ListView.builder(
                itemCount: nc.tasks.length,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  shadowColor: const Color.fromARGB(255, 226, 226, 226).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    tileColor: getColorFromIndex(nc.tasks[index].colorIndex),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), 
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    title: Row(
                      children: [
                        Checkbox(
                          value: nc.tasks[index].isChecked,
                          onChanged: (newValue) {
                            nc.tasks[index].isChecked = newValue ?? false;
                            nc.tasks.refresh(); // Refresh the observable list
                          },
                          checkColor: Colors.white,
                          activeColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        const SizedBox(
                            width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nc.tasks[index].title.length > 15
                                    ? nc.tasks[index].title.substring(0, 15)
                                    : nc.tasks[index].title,
                                style: TextStyle(
                                  decoration: nc.tasks[index].isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                nc.tasks[index].description.length > 15
                                    ? nc.tasks[index].description.substring(0, 15)
                                    : nc.tasks[index].description,
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Get.to(() => MyTodo(index: index));
                            } else if (value == 'delete') {
                              Get.defaultDialog(
                                title: 'Delete Task',
                                middleText: nc.tasks[index].title,
                                onCancel: () => Get.back(),
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  nc.tasks.removeAt(index);
                                  Get.back();
                                },
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Color getColorFromIndex(int index) {
    switch (index) {
      case 0:
        return const Color.fromRGBO(255, 255, 255, 1);
      case 1:
        return const Color.fromRGBO(255, 174, 174, 1);
      case 2:
        return const Color.fromRGBO(255, 211, 146, 1);
      case 3:
        return const Color.fromRGBO(183, 246, 255, 1);
      case 4:
        return const Color.fromRGBO(205, 175, 255, 1);
      default:
        return Colors.white;
    }
  }
}

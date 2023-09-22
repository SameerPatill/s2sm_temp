import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:provider/provider.dart';
import 'package:soul_to_soul_admin/constants.dart';
import 'package:soul_to_soul_admin/controllers/MenuAppController.dart';
import 'package:soul_to_soul_admin/controllers/database_controller.dart';
import 'package:soul_to_soul_admin/models/database_functions.dart';
import 'package:soul_to_soul_admin/models/s2sm_employee.dart';
import 'package:soul_to_soul_admin/screens/dashboard/components/dashboard_header.dart';

class EmployeesScreen extends StatefulWidget {
  EmployeesScreen(this.setStateCallBack);
  Function? setStateCallBack;
  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<Employee> _employees = [];
  List<Employee> _searchEmployees = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _executeUpdateCheckQuery() async {
    var conn = await DatabaseController.connectoToDatabase();
    final result = await DatabaseController.executeQueryOnDatabase(
      conn,
      "SELECT e.employee_id, e.first_name, e.last_name, e.username, eu.is_online, eu.is_blocked, eu.last_active FROM employee e INNER JOIN employee_utilities eu ON e.employee_id = eu.employee_id; ",
    );
    DatabaseController.closeConnectionToDatabase(conn);

    for (var element in result.rows) {
      Employee emp = Employee.fromJson(element.assoc());
      for (var el in _employees) {
        if (emp.employeeId == el.employeeId) {
          if (emp.isOnline != el.isOnline || emp.isBlocked != el.isBlocked) {
            setState(() {
              int ind = _employees.indexOf(el);
              _employees[ind] = emp;
            });
          }
          break;
        }
      }
    }

    Future.delayed(const Duration(seconds: 5), _executeUpdateCheckQuery);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseFunctions.getAllEmployees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              _employees.clear();
              _employees.addAll(snapshot.data!);
              _executeUpdateCheckQuery();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Technical Error")));
            }
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.03,
                right: MediaQuery.of(context).size.width * 0.015,
                top: MediaQuery.of(context).size.height * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Employees",
                        style: GoogleFonts.nunito(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.35),
                        child: Row(
                          children: [
                            Container(
                              child: Text(
                                DateFormat("MMM d,\nyyyy")
                                    .format(DateTime.now()),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          0.005),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.045,
                                child: VerticalDivider(
                                  color: Colors.grey.shade400,
                                  thickness: 3,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                DateFormat("EEEE").format(DateTime.now()),
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.03),
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    child: ElevatedButton(
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: defaultPadding * 1.5,
                                          vertical: defaultPadding / 0.8,
                                        ),
                                      ),
                                      onPressed: () {
                                        Provider.of<MenuAppController>(context,
                                                listen: false)
                                            .selectedNav = 0;
                                        widget.setStateCallBack!(0);
                                      },
                                      // icon: SvgPicture.asset(
                                      //     "assets/icons/menu_dashboard.svg"),
                                      child: Text(
                                        "Dashboard",
                                        style: GoogleFonts.nunito(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.52,
                        child: MaterialTextField(
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.nunito(),
                          hint: 'Search Employee',
                          labelText: 'Search Employee',
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.search_rounded),
                          controller: null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.03),
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    child: ElevatedButton(
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: defaultPadding * 1.6,
                                          vertical: defaultPadding / 0.9,
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                        "Add Employee",
                                        style: GoogleFonts.nunito(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ListView.builder(
                      itemCount: _employees.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.02),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.07,
                            child: ListTile(
                              tileColor: _employees[index].isBlocked
                                  ? Colors.red.shade100
                                  : Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.02,
                                // vertical: MediaQuery.of(context).size.height * 0.01,
                              ),
                              trailing: Container(
                                width:
                                    MediaQuery.of(context).size.width * 0.155,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            _employees[index].isBlocked
                                                ? Colors.red
                                                : Colors.transparent,
                                        foregroundColor:
                                            _employees[index].isBlocked
                                                ? Colors.white
                                                : Colors.grey,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: BorderSide(
                                              color: _employees[index].isBlocked
                                                  ? Colors.transparent
                                                  : Colors.grey,
                                            )),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.018,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_employees[index].isBlocked) {
                                          await DatabaseFunctions
                                              .unblockEmployee(
                                                  _employees[index].employeeId);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "${_employees[index].employeeId} - ${_employees[index].firstName} ${_employees[index].lastName} has been successfully Unblocked",
                                              ),
                                            ),
                                          );
                                          setState(() {});
                                        } else {
                                          DatabaseFunctions.blockEmployee(
                                              _employees[index].employeeId);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "${_employees[index].employeeId} - ${_employees[index].firstName} ${_employees[index].lastName} has been successfully Blocked",
                                              ),
                                            ),
                                          );
                                          setState(() {});
                                        }
                                      },
                                      child: Text(
                                        _employees[index].isBlocked
                                            ? "Unblock"
                                            : "Block",
                                        style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.015,
                                    ),
                                    ElevatedButton(
                                      style: TextButton.styleFrom(
                                        // backgroundColor: Colors.transparent,
                                        // foregroundColor: Colors.grey,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          // side: BorderSide(color: Colors.grey),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.013,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                        "Delete",
                                        style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: _employees[index].isBlocked
                                      ? Colors.red.shade100
                                      : Colors.black,
                                  width: 0,
                                ),
                              ),
                              title: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                // color: Colors.black,
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${_employees[index].firstName} ${_employees[index].lastName}",
                                      style: GoogleFonts.nunito(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.02,
                                    ),
                                    Text(
                                      _employees[index].isOnline
                                          ? "Online"
                                          : "Offline",
                                      style: GoogleFonts.nunito(
                                        color: _employees[index].isOnline
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

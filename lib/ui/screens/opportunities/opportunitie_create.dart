import 'dart:io';
import 'package:bottle_crm/bloc/contact_bloc.dart';
import 'package:bottle_crm/bloc/dashboard_bloc.dart';
import 'package:bottle_crm/bloc/team_bloc.dart';
import 'package:bottle_crm/bloc/user_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:bottle_crm/bloc/opportunity_bloc.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
//import 'package:textfield_tags/textfield_tags.dart';
import '../../../utils/utils.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:file_picker/file_picker.dart';

class CreateOpportunities extends StatefulWidget {
  CreateOpportunities();
  @override
  State createState() => _CreateOpportunitiesState();
}

class _CreateOpportunitiesState extends State<CreateOpportunities> {
  quill.QuillController _controller = quill.QuillController.basic();
  final GlobalKey<FormState> _opportunityFormKey = GlobalKey<FormState>();
  TextEditingController _dateController = TextEditingController();
  TextEditingController fileNameController = new TextEditingController();
  String? selectedDate = "";
  DateTime? initialDate = DateTime.now();
  var _currentTabIndex = 0;
  Map _errors = {};
  bool _isLoading = false;
  File file = new File('');
  List _opportunityFormKeys = [
    "name",
    "account",
    "amount",
    "contacts",
    "currency",
    "stage",
    "lead_source",
    "probability",
    "assigned_to",
    "contacts",
    "due_date",
    "tags",
    "opportunity_attachment"
        "teams"
  ];

  @override
  void initState() {
    _dateController.text = DateFormat("yyyy-MM-dd")
        .format(DateFormat("yyyy-MM-dd").parse(DateTime.now().toString()));
    super.initState();
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate!,
      firstDate: DateTime(1950),
      lastDate: DateTime(2023),
    );
    if (selected != null && selected.toString() != selectedDate)
      setState(() {
        initialDate = selected;
        selectedDate = DateFormat("yyyy-MM-dd")
            .format(DateFormat("yyyy-MM-dd").parse(selected.toString()));
        _dateController.text = DateFormat("yyyy-MM-dd")
            .format(DateFormat("yyyy-MM-dd").parse(selected.toString()));
      });
  }

  buildTopBar() {
    if (_currentTabIndex == 0) {
      return SwipeDetector(
          onSwipeLeft: (offset) {
            setState(() {
              if (_opportunityFormKey.currentState != null)
                _opportunityFormKey.currentState!.save();
              _currentTabIndex = 1;
            });
          },
          child: buildOpportunityBlock());
    } else if (_currentTabIndex == 1) {
      return SwipeDetector(
          onSwipeRight: (offset) {
            setState(() {
              _currentTabIndex = 0;
            });
          },
          child: buildDescriptionBlock());
    }
  }

  OutlineInputBorder buildBorder(Color color) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(3.0)));
  }

  OutlineInputBorder boxBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      borderSide: BorderSide(width: 1, color: Colors.black45),
    );
  }

  _filePicker() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      file = File(result.files[0].path!);
      var _filename = file.path.toString();
      var split = _filename.split('/');
      Map<int, String> values = {
        for (int i = 0; i < split.length; i++) i: split[i]
      };
      setState(() {
        fileNameController.text = values[7].toString();
      });
    } else {}
  }

  EdgeInsets padding() {
    return EdgeInsets.symmetric(
        horizontal: screenWidth / 30, vertical: screenHeight / 80);
  }

  Widget buildOpportunityBlock() {
    return Container(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
                key: _opportunityFormKey,
                child: Container(
                    child: Column(children: [
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(bottom: 5.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Name ',
                                    style: buildLableTextStyle(),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '* ',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: screenWidth / 25,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                )),
                            SizedBox(height: screenHeight / 70),
                            Container(
                              width: screenWidth * 0.92,
                              child: TextFormField(
                                initialValue: opportunityBloc
                                    .currentEditOpportunity['name'],
                                cursorWidth: 3.0,
                                decoration: new InputDecoration(
                                  contentPadding: new EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 10.0),
                                  enabledBorder: buildBorder(Colors.black54),
                                  focusedErrorBorder:
                                      buildBorder(Colors.black54),
                                  focusedBorder: buildBorder(Colors.black54),
                                  errorBorder: buildBorder(Colors.black54),
                                  border: buildBorder(Colors.black54),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'This field is required.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  opportunityBloc
                                      .currentEditOpportunity['name'] = value;
                                },
                              ),
                            ),
                            _errors['name'] != null
                                ? Container(
                                    margin: EdgeInsets.only(top: 5.0),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _errors['name'][0],
                                      style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 12.0),
                                    ),
                                  )
                                : Container(),
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(bottom: 5.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Lead Source ',
                                    style: buildLableTextStyle(),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '* ',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: screenWidth / 25,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                )),
                            SizedBox(height: screenHeight / 70),
                            Container(
                              height: 48.0,
                              margin: EdgeInsets.only(bottom: 5.0),
                              child: DropdownSearch<String?>(
                                items: opportunityBloc.leadSourceObjforDropDown,
                                onChanged: print,
                                onSaved: (selection) {
                                  if (selection == null) {
                                    opportunityBloc.currentEditOpportunity[
                                        'lead_source'] = "";
                                  } else {
                                    opportunityBloc.currentEditOpportunity[
                                        'lead_source'] = selection;
                                  }
                                },
                                selectedItem: opportunityBloc
                                    .currentEditOpportunity['lead_source'],
                                popupProps: PopupProps.bottomSheet(
                                  itemBuilder: (context, item, isSelected) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 10.0),
                                      child: Text(item!,
                                          style: TextStyle(
                                              fontSize: screenWidth / 22)),
                                    );
                                  },
                                  constraints: BoxConstraints(maxHeight: 400),
                                  searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                    border: boxBorder(),
                                    enabledBorder: boxBorder(),
                                    focusedErrorBorder: boxBorder(),
                                    focusedBorder: boxBorder(),
                                    errorBorder: boxBorder(),
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: "Search a Lead Source",
                                  )),
                                  showSearchBox: true,
                                  showSelectedItems: false,
                                ),
                              ),
                            )
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account",
                              style: buildLableTextStyle(),
                            ),
                            SizedBox(height: screenHeight / 70),
                            Container(
                              height: 48.0,
                              margin: EdgeInsets.only(bottom: 5.0),
                              child: DropdownSearch<String?>(
                                items: opportunityBloc.accountsObjforDropDown,
                                onChanged: print,
                                onSaved: (selection) {
                                  if (selection == null) {
                                    opportunityBloc
                                        .currentEditOpportunity['account'] = "";
                                  } else {
                                    opportunityBloc
                                            .currentEditOpportunity['account'] =
                                        selection;
                                  }
                                },
                                selectedItem: opportunityBloc
                                    .currentEditOpportunity['account'],
                                popupProps: PopupProps.bottomSheet(
                                  itemBuilder: (context, item, isSelected) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 10.0),
                                      child: Text(item!,
                                          style: TextStyle(
                                              fontSize: screenWidth / 22)),
                                    );
                                  },
                                  constraints: BoxConstraints(maxHeight: 400),
                                  searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                    border: boxBorder(),
                                    enabledBorder: boxBorder(),
                                    focusedErrorBorder: boxBorder(),
                                    focusedBorder: boxBorder(),
                                    errorBorder: boxBorder(),
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: "Search a Lead Source",
                                  )),
                                  showSearchBox: true,
                                  showSelectedItems: false,
                                ),
                              ),
                            )
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(bottom: 5.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Probability ',
                                    style: buildLableTextStyle(),
                                  ),
                                )),
                            SizedBox(height: screenHeight / 70),
                            Container(
                              width: screenWidth * 0.92,
                              child: TextFormField(
                                maxLength: 2,
                                initialValue: opportunityBloc
                                    .currentEditOpportunity['probability']
                                    .toString(),
                                decoration: new InputDecoration(
                                  contentPadding: new EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 10.0),
                                  enabledBorder: buildBorder(Colors.black54),
                                  focusedErrorBorder:
                                      buildBorder(Colors.black54),
                                  focusedBorder: buildBorder(Colors.black54),
                                  errorBorder: buildBorder(Colors.black54),
                                  border: buildBorder(Colors.black54),
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (value) {
                                  opportunityBloc.currentEditOpportunity[
                                      'probability'] = value;
                                },
                              ),
                            ),
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(bottom: 5.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Amount ',
                                    style: buildLableTextStyle(),
                                  ),
                                )),
                            SizedBox(height: screenHeight / 70),
                            Container(
                              width: screenWidth * 0.92,
                              child: TextFormField(
                                initialValue: opportunityBloc
                                    .currentEditOpportunity['amount']
                                    .toString(),
                                decoration: new InputDecoration(
                                  contentPadding: new EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 10.0),
                                  enabledBorder: buildBorder(Colors.black54),
                                  focusedErrorBorder:
                                      buildBorder(Colors.black54),
                                  focusedBorder: buildBorder(Colors.black54),
                                  errorBorder: buildBorder(Colors.black54),
                                  border: buildBorder(Colors.black54),
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (value) {
                                  opportunityBloc
                                      .currentEditOpportunity['amount'] = value;
                                },
                              ),
                            ),
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Teams",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54),
                            ),
                            SizedBox(height: screenHeight / 70),
                            Container(
                                child: MultiSelectFormField(
                                    border: boxBorder(),
                                    fillColor: Colors.white,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select one or more options';
                                      }
                                      return null;
                                    },
                                    dataSource: teamBloc.teamsObjForDropdown,
                                    textField: 'name',
                                    valueField: 'id',
                                    okButtonLabel: 'OK',
                                    chipLabelStyle:
                                        TextStyle(color: Colors.black),
                                    cancelButtonLabel: 'CANCEL',
                                    // required: true,
                                    hintWidget: Text(
                                      "Please choose one or more",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    title: Text(
                                      "teams",
                                    ),
                                    initialValue: opportunityBloc
                                        .currentEditOpportunity['teams'],
                                    onSaved: (value) {
                                      if (value == null) return;
                                      opportunityBloc
                                              .currentEditOpportunity['teams'] =
                                          value;
                                    }))
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Currency",
                              style: buildLableTextStyle(),
                            ),
                            SizedBox(height: screenHeight / 70),
                            Container(
                              height: 48.0,
                              margin: EdgeInsets.only(bottom: 5.0),
                              child: DropdownSearch<String?>(
                                items: opportunityBloc.currencyObjforDropDown,
                                onChanged: print,
                                onSaved: (selection) {
                                  if (selection == null) {
                                    opportunityBloc.currentEditOpportunity[
                                        'currency'] = "";
                                  } else {
                                    opportunityBloc.currentEditOpportunity[
                                        'currency'] = selection;
                                  }
                                },
                                selectedItem: opportunityBloc
                                    .currentEditOpportunity['currency'],
                                popupProps: PopupProps.bottomSheet(
                                  itemBuilder: (context, item, isSelected) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 10.0),
                                      child: Text(item!,
                                          style: TextStyle(
                                              fontSize: screenWidth / 22)),
                                    );
                                  },
                                  constraints: BoxConstraints(maxHeight: 400),
                                  searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                    border: boxBorder(),
                                    enabledBorder: boxBorder(),
                                    focusedErrorBorder: boxBorder(),
                                    focusedBorder: boxBorder(),
                                    errorBorder: boxBorder(),
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: "Search a Currency",
                                  )),
                                  showSearchBox: true,
                                  showSelectedItems: false,
                                ),
                              ),
                            )
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(bottom: 5.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Stage ',
                                    style: buildLableTextStyle(),
                                  ),
                                )),
                            SizedBox(height: screenHeight / 70),
                            Container(
                              height: 48.0,
                              margin: EdgeInsets.only(bottom: 5.0),
                              child: DropdownSearch<String?>(
                                items: opportunityBloc.stageObjforDropDown,
                                onChanged: print,
                                onSaved: (selection) {
                                  if (selection == null) {
                                    opportunityBloc
                                        .currentEditOpportunity['stage'] = "";
                                  } else {
                                    opportunityBloc
                                            .currentEditOpportunity['stage'] =
                                        selection;
                                  }
                                },
                                selectedItem: opportunityBloc
                                    .currentEditOpportunity['stage'],
                                popupProps: PopupProps.bottomSheet(
                                  itemBuilder: (context, item, isSelected) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 10.0),
                                      child: Text(item!,
                                          style: TextStyle(
                                              fontSize: screenWidth / 22)),
                                    );
                                  },
                                  constraints: BoxConstraints(maxHeight: 400),
                                  searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                    border: boxBorder(),
                                    enabledBorder: boxBorder(),
                                    focusedErrorBorder: boxBorder(),
                                    focusedBorder: boxBorder(),
                                    errorBorder: boxBorder(),
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: "Search a Stage",
                                  )),
                                  showSearchBox: true,
                                  showSelectedItems: false,
                                ),
                              ),
                            )
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Assigned to",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54),
                            ),
                            SizedBox(height: screenHeight / 70),
                            Container(
                                child: MultiSelectFormField(
                                    border: boxBorder(),
                                    fillColor: Colors.white,
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Please select one or more options';
                                      }
                                      return null;
                                    },
                                    dataSource: userBloc.usersObjForDropdown,
                                    textField: 'name',
                                    valueField: 'id',
                                    okButtonLabel: 'OK',
                                    chipLabelStyle:
                                        TextStyle(color: Colors.black),
                                    cancelButtonLabel: 'CANCEL',
                                    // required: true,
                                    hintWidget: Text(
                                      "Please choose one or more",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    title: Text(
                                      "Users",
                                    ),
                                    initialValue: opportunityBloc
                                        .currentEditOpportunity['assigned_to'],
                                    onSaved: (value) {
                                      if (value == null) return;
                                      opportunityBloc.currentEditOpportunity[
                                          'assigned_to'] = value;
                                    }))
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(bottom: 5.0),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Contacts ',
                                    style: buildLableTextStyle(),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: screenWidth / 25,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                )),
                            SizedBox(height: screenHeight / 70),
                            Container(
                              child: MultiSelectFormField(
                                border: boxBorder(),
                                fillColor: Colors.white,
                                dataSource: contactBloc.contactsObjForDropdown,
                                textField: 'name',
                                valueField: 'id',
                                okButtonLabel: 'OK',
                                chipLabelStyle: TextStyle(color: Colors.black),
                                cancelButtonLabel: 'CANCEL',
                                hintWidget: Text(
                                  "Please choose one or more",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                title: Text(
                                  "Contacts",
                                ),
                                initialValue: opportunityBloc
                                    .currentEditOpportunity['contacts'],
                                onSaved: (value) {
                                  if (value == null) return;
                                  opportunityBloc
                                          .currentEditOpportunity['contacts'] =
                                      value;
                                },
                              ),
                            ),
                          ])),
                  Container(
                      padding: padding(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Due Date ",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54),
                            ),
                            SizedBox(height: screenHeight / 70),
                            Container(
                              width: screenWidth * 0.92,
                              child: TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                decoration: new InputDecoration(
                                  contentPadding: new EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 10.0),
                                  enabledBorder: buildBorder(Colors.black54),
                                  focusedErrorBorder:
                                      buildBorder(Colors.black54),
                                  focusedBorder: buildBorder(Colors.black54),
                                  errorBorder: buildBorder(Colors.black54),
                                  border: buildBorder(Colors.black54),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      _selectDate(context);
                                    },
                                    icon: Icon(Icons.calendar_today_outlined),
                                  ),
                                ),
                                // keyboardType: TextInputType.text
                              ),
                            ),
                          ])),
                  // Container(
                  //     padding: padding(),
                  //     child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             "Tags",
                  //             style: buildLableTextStyle(),
                  //           ),
                  //           SizedBox(height: screenHeight / 70),
                  //           Container(
                  //             width: screenWidth * 0.92,
                  //             margin: EdgeInsets.only(bottom: 5.0),
                  //             child: TextFieldTags(
                  //               initialTags: opportunityBloc.tags,
                  //               textFieldStyler: TextFieldStyler(
                  //                 textFieldBorder: boxBorder(),
                  //                 textFieldFocusedBorder: boxBorder(),
                  //                 hintText: 'Enter Tags',
                  //                 hintStyle: TextStyle(fontSize: 16.0),
                  //                 helperText: "",
                  //               ),
                  //               tagsStyler: TagsStyler(
                  //                   tagTextPadding:
                  //                       EdgeInsets.symmetric(horizontal: 5.0),
                  //                   tagDecoration: BoxDecoration(
                  //                     color: Colors.lightGreen[300],
                  //                     borderRadius: BorderRadius.circular(0.0),
                  //                   ),
                  //                   tagCancelIcon: Icon(Icons.cancel,
                  //                       size: 18.0, color: Colors.green[900]),
                  //                   tagPadding: const EdgeInsets.all(6.0)),
                  //               onTag: (tag) {
                  //                 setState(() {
                  //                   opportunityBloc
                  //                       .currentEditOpportunity['tags']
                  //                       .add(tag);
                  //                 });
                  //               },
                  //               onDelete: (tag) {
                  //                 setState(() {
                  //                   opportunityBloc
                  //                       .currentEditOpportunity['tags']
                  //                       .remove(tag);
                  //                 });
                  //               },
                  //             ),
                  //           ),
                  //         ])),
                ])))));
  }

  Widget buildDescriptionBlock() {
    return Container(
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Column(
          children: [
            quill.QuillToolbar.basic(
              controller: _controller,
              showAlignmentButtons: true,
              showBackgroundColorButton: false,
              showCameraButton: false,
              showImageButton: false,
              showVideoButton: false,
              showDividers: false,
              showColorButton: false,
              showUndo: false,
              showRedo: false,
              showQuote: false,
              showClearFormat: false,
              showIndent: false,
              showLink: false,
              showCodeBlock: false,
              showInlineCode: false,
              showListCheck: false,
              showJustifyAlignment: false,
              showHeaderStyle: false,
            ),
            Expanded(
              child: Container(
                child: quill.QuillEditor.basic(
                    controller: _controller,
                    readOnly: !_isLoading ? false : true),
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(73, 128, 255, 1.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(children: [
                        GestureDetector(
                            child: new Icon(Icons.arrow_back_ios,
                                size: screenWidth / 18, color: Colors.white),
                            onTap: () {
                              dashboardBloc.fetchDashboardDetails();
                              opportunityBloc.cancelCurrentEditOpportunity();
                              opportunityBloc.currentEditOpportunityId = "";
                              Navigator.pop(context, true);
                            }),
                        SizedBox(width: 10.0),
                        Text(
                          opportunityBloc.currentEditOpportunityId == ""
                              ? 'Add Opportunity'
                              : "Edit Opportunity",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth / 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_opportunityFormKey.currentState != null)
                          _opportunityFormKey.currentState!.save();
                        FocusScope.of(context).unfocus();
                        // opportunityBloc.currentEditOpportunity['description'] =
                        //     _controller.document.toPlainText();
                        print(opportunityBloc
                            .currentEditOpportunity['description']);
                        if (!_isLoading) _submitForm();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                          color: Colors.white,
                        ),
                        width: screenWidth * 0.18,
                        height: screenHeight * 0.04,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.check,
                                color: Theme.of(context).primaryColor,
                                size: screenWidth / 18),
                            Container(
                              child: Text(
                                "Save",
                                style: TextStyle(
                                    fontSize: screenWidth / 25,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              !_isLoading
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 23.0),
                      height: screenHeight * 0.06,
                      decoration: BoxDecoration(
                        color: bottomNavBarSelectedTextColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentTabIndex = 0;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: screenHeight * 0.06,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                color: Colors.white,
                                width: _currentTabIndex == 0 ? 3.0 : 0.0,
                              ))),
                              width: screenWidth * 0.22,
                              child: Text(
                                'Opportunity',
                                style: TextStyle(
                                    color: _currentTabIndex == 0
                                        ? Colors.white
                                        : Theme.of(context)
                                            .secondaryHeaderColor,
                                    fontSize: screenWidth / 25,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_opportunityFormKey.currentState != null)
                                _opportunityFormKey.currentState!.save();
                              setState(() {
                                _currentTabIndex = 1;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: screenHeight * 0.06,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                color: Colors.white,
                                width: _currentTabIndex == 1 ? 3.0 : 0.0,
                              ))),
                              width: screenWidth * 0.25,
                              child: Text(
                                'Description',
                                style: TextStyle(
                                    color: _currentTabIndex == 1
                                        ? Colors.white
                                        : Theme.of(context)
                                            .secondaryHeaderColor,
                                    fontSize: screenWidth / 25,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              Expanded(
                  child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.white,
                    child: buildTopBar(),
                  ),
                  new Align(
                    child: _isLoading
                        ? Container(
                            color: Colors.white,
                            width: screenWidth,
                            height: screenHeight * 0.9,
                            child: new Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: new Center(
                                    child: new CircularProgressIndicator())),
                          )
                        : Container(),
                    alignment: FractionalOffset.center,
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  _submitForm() async {
    setState(() {
      _errors = {};
      _isLoading = true;
    });
    _currentTabIndex = 0;
    await Future.delayed(const Duration(seconds: 1), () async {});
    if (_opportunityFormKey.currentState != null) {
      if (!_opportunityFormKey.currentState!.validate()) {
        setState(() {
          _isLoading = false;
        });
        showToaster('⚠ Please enter required fields.', context);
        return;
      }
      _opportunityFormKey.currentState!.save();
      await Future.delayed(const Duration(seconds: 1), () async {});

      Map _result = {};
      if (opportunityBloc.currentEditOpportunityId != null &&
          opportunityBloc.currentEditOpportunityId != "") {
        _result = await opportunityBloc.editOpportunity();
      } else {
        _result = await opportunityBloc.createOpportunity(file: file);
      }
      setState(() {
        _isLoading = false;
      });
      if (_result['error'] == false) {
        setState(() {
          _errors = {};
        });
        opportunityBloc.cancelCurrentEditOpportunity();
        opportunityBloc.currentEditOpportunityId = "";
        showToaster(_result['message'], context);
        opportunityBloc.opportunities.clear();
        opportunityBloc.offset = "";
        await opportunityBloc.fetchOpportunities();
        opportunityBloc.opportunities;
        await FirebaseAnalytics.instance.logEvent(name: "Opportunity_Created");
        Navigator.pushReplacementNamed(context, '/opportunities_list');
      } else if (_result['error'] == true) {
        setState(() {
          _errors = _result['errors'];
        });
        for (var key in _opportunityFormKeys) {
          if (_errors.containsKey(key)) {
            setState(() {
              _currentTabIndex = 0;
            });
            showToaster(_errors[key][0], context);
            return;
          }
        }
      } else {
        setState(() {
          _errors = {};
        });
        showErrorMessage(context, _result['message'].toString());
      }
    }
  }

  showErrorMessage(BuildContext context, msg) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Alert'),
              content: Text(msg),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitForm();
                    },
                    child: Text('RETRY'))
              ],
            ));
  }
}

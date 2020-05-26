import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zendeskchat/constant/common.dart';
import 'package:zendeskchat/constant/zendesk_constant.dart';
import 'package:zendeskchat/model/base.dart';
import 'package:zendeskchat/util/app_colors.dart';
import 'package:zendeskchat/views/chat/chat.dart';
import 'package:zendeskchat/widget/spacer.dart';
import 'package:zendeskchat/widget/text_input_widget.dart';

class DashboardScreen extends StatefulWidget {
  static const route = '/dashboard';
  static const String appBarTitle = 'Simulasi Chat Zendesk';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  BaseModel selectedDepartment;

  final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  void initState() {
    super.initState();

    nameController.text = 'Vincent';
    phoneNumberController.text = '085218811296';
    emailController.text = 'good@day.sir';
    selectedDepartment = ZendeskConstant.departmentDropDown.elementAt(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DashboardScreen.appBarTitle,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: AppColors.offWhite),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: <Widget>[
            TextInputWidgetCustom(
                context: context,
                controller: nameController,
                label: CommonConstant.name,
                onSubmitted: (String _) {
                  FocusScope.of(context).requestFocus(emailFocusNode);
                },
                focusNode: nameFocusNode),
            SpacerVerticalSmall(),
            TextInputWidgetCustom(
                context: context,
                controller: emailController,
                label: CommonConstant.email,
                onSubmitted: (String _) {
                  FocusScope.of(context).requestFocus(phoneNumberFocusNode);
                },
                textInputType: TextInputType.emailAddress,
                focusNode: emailFocusNode),
            SpacerVerticalSmall(),
            TextInputWidgetCustom(
                context: context,
                controller: phoneNumberController,
                label: CommonConstant.phoneNumber,
                textInputType: TextInputType.phone,
                focusNode: phoneNumberFocusNode),
            SpacerVerticalMedium(),
            DropdownButtonHideUnderline(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: selectedDepartment != null ? 2 : 1,
                            color: selectedDepartment != null
                                ? AppColors.primaryColor
                                : AppColors.gray))),
                child: DropdownButton<BaseModel>(
                  value: selectedDepartment,
                  hint: const Text('Select item'),
                  onChanged: (value) {
                    setState(() {
                      selectedDepartment = value;
                    });
                  },
                  items: ZendeskConstant.departmentDropDown
                      .map((element) => DropdownMenuItem<BaseModel>(
                            value: element,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                element.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                      textBaseline: TextBaseline.alphabetic,
                                    ),
                              ),
                            ),
                          ))
                      .toList(),
                  isExpanded: true,
                ),
              ),
            ),
            SpacerVerticalBig(),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () {
                  if (validate()) {
                    Get.toNamed<dynamic>(ChatScreen.route,
                        arguments: selectedDepartment);
                  } else {
                    Get.snackbar(
                      'Error!', // title
                      'Mohon Periksa data ', // message
                      icon: Icon(Icons.error),
                      backgroundColor: AppColors.red,
                      shouldIconPulse: true,
                      barBlur: 20,
                      isDismissible: true,
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
                child: Text(CommonConstant.submit),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool validate() {
    if (nameController.text == null || nameController.text.isEmpty) {
      return false;
    }

    if (emailController.text == null ||
        emailController.text.isEmpty ||
        emailRegex.hasMatch(emailController.text) == false) {
      return false;
    }

    if (phoneNumberController.text == null ||
        phoneNumberController.text.isEmpty) {
      return false;
    }

    if (selectedDepartment == null) {
      return false;
    }

    return true;
  }
}

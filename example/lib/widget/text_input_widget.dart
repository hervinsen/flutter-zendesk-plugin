import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:zendeskchat/util/app_colors.dart';

Widget TextInputWidgetCustom({
  @required BuildContext context,
  @required TextEditingController controller,
  @required String label,
  FocusNode focusNode,
  TextInputType textInputType = TextInputType.text,
  TextCapitalization textCapitalization = TextCapitalization.sentences,
  TextInputAction textInputAction = TextInputAction.next,
  Function onSubmitted,
}) {
  return TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: textInputType,
    textInputAction: textInputAction,
    textCapitalization: textCapitalization,
    onSubmitted: onSubmitted,
    decoration: InputDecoration(
        border: UnderlineInputBorder(
            borderSide: BorderSide(width: 1, color: AppColors.gray)),
        labelText: label.toUpperCase(),
        hintText: 'Masukan $label',
        labelStyle: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: AppColors.seaGreen)),
  );
}

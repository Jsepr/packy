import 'package:flutter/material.dart';

class TextInputForm extends StatefulWidget {
  const TextInputForm(
      {super.key,
      required this.onSuccess,
      required this.header,
      required this.hintText,
      required this.errorText,
      required this.submitButtonText});

  final String header;
  final String hintText;
  final String errorText;
  final String submitButtonText;
  final void Function(String value) onSuccess;

  @override
  State<StatefulWidget> createState() {
    return TextInputFormState();
  }
}

class TextInputFormState extends State<TextInputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();

  onSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSuccess(titleController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(widget.header),
          TextFormField(
            autofocus: true,
            controller: titleController,
            decoration: InputDecoration(hintText: widget.hintText),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return widget.errorText;
              }
              return null;
            },
            onFieldSubmitted: (value) => onSubmit(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: onSubmit,
              child: Text(widget.submitButtonText),
            ),
          ),
        ],
      ),
    );
  }
}

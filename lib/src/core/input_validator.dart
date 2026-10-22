import 'package:flutter/widgets.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class InputValidator {
  InputValidator._();

  static FormFieldValidator<dynamic> _isRequired(String fieldName) {
    return FormBuilderValidators.required(errorText: '$fieldName is required');
  }

  static String? checkEmail(String? email) {
    return FormBuilderValidators.compose([
      _isRequired('Email'),
      FormBuilderValidators.email(),
    ])(email);
  }

  static String? checkPassword(String? password) {
    return FormBuilderValidators.compose([
      _isRequired('Password'),
      FormBuilderValidators.minLength(8),
    ])(password);
  }

  static String? checkConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    return FormBuilderValidators.compose([
      _isRequired('Confirm password'),
      FormBuilderValidators.equal(
        password ?? '',
        errorText: 'Passwords do not match!',
      ),
    ])(confirmPassword);
  }

  static String? checkName(String? name) {
    return _isRequired('Name')(name);
  }

  static String? checkPhone(String? phone) {
    return _isRequired('Phone')(phone);
  }
}

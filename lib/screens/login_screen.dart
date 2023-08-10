import 'package:flutter/material.dart';
import 'package:interactive_login/utils/constants.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  var _errorMessage = '';
  var _successMessage = '';
  var _isLoading = false;

  SMIInput<double>? _numLookValue;
  SMIInput<bool>? _isChecking;
  SMIInput<bool>? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFailure;

  void _onInit(Artboard art) {
    var ctrl = StateMachineController.fromArtboard(art, ksStateMachineName);

    if (ctrl != null) {
      ctrl.isActive = false;
      art.addController(ctrl);

      _numLookValue = ctrl.findInput<double>(ksNumLookInput);
      _isChecking = ctrl.findInput<bool>(ksCheckInput);
      _isHandsUp = ctrl.findInput<bool>(ksRaiseHandInput);
      _trigSuccess = ctrl.findSMI<SMITrigger>(ksTrigSuccessInput);
      _trigFailure = ctrl.findSMI<SMITrigger>(ksTrigFailInput);

      _triggerSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _updateCheckingState(false);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                _riveAnimationBuilder(),
                const SizedBox(
                  height: 50.0,
                ),
                _containerBuilder(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _riveAnimationBuilder() {
    return SizedBox(
      height: 300.0,
      child: RiveAnimation.asset(
        'assets/rive/teddy_animation.riv',
        fit: BoxFit.cover,
        onInit: _onInit,
      ),
    );
  }

  Widget _containerBuilder() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _inputBuilder(
            controller: _userNameController,
            hintText: 'Enter your username',
            onPressed: () {
              _updateCheckingState(true);
              _updateHandsUpState(false);
            },
            onChanged: _handleTextChange,
          ),
          const SizedBox(
            height: 10.0,
          ),
          _inputBuilder(
            controller: _passwordController,
            hintText: 'Enter your password',
            password: true,
            onPressed: () => _updateHandsUpState(true),
          ),
          const SizedBox(
            height: 15.0,
          ),
          _buttonBuilder(),
          const SizedBox(
            height: 10.0,
          ),
          _errorBuilder(),
          _successBuilder(),
          const SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget _inputBuilder({
    required final TextEditingController controller,
    required final String hintText,
    final bool password = false,
    final Function()? onPressed,
    final Function(String)? onChanged,
  }) {
    return TextFormField(
      obscureText: password,
      onTap: onPressed,
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 1.0,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 1.0,
            color: Colors.grey.withOpacity(0.9),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 1.0,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
      ),
    );
  }

  Widget _buttonBuilder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                _updateHandsUpState(false);
                _updateCheckingState(false);
                setState(() {
                  _isLoading = true;
                });
                Future.delayed(const Duration(milliseconds: 3000), () {
                  if (_userNameController.text.trim() == 'shrijanRegmi' &&
                      _passwordController.text.trim() == '123456') {
                    _triggerSuccess();
                    setState(() {
                      _successMessage = 'Successfully logged in!';
                      _errorMessage = '';
                    });
                  } else {
                    _triggerFailure();
                    setState(() {
                      _errorMessage =
                          'Invalid username or password. Use shrijanRegmi as username and 123456 as password.';
                      _successMessage = '';
                    });
                  }
                  setState(() {
                    _isLoading = false;
                  });
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(12.0),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 1.0,
                      ),
                    )
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBuilder() {
    return Text(
      _errorMessage,
      style: const TextStyle(
        color: Colors.red,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _successBuilder() {
    return Text(
      _successMessage,
      style: const TextStyle(
        color: Colors.green,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _handleTextChange(final String val) {
    _numLookValue?.value = val.length * 2;
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }
    if (_successMessage.isNotEmpty) {
      setState(() {
        _successMessage = '';
      });
    }
  }

  void _updateCheckingState(final bool isChecking) {
    _isChecking?.value = isChecking;
  }

  void _updateHandsUpState(final bool isHandsUp) {
    _isHandsUp?.value = isHandsUp;
  }

  void _triggerSuccess() {
    _trigSuccess?.fire();
  }

  void _triggerFailure() {
    _trigFailure?.fire();
  }
}

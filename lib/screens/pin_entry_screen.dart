import 'package:expensero/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validatePin() {
    const storedPin = '2048';
    final enteredPin = _controller.text;

    if (enteredPin == storedPin) {
      Provider.of<AuthState>(context, listen: false).authenticate();
    } else {
      _controller.clear();
      _focusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid PIN. Please try again.'),
          duration: Duration(milliseconds: 1000),
          backgroundColor: Color.fromARGB(255, 79, 86, 99),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 167, 178, 204),
              Color.fromARGB(255, 50, 56, 65)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 44),
                          const Text(
                            'Enter PIN',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 28),
                          PinInput(
                            controller: _controller,
                            focusNode: _focusNode,
                            onCompleted: _validatePin,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Expensero',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PinInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onCompleted;

  const PinInput({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        maxLength: 4,
        obscureText: true,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, color: Colors.white, letterSpacing: 10),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
          ),
          hintText: '● ● ● ●',
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 20,
              letterSpacing: 2),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        onChanged: (value) {
          if (value.length == 4) {
            onCompleted();
          }
        },
      ),
    );
  }
}

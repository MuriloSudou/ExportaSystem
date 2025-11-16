
import 'package:exportasystem/controllers/authController.dart';
import 'package:exportasystem/controllers/userController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final AuthController controller = Get.put(AuthController());
  final UserController userController = Get.put(UserController());

  bool _isLoading = false;
  
 
  bool _obscure = true;


  static const corPrincipal = Color(0xFF1E88E5);
  static const background = Color(0xFFF5F7FA);
  static const corTexto = Color(0xFF37474F);
  final corDica = Colors.grey.shade600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
              Image.asset("assets/images/logo.png", height: 150), 
              const SizedBox(height: 50),
              
              
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      
                      TextFormField(
                        controller: controller.emailController,
                        style: TextStyle(
                          color: corTexto,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          "Email",
                          "seu.email@exemplo.com",
                          Icons.email_outlined,
                        ),
                       
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu e-mail';
                          } else if (!GetUtils.isEmail(value)) {
                            return 'Formato de e-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      
                      TextFormField(
                        controller: controller.passwordController,
                        style: TextStyle(
                          color: corTexto,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          "Senha",
                          "Digite sua senha",
                          Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              color: corPrincipal,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscure,
                      
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          } else if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      
                      
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: _buildButtonStyle(),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: _isLoading
                              ? _buildLoadingIndicator()
                              : const Text(
                                  "Entrar",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Não tem conta?",
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              "Cadastre-se!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: corPrincipal, 
                              ),
                            ),
                          ),
                        ],
                      ),
                      

                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("ou"),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : controller.loginWithGoogle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: corTexto,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/icons/google.png', 
                          height: 20,
                        ),
                        label: const Text('Fazer login com o Google'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool success = await controller.loginWithEmailAndPassword();

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Erro no Login',
          'E-mail ou senha incorretos',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }


  InputDecoration _buildInputDecoration(
      String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: corDica),
      hintText: hint,
      hintStyle: TextStyle(color: corDica),
      prefixIcon: Icon(icon, color: corPrincipal),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: corPrincipal,
          width: 2.0,
        ),
      ),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: corPrincipal,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  SizedBox _buildLoadingIndicator() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }
}

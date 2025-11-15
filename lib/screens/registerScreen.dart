import 'package:exportasystem/const/hashedPassword.dart';
import 'package:exportasystem/controllers/userController.dart';
import 'package:exportasystem/controllers/authController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores do seu arquivo original
  final UserController controller = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  // Estado do seu arquivo original
  bool _acceptContact = false;
  
  // Estado de loading (baseado no novo design)
  bool _isLoading = false;
  
  // Estado do novo design
  bool _obscure = true;

  // Cores do novo design
  static const corPrincipal = Color(0xFF1E88E5);
  static const background = Color(0xFFF5F7FA);
  static const corTexto = Color(0xFF37474F);
  final corDica = Colors.grey.shade600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      // AppBar do seu arquivo original
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background, // Combinando com o fundo
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Imagem do novo design
              Image.asset("assets/images/logo.png", height: 100), // Um pouco menor
              const SizedBox(height: 30),
              
              // Card do novo design
              Container(
                // SEM altura fixa, para caber todos os campos
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
                      // Campo de Nome (Lógica original + Design novo)
                      TextFormField(
                        controller: controller.nameController,
                        style: TextStyle(color: corTexto, fontWeight: FontWeight.w500),
                        decoration: _buildInputDecoration("Nome", "Seu nome", Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Campo de Sobrenome (Lógica original + Design novo)
                      TextFormField(
                        controller: controller.lastnameController,
                        style: TextStyle(color: corTexto, fontWeight: FontWeight.w500),
                        decoration: _buildInputDecoration("Sobrenome", "Seu sobrenome", Icons.person_outline),
                        // Sem validador no original
                      ),
                      const SizedBox(height: 20),
                      
                      // Campo de Email (Lógica original + Design novo)
                      TextFormField(
                        controller: controller.emailController,
                        style: TextStyle(color: corTexto, fontWeight: FontWeight.w500),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration("Email", "seu.email@exemplo.com", Icons.email_outlined),
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
                      
                      // Campo de Senha (Lógica original + Design novo)
                      TextFormField(
                        controller: controller.passwordController,
                        style: TextStyle(color: corTexto, fontWeight: FontWeight.w500),
                        decoration: _buildInputDecoration("Senha", "Digite sua senha", Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: corPrincipal),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        obscureText: _obscure,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira uma senha';
                          } else if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Campo de Telefone (Lógica original + Design novo)
                      TextFormField(
                        controller: controller.numberController,
                        style: TextStyle(color: corTexto, fontWeight: FontWeight.w500),
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration("Telefone", "55 9...", Icons.phone_outlined),
                        // Sem validador no original
                      ),
                      const SizedBox(height: 20),
                      
                      // Checkbox (Do seu arquivo original)
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptContact,
                            activeColor: corPrincipal,
                            onChanged: (value) {
                              setState(() {
                                _acceptContact = value!;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Aceito que entrem em contato comigo por SMS e WhatsApp.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Botão Continuar (Design novo + Lógica original)
                      ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: _buildButtonStyle(),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: _isLoading
                              ? _buildLoadingIndicator()
                              : const Text(
                                  "Continuar", // Texto do seu original
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Navegação "Já tem conta?"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Já tem conta?",
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navegação para voltar
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              "Entre aqui!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: corPrincipal,
                              ),
                            ),
                          ),
                        ],
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

  // Função _registerUser do seu arquivo original (com adição de _isLoading)
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Inicia o loading
      });

      final name = controller.nameController.text.trim();
      final email = controller.emailController.text.trim().toLowerCase();
      final lastname = controller.lastnameController.text.trim();
      final password = controller.passwordController.text.trim();
      final number = controller.numberController.text.trim();

      try {
        final hashedPassword = hashPassword(password.trim());
        final success = await controller.insertUser(name, email, lastname, hashedPassword, number);

        if (success > 0) {
          final user = await authController.getUserByEmail(email);

          if (user != null && mounted) {
            await authController.saveUserSession(user);
            print('Usuário logado e sessão salva: ${user.toMap()}');
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            _showSnackbar('Falha no login após o registro.');
          }
        } else {
          _showSnackbar('Falha no registro');
        }
      } catch (error) {
        _showSnackbar('Erro: $error');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Termina o loading
          });
        }
      }
    }
  }

  // Função _showSnackbar do seu arquivo original
  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // Função dispose do seu arquivo original
  @override
  void dispose() {
    controller.nameController.dispose();
    controller.emailController.dispose();
    controller.passwordController.dispose();
    controller.lastnameController.dispose();
    controller.numberController.dispose();
    super.dispose();
  }

  // --- Funções de UI do novo design ---

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

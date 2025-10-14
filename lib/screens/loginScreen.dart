import 'package:exportasystem/controllers/authController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUp = false;
  bool _obscure = true;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  final AuthController _auth = Get.put(AuthController());

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  
  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Informe o e-mail';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
    if (!ok) return 'E-mail inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validateName(String? v) {
    if (!isSignUp) return null;
    final value = v?.trim() ?? '';
    if (value.length < 2) return 'Informe seu nome';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();

    if (isSignUp) {
      await _auth.registerEmail(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } else {
      await _auth.loginEmail(_emailCtrl.text.trim(), _passCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    const corPrincipal = Color(0xFF1E88E5);
    const background = Color(0xFFF5F7FA);
    const corTexto = Color(0xFF37474F);
    final corDica = Colors.grey.shade600;

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/images/logo.png", height: 120), 
              const SizedBox(height: 40),
              Container(
                width: double.infinity, 
                constraints: const BoxConstraints(maxWidth: 400), 
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Obx(
                  () => Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          isSignUp ? 'Criar Conta' : 'Bem-vindo de Volta!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: corTexto,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSignUp ? 'Preencha os dados para se cadastrar' : 'Faça login para continuar',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: corDica, fontSize: 16),
                        ),
                        const SizedBox(height: 24),

                        if (_auth.errorMessage.value != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _auth.errorMessage.value!,
                                    style: const TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        if (isSignUp) ...[
                          TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: corTexto, fontWeight: FontWeight.w500),
                            decoration: _buildInputDecoration(
                              labelText: "Nome Completo",
                              hintText: "Digite seu nome",
                              icon: Icons.person_outline,
                              corPrincipal: corPrincipal,
                              corDica: corDica,
                            ),
                            validator: _validateName,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                        ],

                        TextFormField(
                          controller: _emailCtrl,
                          style: const TextStyle(color: corTexto, fontWeight: FontWeight.w500),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInputDecoration(
                            labelText: "Email",
                            hintText: "seu.email@exemplo.com",
                            icon: Icons.email_outlined,
                            corPrincipal: corPrincipal,
                            corDica: corDica,
                          ),
                          validator: _validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passCtrl,
                          style: const TextStyle(color: corTexto, fontWeight: FontWeight.w500),
                          obscureText: _obscure,
                          decoration: _buildInputDecoration(
                            labelText: "Senha",
                            hintText: "Digite sua senha",
                            icon: Icons.lock_outline,
                            corPrincipal: corPrincipal,
                            corDica: corDica,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_off : Icons.visibility,
                                color: corPrincipal,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: _validatePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 32),

                        ElevatedButton(
                          onPressed: _auth.isLoading.value ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: corPrincipal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: corPrincipal.withOpacity(0.4),
                          ),
                          child: _auth.isLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  isSignUp ? "CADASTRAR" : "ENTRAR",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isSignUp ? "Já tem uma conta?" : "Não tem conta?",
                              style: TextStyle(fontSize: 15, color: corDica),
                            ),
                            TextButton(
                              onPressed: _auth.isLoading.value
                                    ? null
                                    : () {
                                        setState(() => isSignUp = !isSignUp);
                                        _auth.errorMessage.value = null; 
                                      },
                              child: Text(
                                isSignUp ? "Faça Login" : "Cadastre-se!",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: corPrincipal,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                            Row(
                              children: const [
                                Expanded(child: Divider(thickness: 1)),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  child: Text("ou"),
                                ),
                                Expanded(child: Divider(thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 18),
                          
                           SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed:
                                    _auth.isLoading.value ? null : _auth.loginGoogle,
                                icon: Image.asset(
                                  'assets/icons/google.png',
                                  height: 20,
                                ),
                                label: const Text('Entrar com Google'),
                              ),
                            ),
                            
                            
                            
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    required Color corPrincipal,
    required Color corDica,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: corDica),
      hintText: hintText,
      hintStyle: TextStyle(color: corDica.withOpacity(0.8)),
      prefixIcon: Icon(icon, color: corPrincipal),
      filled: true,
      fillColor: const Color(0xFFF5F7FA), 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: corPrincipal, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2.0),
      ),
    );
  }
}

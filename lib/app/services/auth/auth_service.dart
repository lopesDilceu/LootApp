import 'package:firebase_auth/firebase_auth.dart' as fb; // Renomeado para evitar conflito com seu User
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/user_model.dart'; // Seu modelo User
import 'package:loot_app/app/routes/app_routes.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<User> currentUser = Rxn<User>();
  final Rxn<fb.User> firebaseUser = Rxn<fb.User>();
  final RxBool isAuthenticated = false.obs;

  bool get isLoggedIn => isAuthenticated.value;

  Future<AuthService> init() async {
    // Ouve as mudanças no estado de autenticação do Firebase
    _firebaseAuth.authStateChanges().listen((fb.User? user) async {
      if (user == null) {
        print('[AuthService] Usuário deslogado.');
        currentUser.value = null;
        firebaseUser.value = null;
        isAuthenticated.value = false;
      } else {
        print('[AuthService] Usuário logado: ${user.uid}');
        firebaseUser.value = user;
        // Após logar, busca os dados do perfil no Firestore
        await _fetchUserProfile(user.uid);
        isAuthenticated.value = true;
      }
    });
    return this;
  }

  // Busca os dados do perfil do usuário no Firestore
  Future<void> _fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        // Assume que seu UserModel tem um construtor fromJson
        currentUser.value = User.fromJson(userDoc.data() as Map<String, dynamic>);
      } else {
        print("[AuthService] Documento do usuário não encontrado no Firestore para UID: $uid");
        // Pode indicar um erro onde o usuário foi criado no Auth mas não no Firestore.
      }
    } catch (e) {
      print("[AuthService] Erro ao buscar perfil do Firestore: $e");
    }
  }

  // --- Novos Métodos de Autenticação ---

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      // O listener authStateChanges já vai cuidar de atualizar o estado do app
      return true;
    } on fb.FirebaseAuthException catch (e) {
      Get.snackbar("Erro de Login", e.message ?? "Ocorreu um erro.", snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> registerWithEmail(String firstName, String lastName, String email, String password) async {
    try {
      // 1. Cria o usuário no Firebase Auth
      fb.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      
      if (userCredential.user != null) {
        // 2. Cria o documento do usuário no Firestore
        User newUser = User(
          id: userCredential.user!.uid, // Usa o UID do Firebase Auth como ID
          firstName: firstName,
          lastName: lastName,
          email: email,
          role: Role.user, // Ou o role padrão que você definir
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
        // O listener authStateChanges cuidará do resto
        return true;
      }
      return false;
    } on fb.FirebaseAuthException catch (e) {
      Get.snackbar("Erro de Cadastro", e.message ?? "Ocorreu um erro.", snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    // O listener authStateChanges já vai limpar o estado e redirecionar
  }
}
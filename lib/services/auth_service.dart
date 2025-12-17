import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as MyModel; // Alias pour votre User personnalisé

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Convertir Firebase User en User personnalisé
  MyModel.User _userFromFirebaseUser(User user) {
    return MyModel.User(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? user.email!.split('@')[0],
      role: 'user',
    );
  }

  // Connexion
  Future<MyModel.User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return MyModel.User.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        MyModel.User newUser = MyModel.User(
          id: user.uid,
          email: user.email!,
          name: user.email!.split('@')[0],
          role: 'user',
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      return null;
    }
  }

  // Inscription
  Future<MyModel.User?> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;

      MyModel.User newUser = MyModel.User(
        id: user.uid,
        email: email,
        name: name,
        role: 'user',
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      return newUser;
    } catch (e) {
      print('Erreur d\'inscription: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Vérifier l'état de l'utilisateur
  Stream<MyModel.User?> get user {
    return _auth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser == null) return null;

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        return MyModel.User.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}

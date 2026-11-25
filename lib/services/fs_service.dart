import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class FsService {
  Stream<QuerySnapshot> publicaciones() {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> publicacion(String id) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .snapshots();
  }

  Future<List<String>> categorias() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('categoria')
        .orderBy('nombre')
        .get();
    return snapshot.docs.map((doc) => doc['nombre'] as String).toList();
  }

  Future<void> agregarPublicacion({
    required String titulo,
    required String descripcion,
    required String tipo,
    required String categoria,
    required String lugar,
    required DateTime fecha,
    required Uint8List foto,
    required String autorUid,
    required String autorNombre,
  }) {
    return FirebaseFirestore.instance.collection('publicaciones').doc().set({
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fecha': Timestamp.fromDate(fecha),
      'foto': Blob(foto),
      'estado': 'Vigente',
      'autorUid': autorUid,
      'autorNombre': autorNombre,
    });
  }

  Future<void> marcarDevuelto(String id) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .update({'estado': 'Devuelto'});
  }

  Future<void> borrarPublicacion(String id) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .delete();
  }
}

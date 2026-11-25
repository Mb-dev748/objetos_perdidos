import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/services/fs_service.dart';
import 'package:objetos_perdidos/utils/format_utils.dart';

class DetallePage extends StatefulWidget {
  final String publicacionId;
  const DetallePage({super.key, required this.publicacionId});

  @override
  State<DetallePage> createState() => _DetallePageState();
}

class _DetallePageState extends State<DetallePage> {
  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colores.primary,
        foregroundColor: colores.secondary,
        title: const Text('detalle'),
      ),
      body: FutureBuilder(
        future: FsService().publicacion(widget.publicacionId),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var publicacion = snapshot.data!;
          Blob foto = publicacion['foto'];
          Timestamp fecha = publicacion['fecha'];
          bool esAutor =
              publicacion['autorUid'] == FirebaseAuth.instance.currentUser!.uid;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Image.memory(foto.bytes),
              const SizedBox(height: 16),
              Text(
                publicacion['titulo'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(publicacion['descripcion']),
              const SizedBox(height: 8),
              Text('tipo: ${publicacion['tipo']}'),
              Text('categoria: ${publicacion['categoria']}'),
              Text('estado: ${publicacion['estado']}'),
              Text('lugar: ${publicacion['lugar']}'),
              Text('fecha: ${formatearFecha(fecha.toDate())}'),
              Text('publicado por: ${publicacion['autorNombre']}'),
              const SizedBox(height: 16),
              if (esAutor && publicacion['estado'] == 'Vigente')
                FilledButton(
                  onPressed: () {
                    FsService().marcarDevuelto(widget.publicacionId);
                    Navigator.pop(context);
                  },
                  child: const Text('marcar como devuelto'),
                ),
              if (esAutor)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('borrar publicacion'),
                          content: const Text('estas seguro?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('cancelar'),
                            ),
                            FilledButton(
                              onPressed: () {
                                FsService().borrarPublicacion(
                                  widget.publicacionId,
                                );
                                Navigator.pop(dialogContext);
                                Navigator.pop(context);
                              },
                              child: const Text('borrar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('borrar publicacion'),
                ),
            ],
          );
        },
      ),
    );
  }
}

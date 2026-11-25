import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/services/auth_service.dart';
import 'package:objetos_perdidos/pages/publicar_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:objetos_perdidos/services/fs_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  bool soloMias = false;

  @override
  void initState() {
    super.initState();
    AuthService().currentUser().then((currentU) {
      if (!mounted) return;
      setState(() {
        user = currentU;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colores.primary,
        foregroundColor: colores.secondary,
        title: Text(user?.displayName ?? 'Cargando...'),
        actions: [
          IconButton(
            onPressed: () => AuthService().cerrarSesion(),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesion',
          ),
        ],
      ),

      //la lista de publicacionbes --->
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('todas'),
                  selected: !soloMias,
                  onSelected: (_) {
                    setState(() {
                      soloMias = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('mis publicaciones'),
                  selected: soloMias,
                  onSelected: (_) {
                    setState(() {
                      soloMias = true;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FsService().publicaciones(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                //esto es solo xq no encuentro un error
                if (snapshot.hasError) {
                  return Text('error: ${snapshot.error}');
                }
                //-----------------------
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var publicaciones = snapshot.data!.docs;
                if (soloMias) {
                  publicaciones = publicaciones
                      .where((p) => p['autorUid'] == user?.uid)
                      .toList();
                }
                if (publicaciones.isEmpty) {
                  return const Center(child: Text('no hay publicaciones'));
                }
                return ListView.separated(
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemCount: publicaciones.length,
                  itemBuilder: (context, index) {
                    var publicacion = publicaciones[index];
                    Blob foto = publicacion['foto'];
                    bool devuelto = publicacion['estado'] == 'Devuelto';
                    return Opacity(
                      opacity: devuelto ? 0.5 : 1,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            foto.bytes,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          publicacion['titulo'],
                          style: TextStyle(
                            decoration: devuelto
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          '${publicacion['tipo']} - ${publicacion['categoria']}',
                        ),
                        trailing: Chip(
                          label: Text(publicacion['estado'].toString()),
                          backgroundColor: devuelto
                              ? colores.surfaceContainerHighest
                              : colores.secondary,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // boton publicar
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colores.secondary,
        foregroundColor: colores.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PublicarPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('publicar'),
      ),
    );
  }
}

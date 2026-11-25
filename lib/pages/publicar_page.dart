import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:objetos_perdidos/services/fs_service.dart';
import 'package:objetos_perdidos/utils/format_utils.dart';

class PublicarPage extends StatefulWidget {
  const PublicarPage({super.key});

  @override
  State<PublicarPage> createState() => _PublicarPageState();
}

class _PublicarPageState extends State<PublicarPage> {
  static const int maxBytesFoto = 900000;

  final formKey = GlobalKey<FormState>();
  final tituloCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();

  String? tipo;
  String? categoria;
  DateTime? fecha;
  Uint8List? foto;
  bool guardando = false;
  bool mostrarErrores = false;
  late Future<List<String>> categoriasFuture;

  @override
  void initState() {
    super.initState();
    categoriasFuture = FsService().categorias();
  }

  @override
  void dispose() {
    tituloCtrl.dispose();
    descripcionCtrl.dispose();
    lugarCtrl.dispose();
    super.dispose();
  }

  Future<void> elegirFoto(ImageSource origen) async {
    final archivo = await ImagePicker().pickImage(
      source: origen,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 75,
    );
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    if (!mounted) return;
    if (bytes.length > maxBytesFoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La foto es muy pesada, elige otra')),
      );
      return;
    }
    setState(() {
      foto = bytes;
    });
  }

  Future<void> elegirFecha() async {
    final ahora = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      initialDate: fecha ?? ahora,
      firstDate: DateTime(ahora.year - 1),
      lastDate: ahora,
    );
    if (dia == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fecha ?? ahora),
    );
    if (hora == null) return;
    setState(() {
      fecha = DateTime(dia.year, dia.month, dia.day, hora.hour, hora.minute);
    });
  }

  Future<void> publicar() async {
    final formOk = formKey.currentState!.validate();
    setState(() {
      mostrarErrores = true;
    });
    if (!formOk || foto == null || fecha == null || guardando) return;

    setState(() {
      guardando = true;
    });
    final user = FirebaseAuth.instance.currentUser!;
    try {
      await FsService().agregarPublicacion(
        titulo: tituloCtrl.text.trim(),
        descripcion: descripcionCtrl.text.trim(),
        tipo: tipo!,
        categoria: categoria!,
        lugar: lugarCtrl.text.trim(),
        fecha: fecha!,
        foto: foto!,
        autorUid: user.uid,
        autorNombre: user.displayName ?? 'Sin nombre',
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (ex) {
      if (!mounted) return;
      setState(() {
        guardando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo publicar, intenta de nuevo')),
      );
    }
  }

  String? validarTexto(String? valor, String mensaje) {
    if (valor == null || valor.trim().isEmpty) {
      return mensaje;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final estiloError = TextStyle(color: colores.error, fontSize: 12);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colores.primary,
        foregroundColor: colores.secondary,
        title: const Text('publicar el objeto'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: colores.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: foto != null
                  ? Image.memory(foto!, fit: BoxFit.cover)
                  : Icon(Icons.add_a_photo, size: 64, color: colores.primary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => elegirFoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('camara'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => elegirFoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('galeria'),
                  ),
                ),
              ],
            ),
            if (mostrarErrores && foto == null)
              Text('La foto es obligatoria', style: estiloError),
            const SizedBox(height: 16),

            TextFormField(
              controller: tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'titulo',
                hintText: 'ej: Audifonos bluetooth negros',
                border: OutlineInputBorder(),
              ),
              validator: (valor) => validarTexto(valor, 'indica un título'),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: descripcionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'descripcion',
                border: OutlineInputBorder(),
              ),
              validator: (valor) =>
                  validarTexto(valor, 'agrega una descripcion'),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'tipo',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Perdido', child: Text('perdido')),
                DropdownMenuItem(
                  value: 'Encontrado',
                  child: Text('encontrado'),
                ),
              ],
              onChanged: (valor) => tipo = valor,
              validator: (valor) => valor == null ? 'elige el tipo' : null,
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<String>>(
              future: categoriasFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: snapshot.data!
                      .map(
                        (nombre) => DropdownMenuItem(
                          value: nombre,
                          child: Text(nombre),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) => categoria = valor,
                  validator: (valor) =>
                      valor == null ? 'elige una categoria' : null,
                );
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: lugarCtrl,
              decoration: const InputDecoration(
                labelText: 'lugar del campus',
                hintText: 'ej; Laboratorio U100',
                border: OutlineInputBorder(),
              ),
              validator: (valor) => validarTexto(valor, 'indica el lugar'),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: elegirFecha,
              icon: const Icon(Icons.event),
              label: Text(
                fecha == null ? 'elegir fecha y hora' : formatearFecha(fecha!),
              ),
            ),
            if (mostrarErrores && fecha == null)
              Text('Indica la fecha y hora', style: estiloError),
            const SizedBox(height: 24),

            guardando
                ? const Center(child: CircularProgressIndicator())
                : FilledButton.icon(
                    onPressed: publicar,
                    icon: const Icon(Icons.send),
                    label: const Text('publicar'),
                  ),
          ],
        ),
      ),
    );
  }
}

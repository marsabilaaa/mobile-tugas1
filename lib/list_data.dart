import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:tugas1/side_menu.dart';
import 'package:tugas1/tambah_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tugas1/view_data.dart';

class ListData extends StatefulWidget {
  const ListData({super.key});
  @override
// ignore: library_private_types_in_public_api
  _ListDataState createState() => _ListDataState();
}

class _ListDataState extends State<ListData> {
  List<Map<String, String>> dataMahasiswa = [];
  String url = Platform.isAndroid
      ? 'http://10.0.2.2/pem_mob/index.php'
      : 'http://localhost/pem_mob/index.php';
  // String url = 'http://localhost/pem_mob/index.php';
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        dataMahasiswa = List<Map<String, String>>.from(data.map((item) {
          return {
            'nama': item['nama'] as String,
            'jurusan': item['jurusan'] as String,
            'id': item['id'] as String,
          };
        }));
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future editData(int id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$url?id=$id'),
      headers: {
        'Content-Type':
            'application/json', // Sesuaikan dengan tipe data yang digunakan di API Anda
      },
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to edit data');
    }
  }

  Future deleteData(int id) async {
    final response = await http.delete(Uri.parse('$url?id=$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Data Mahasiswa'),
      ),
      drawer: const SideMenu(),
      body: Column(children: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TambahData(),
              ),
            );
          },
          child: const Text('Tambah Data Mahasiswa'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dataMahasiswa.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(dataMahasiswa[index]['nama']!),
                subtitle: Text('Jurusan: ${dataMahasiswa[index]['jurusan']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.visibility),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewData(
                                    nama:
                                        dataMahasiswa[index]['nama'] as String,
                                    jurusan: dataMahasiswa[index]['jurusan']
                                        as String)));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Implementasikan logika edit di sini
                        editData(int.parse(dataMahasiswa[index]['id']!), {
                          // Gantilah dengan data yang ingin Anda edit
                          'nama': 'Nama yang Diperbarui',
                          'jurusan': 'Jurusan yang Diperbarui',
                        }).then((result) {
                          if (result['pesan'] == 'berhasil') {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Data berhasil di edit'),
                                  content: Text('ok'),
                                  actions: [
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ListData(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteData(int.parse(dataMahasiswa[index]['id']!))
                            .then((result) {
                          if (result['pesan'] == 'berhasil') {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Data berhasil di hapus'),
                                    content: const Text('ok'),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ListData(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                });
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}

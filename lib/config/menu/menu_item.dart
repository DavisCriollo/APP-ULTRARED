import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String subTitle;
  final String link;
  final String icon;
  final Color color;

  const MenuItem(
      {required this.title,
      required this.subTitle,
      required this.link,
      required this.color,
      required this.icon});
}

const appMenuItems = <MenuItem>[
  MenuItem(
    title: 'Actividades',
    subTitle: "Actividades",
    link: "/actividades",
    icon: 'assets/images/open-book.png',
    color: Colors.blue,
  ),
  MenuItem(
    title: 'Cuentas por Cobrar',
    subTitle: "",
    link: "/cuenta_cobrar",
    icon: 'assets/images/open-book.png',
    color: Colors.blue,
  ),
  MenuItem(
    title: 'Conexiónes PPPoE',
    subTitle: "",
    link: "/conexiones",
    icon: 'assets/images/open-book.png',
    color: Colors.blue,
  ),
];

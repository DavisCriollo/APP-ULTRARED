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
    title: 'Modulo',
    subTitle: "Nuestros Clientes",
    link: "/clientes",
    icon: 'assets/images/personas.png',
    color: Colors.blue,
  ),
];

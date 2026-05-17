import 'package:flutter/material.dart';

enum DeviceType { phone, tv }

DeviceType getDeviceType(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isLandscape = size.width > size.height;
  final isLargeScreen = size.shortestSide > 600;
  if (isLandscape && isLargeScreen) return DeviceType.tv;
  return DeviceType.phone;
}

bool isTV(BuildContext context) => getDeviceType(context) == DeviceType.tv;

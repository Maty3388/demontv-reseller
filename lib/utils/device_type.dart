import "package:flutter/material.dart";

enum DeviceType { phone, tv }

DeviceType getDeviceType(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final width = size.width;
  // TV Box generalmente tiene 960dp+ de ancho
  if (width >= 800) return DeviceType.tv;
  return DeviceType.phone;
}

bool isTV(BuildContext context) => getDeviceType(context) == DeviceType.tv;

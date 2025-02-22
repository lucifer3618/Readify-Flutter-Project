import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:readify/shared/widgets/permission_screen_layout.dart';

class LocationService {
  // Request Permission
  Future<void> reqestPermission(BuildContext context) async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return PermissionScreenLayout(
              title: "Enable Geolocation",
              description:
                  "Readify needs access to your location to help you find nearby book exchanges. This ensures you can connect with users in your area for convenient book sharing.",
              image: "assets/images/location.webp",
              onPressed: () async {
                permission = await Geolocator.requestPermission();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            );
          },
        ));
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
  }

  // Determin Postion
  Future<Position> getCurrentPosition() async {
    Position pos = await Geolocator.getCurrentPosition();
    log(pos.toString());
    return pos;
  }
}

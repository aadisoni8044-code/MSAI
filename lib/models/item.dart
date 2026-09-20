import 'vector3d.dart';

enum ItemType { healthPack, ammoCrate, airDropAK47 }

class Item {
  final String id;
  final ItemType type;
  final Vector3D position;
  final double pickupRadius;
  final int quantity;

  bool isCollected = false;
  double animPhase = 0.0; // Floating / spinning animation counter

  Item({
    required this.id,
    required this.type,
    required this.position,
    this.pickupRadius = 2.0,
    this.quantity = 1,
  });

  void update(double dt) {
    animPhase += dt * 2.0;
  }

  bool canBePickedUpBy(Vector3D playerPos) {
    if (isCollected) return false;
    return position.distanceToXZ(playerPos) <= pickupRadius;
  }
}

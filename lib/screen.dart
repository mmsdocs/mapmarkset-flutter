import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

class MapApp extends StatelessWidget {
  const MapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MapMarkset',
      home: MapContainer(),
    );
  }
}

class MapContainer extends StatefulWidget {
  const MapContainer({Key? key}) : super(key: key);

  @override
  State<MapContainer> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  final MapController _controller =
      MapController(location: LatLng(35.68, 51.41));
  final Set<LatLng> _markers = {};
  Set<Positioned> markersWidgets = {};
  List<Offset> markerPositions = [];
  bool _darkMode = false;
  // late final LatLng myLocation;

  _MapContainerState() {
    _goToDefault();
  }

  void _goToDefault() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _controller.center = LatLng(position.latitude, position.longitude);
    setState(() {});
  }

  // Positioned myLocationWidget() {
  //   const iconSize = 32.0;

  //   return Positioned(
  //     left: pos.dx - (iconSize / 2),
  //     top: pos.dy - (iconSize / 2),
  //     width: iconSize,
  //     height: iconSize,
  //     child: Icon(
  //       Icons.home,
  //       color: color,
  //       size: iconSize,
  //     ),
  //   )
  // }

  void _onDoubleTap() {
    _controller.zoom += 0.5;

    setState(() {});
  }

  void onLongPressEnd(LongPressEndDetails details, MapTransformer transformer) {
    final location = transformer.fromXYCoordsToLatLng(details.localPosition);
    _markers.add(location);
    _updateMakerPositions(transformer);

    setState(() {});
  }

  void _updateMakerPositions(MapTransformer transformer) {
    markerPositions = _markers.map(transformer.fromLatLngToXYCoords).toList();
    markersWidgets = markerPositions
        .map((pos) => _buildMarkerWidget(pos, Colors.blue))
        .toSet();
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;
  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      _controller.zoom += 0.02;
      setState(() {});
    } else if (scaleDiff < 0) {
      _controller.zoom -= 0.02;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      _controller.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  Positioned _buildMarkerWidget(Offset pos, Color color) {
    const iconSize = 32.0;

    return Positioned(
      left: pos.dx - (iconSize / 2),
      top: pos.dy - ((3 * iconSize) / 4),
      width: iconSize,
      height: iconSize,
      child: Icon(
        Icons.location_on_outlined,
        color: color,
        size: iconSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MapMarkset'),
        actions: [
          IconButton(
            tooltip: 'Toogle DarkMode',
            onPressed: () {
              setState(() {
                _darkMode = !_darkMode;
              });
            },
            icon: Icon(_darkMode ? Icons.wb_sunny_outlined : Icons.wb_sunny),
          )
        ],
      ),
      body:
          MapLayoutBuilder(controller: _controller, builder: mapLayoutBuilder),
      floatingActionButton: FloatingActionButton(
        autofocus: true,
        onPressed: _goToDefault,
        tooltip: 'Center my location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget mapLayoutBuilder(BuildContext context, MapTransformer transformer) {
    _updateMakerPositions(transformer);
    // _goToDefault();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: _onDoubleTap,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onLongPressEnd: (details) => onLongPressEnd(details, transformer),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            final delta = event.scrollDelta;

            _controller.zoom -= delta.dy / 1000.0;
            setState(() {});
          }
        },
        child: Stack(
          children: [
            Map(
              controller: _controller,
              builder: (context, x, y, z) {
                //Legal notice: This url is only used for demo and educational purposes. You need a license key for production use.

                //Google Maps
                final url =
                    'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

                final darkUrl =
                    'https://maps.googleapis.com/maps/vt?pb=!1m5!1m4!1i$z!2i$x!3i$y!4i256!2m3!1e0!2sm!3i556279080!3m17!2sen-US!3sUS!5e18!12m4!1e68!2m2!1sset!2sRoadmap!12m3!1e37!2m1!1ssmartmaps!12m4!1e26!2m2!1sstyles!2zcC52Om9uLHMuZTpsfHAudjpvZmZ8cC5zOi0xMDAscy5lOmwudC5mfHAuczozNnxwLmM6I2ZmMDAwMDAwfHAubDo0MHxwLnY6b2ZmLHMuZTpsLnQuc3xwLnY6b2ZmfHAuYzojZmYwMDAwMDB8cC5sOjE2LHMuZTpsLml8cC52Om9mZixzLnQ6MXxzLmU6Zy5mfHAuYzojZmYwMDAwMDB8cC5sOjIwLHMudDoxfHMuZTpnLnN8cC5jOiNmZjAwMDAwMHxwLmw6MTd8cC53OjEuMixzLnQ6NXxzLmU6Z3xwLmM6I2ZmMDAwMDAwfHAubDoyMCxzLnQ6NXxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjV8cy5lOmcuc3xwLmM6I2ZmNGQ2MDU5LHMudDo4MnxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjJ8cy5lOmd8cC5sOjIxLHMudDoyfHMuZTpnLmZ8cC5jOiNmZjRkNjA1OSxzLnQ6MnxzLmU6Zy5zfHAuYzojZmY0ZDYwNTkscy50OjN8cy5lOmd8cC52Om9ufHAuYzojZmY3ZjhkODkscy50OjN8cy5lOmcuZnxwLmM6I2ZmN2Y4ZDg5LHMudDo0OXxzLmU6Zy5mfHAuYzojZmY3ZjhkODl8cC5sOjE3LHMudDo0OXxzLmU6Zy5zfHAuYzojZmY3ZjhkODl8cC5sOjI5fHAudzowLjIscy50OjUwfHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE4LHMudDo1MHxzLmU6Zy5mfHAuYzojZmY3ZjhkODkscy50OjUwfHMuZTpnLnN8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmd8cC5jOiNmZjAwMDAwMHxwLmw6MTYscy50OjUxfHMuZTpnLmZ8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmcuc3xwLmM6I2ZmN2Y4ZDg5LHMudDo0fHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE5LHMudDo2fHAuYzojZmYyYjM2Mzh8cC52Om9uLHMudDo2fHMuZTpnfHAuYzojZmYyYjM2Mzh8cC5sOjE3LHMudDo2fHMuZTpnLmZ8cC5jOiNmZjI0MjgyYixzLnQ6NnxzLmU6Zy5zfHAuYzojZmYyNDI4MmIscy50OjZ8cy5lOmx8cC52Om9mZixzLnQ6NnxzLmU6bC50fHAudjpvZmYscy50OjZ8cy5lOmwudC5mfHAudjpvZmYscy50OjZ8cy5lOmwudC5zfHAudjpvZmYscy50OjZ8cy5lOmwuaXxwLnY6b2Zm!4e0&key=AIzaSyAOqYYyBbtXQEtcHG7hwAwyCPQSYidG8yU&token=31440';
                //Mapbox Streets
                // final url =
                //     'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/$z/$x/$y?access_token=YOUR_MAPBOX_ACCESS_TOKEN';

                return CachedNetworkImage(
                  imageUrl: _darkMode ? darkUrl : url,
                  fit: BoxFit.cover,
                );
              },
            ),
            ...markersWidgets,
            // myLocationWidget,
          ],
        ),
      ),
    );
  }
}

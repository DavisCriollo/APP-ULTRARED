import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

const String googleApiKey =
    "AIzaSyAoWdXxoJw4oM47HDqbpGEYxaI1D2i0kGU"; // Reemplaza con tu clave real

class EditableMap extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng)? onPositionChanged;

  const EditableMap({
    Key? key,
    required this.initialPosition,
    this.onPositionChanged,
  }) : super(key: key);

  @override
  _EditableMapState createState() => _EditableMapState();
}

class _EditableMapState extends State<EditableMap> {
  late GoogleMapController mapController;
  late LatLng _markerPosition;
  final TextEditingController _searchController = TextEditingController();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleApiKey);
  List<Prediction> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _markerPosition = widget.initialPosition;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _updatePosition(LatLng position) {
    setState(() {
      _markerPosition = position;
    });
    widget.onPositionChanged?.call(position);
  }

  void _onTap(LatLng position) {
    _updatePosition(position);
  }

  Future<void> _searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final response = await _places.autocomplete(
      input,
      language: "es",
    );

    if (response.isOkay) {
      setState(() => _suggestions = response.predictions);
    } else {
      print("Error en autocompletado: ${response.errorMessage}");
    }
  }

  Future<void> _selectPlace(Prediction prediction) async {
    final detail = await _places.getDetailsByPlaceId(prediction.placeId!);
    final location = detail.result.geometry!.location;
    final newPos = LatLng(location.lat, location.lng);

    mapController.animateCamera(CameraUpdate.newLatLng(newPos));
    _updatePosition(newPos);
    setState(() {
      _searchController.text = prediction.description!;
      _suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar ubicación...",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _searchPlaces,
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          title: Text(suggestion.description ?? ""),
                          onTap: () => _selectPlace(suggestion),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _markerPosition,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("editable_marker"),
                  position: _markerPosition,
                  draggable: true,
                  onDragEnd: _updatePosition,
                ),
              },
              onTap: _onTap,
            ),
          ),
        ],
      ),
    );
  }
}

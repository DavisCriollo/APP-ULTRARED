import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ultrared/config/config.dart';
import 'package:ultrared/features/shared/shared.dart';

class EditableMap extends StatefulWidget {
  final LatLng position;
  final Function(LatLng)? onPositionChanged;

  const EditableMap({
    super.key,
    required this.position,
    this.onPositionChanged,
  });

  @override
  EditableMapState createState() => EditableMapState();
}

class EditableMapState extends State<EditableMap> {
  late GoogleMapController mapController;
  late LatLng _markerPosition;
  final TextEditingController _searchController = TextEditingController();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Environment.mapApi);
  List<Prediction> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _markerPosition = widget.position;
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
                CustomInputField(
                  controller: _searchController,
                  label: "Buscar ubicación...",
                  suffixIcon: IconButton(
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          setState(() {
                            _suggestions = [];
                            _searchController.text = '';
                          });

                          return;
                        }
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.red,
                      )),
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

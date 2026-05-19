import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';

/// Form for editing a [RentalCarViewModel] for [TravelSegmentStepViewModel],
/// receiving a [RentalCarViewModel] and a [onChanged] callback.
class RentalCarForm extends StatefulWidget {
  const RentalCarForm({super.key, required this.rentalCar, required this.onChanged});
  /// The [RentalCarViewModel] entity to edit, used as starting point for the form
  final RentalCarViewModel rentalCar;
  /// Callback for updating the [RentalCarViewModel] entity
  final void Function(RentalCarViewModel rentalCar) onChanged;


  @override
  State<RentalCarForm> createState() => _RentalCarFormState();
}

class _RentalCarFormState extends State<RentalCarForm> {
  /// Vehicle model name controller
  final TextEditingController _vehicleModelCtrl = TextEditingController();
  /// Vehicle license plate controller
  final TextEditingController _vehicleLicensePlateCtrl = TextEditingController();
  /// Company name controller
  final TextEditingController _companyNameCtrl = TextEditingController();
  /// Check in date controller
  final TextEditingController _checkInDateCtrl = TextEditingController();
  /// Check out date controller
  final TextEditingController _checkOutDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    /// starting the controllers with the values from the constructor entity
    _vehicleModelCtrl.text = widget.rentalCar.vehicleModelName;
    _vehicleLicensePlateCtrl.text = widget.rentalCar.vehicleLicensePlate;
    _companyNameCtrl.text = widget.rentalCar.companyName;
    _checkInDateCtrl.text = widget.rentalCar.checkInString;
    _checkOutDateCtrl.text = widget.rentalCar.checkOutString;
  }

  @override
  void dispose() {
    /// dispose all controllers
    _vehicleModelCtrl.dispose();
    _vehicleLicensePlateCtrl.dispose();
    _companyNameCtrl.dispose();
    _checkInDateCtrl.dispose();
    _checkOutDateCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          children: [

            TextField(
              controller: _vehicleModelCtrl,
              decoration: const InputDecoration(
                labelText: 'Vehicle Model',
                border: OutlineInputBorder(),
              ),
            ),

            TextField(
              controller: _vehicleLicensePlateCtrl,
              decoration: const InputDecoration(
                labelText: 'License Plate',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),

        TextField(
          controller: _companyNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Company Name',
            border: OutlineInputBorder(),
          ),
        ),

        TextField(
          controller: _checkInDateCtrl,
          decoration: const InputDecoration(
            labelText: 'Check In Date',
            border: OutlineInputBorder(),
          ),
        ),

        TextField(
          controller: _checkOutDateCtrl,
          decoration: const InputDecoration(
            labelText: 'Check Out Date',
            border: OutlineInputBorder(),
          ),
        ),

      ],
    );
  }
}



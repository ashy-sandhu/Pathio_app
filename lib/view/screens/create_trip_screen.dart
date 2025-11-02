import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/providers/auth_provider.dart';
import '../../state/providers/user_profile_provider.dart';
import '../../state/providers/places_provider.dart';
import '../../data/models/place_model.dart';
import '../../data/models/trip_model.dart';
import '../components/custom_app_bar.dart';

class CreateTripScreen extends StatefulWidget {
  final Trip? trip; // If provided, we're editing

  const CreateTripScreen({super.key, this.trip});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<Place> _selectedPlaces = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _nameController.text = widget.trip!.name;
      _descriptionController.text = widget.trip!.description ?? '';
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
      _selectedPlaces = List.from(widget.trip!.places);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 1));
          }
        } else {
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End date must be after start date')),
            );
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectPlaces() async {
    final placesProvider = context.read<PlacesProvider>();
    final allPlaces = placesProvider.allPlaces;

    if (allPlaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No places available')),
      );
      return;
    }

    final selected = await showDialog<List<Place>>(
      context: context,
      builder: (context) => _PlaceSelectorDialog(
        availablePlaces: allPlaces,
        selectedPlaces: _selectedPlaces,
      ),
    );

    if (selected != null) {
      setState(() => _selectedPlaces = selected);
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    if (_selectedPlaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one place')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<UserProfileProvider>();

    bool success;
    if (widget.trip != null) {
      // Update existing trip
      success = await profileProvider.updateTrip(
        userId: authProvider.user!.uid,
        tripId: widget.trip!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        places: _selectedPlaces,
      );
    } else {
      // Create new trip
      final tripId = await profileProvider.createTrip(
        userId: authProvider.user!.uid,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        places: _selectedPlaces,
      );
      success = tripId != null;
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.trip != null
              ? 'Trip updated successfully'
              : 'Trip created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.error ?? 'Failed to save trip'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.trip != null ? 'Edit Trip' : 'Create Trip',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name *',
                  hintText: 'e.g., Summer Vacation 2024',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add notes about your trip...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Start date
              InkWell(
                onTap: () => _selectDate(true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Start Date *',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Select start date',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End date
              InkWell(
                onTap: () => _selectDate(false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'End Date *',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Select end date',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Places selection
              Card(
                child: InkWell(
                  onTap: _selectPlaces,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Places *',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              '${_selectedPlaces.length} selected',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                        if (_selectedPlaces.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Tap to select places',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ),
                        if (_selectedPlaces.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedPlaces
                                  .map(
                                    (place) => Chip(
                                      label: Text(place.name),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedPlaces.remove(place);
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.trip != null ? 'Update Trip' : 'Create Trip',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Place selector dialog
class _PlaceSelectorDialog extends StatefulWidget {
  final List<Place> availablePlaces;
  final List<Place> selectedPlaces;

  const _PlaceSelectorDialog({
    required this.availablePlaces,
    required this.selectedPlaces,
  });

  @override
  State<_PlaceSelectorDialog> createState() => _PlaceSelectorDialogState();
}

class _PlaceSelectorDialogState extends State<_PlaceSelectorDialog> {
  late List<Place> _selectedPlaces;

  @override
  void initState() {
    super.initState();
    _selectedPlaces = List.from(widget.selectedPlaces);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Select Places',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _selectedPlaces),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Places list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.availablePlaces.length,
                itemBuilder: (context, index) {
                  final place = widget.availablePlaces[index];
                  final isSelected = _selectedPlaces.contains(place);

                  return CheckboxListTile(
                    title: Text(place.name),
                    subtitle: Text(place.cityName),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedPlaces.add(place);
                        } else {
                          _selectedPlaces.remove(place);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


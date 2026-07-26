import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/address_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/services/location_service.dart';
import '../../../../domain/models/order.dart';

class OrderViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final AddressRepository addressRepository;
  final OrderRepository orderRepository;

  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  List<ServiceModel> _services = [];
  ServiceModel? _selectedService;
  bool _isLoading = false;
  String? _errorMessage;

  // Selected item tags for grid
  final List<String> _selectedItems = [];

  // Finding courier loading screen toggle
  bool _isFindingCourier = false;

  // Promo state
  Map<String, dynamic>? _selectedPromo;

  OrderViewModel({
    required this.authRepository,
    required this.addressRepository,
    required this.orderRepository,
  });

  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress;
  List<ServiceModel> get services => _services;
  ServiceModel? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get selectedItems => _selectedItems;
  bool get isFindingCourier => _isFindingCourier;
  Map<String, dynamic>? get selectedPromo => _selectedPromo;

  void toggleItem(String item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    notifyListeners();
  }

  void addCustomItem(String item) {
    final trimmed = item.trim();
    if (trimmed.isNotEmpty && !_selectedItems.contains(trimmed)) {
      _selectedItems.add(trimmed);
      notifyListeners();
    }
  }

  void selectPromo(Map<String, dynamic>? promo) {
    _selectedPromo = promo;
    notifyListeners();
  }

  void selectService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setFindingCourier(bool value) {
    _isFindingCourier = value;
    notifyListeners();
  }

  void selectServiceByTitle(String title) {
    if (_services.isEmpty) return;
    final lowerTitle = title.toLowerCase();
    try {
      final matched = _services.firstWhere((s) {
        final sTitle = s.title.toLowerCase();
        if (lowerTitle.contains('jemput') || lowerTitle.contains('pick')) {
          return sTitle.contains('fold') || sTitle.contains('cuci') || sTitle.contains('regular');
        } else if (lowerTitle.contains('lipat') || lowerTitle.contains('fold')) {
          return sTitle.contains('fold') || sTitle.contains('lipat');
        } else if (lowerTitle.contains('satuan') || lowerTitle.contains('item')) {
          return sTitle.contains('ironing') || sTitle.contains('express') || sTitle.contains('satuan');
        } else if (lowerTitle.contains('setrika') || lowerTitle.contains('iron')) {
          return sTitle.contains('iron') || sTitle.contains('setrika');
        }
        return sTitle.contains(lowerTitle);
      });
      _selectedService = matched;
    } catch (_) {
      _selectedService = _services.first;
    }
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    final token = authRepository.token;
    final user = authRepository.currentUser;
    if (token == null || user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Load Services from Admin API
      final fetchedServices = await orderRepository.getServices(token);
      _services = fetchedServices;

      // Keep previously selected service if valid, otherwise pick first
      if (_services.isNotEmpty) {
        if (_selectedService != null) {
          final exists = _services.any((s) => s.id == _selectedService!.id);
          if (!exists) _selectedService = _services.first;
        } else {
          _selectedService = _services.first;
        }
      }

      // 2. Load Addresses
      final fetchedAddresses = await addressRepository.getAddresses(user.id, token);
      _addresses = fetchedAddresses;

      // If user has no address in database, fetch real GPS location dynamically
      if (_addresses.isEmpty) {
        try {
          final locationData = await LocationService.getCurrentLocation();
          final String resolvedAddress = (locationData['address'] as String?) ?? 'Posisi Real GPS Bojongsoang';

          final realGpsAddress = await addressRepository.createAddress(
            receiverName: user.username,
            phoneNumber: '081234567890',
            houseNumber: 'GPS',
            residenceName: 'Posisi Real Terdeteksi',
            addressNotes: 'Terdeteksi otomatis via Real GPS Browser/Device',
            streetName: resolvedAddress,
            district: 'Bojongsoang',
            subDistrict: 'Sukapura',
            token: token,
          );
          _addresses.add(realGpsAddress);
        } catch (_) {
          // Local fallback address if backend/GPS error occurs
          final fallbackAddr = AddressModel(
            id: 1,
            customerId: user.id,
            receiverName: user.username,
            phoneNumber: '081234567890',
            houseNumber: 'GPS',
            residenceName: 'Posisi Real Terdeteksi',
            addressNotes: 'Terdeteksi otomatis via Real GPS Browser/Device',
            streetName: 'Jl. Raya Bojongsoang No. 12, Bandung',
            district: 'Bojongsoang',
            subDistrict: 'Sukapura',
            city: 'Bandung',
            area: 'Jawa Barat',
          );
          _addresses.add(fallbackAddr);
        }
      }

      if (_selectedAddress == null && _addresses.isNotEmpty) {
        _selectedAddress = _addresses.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addManualAddress({
    required String receiverName,
    required String phoneNumber,
    required String streetName,
    String? notes,
  }) async {
    final token = authRepository.token;
    if (token == null) return false;

    try {
      final newAddr = await addressRepository.createAddress(
        receiverName: receiverName,
        phoneNumber: phoneNumber,
        houseNumber: 'No. Manual',
        residenceName: receiverName,
        addressNotes: notes ?? '',
        streetName: streetName,
        district: 'Kota',
        subDistrict: 'Kecamatan',
        token: token,
      );
      _addresses.insert(0, newAddr);
      _selectedAddress = newAddr;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addGpsAddress() async {
    final token = authRepository.token;
    final user = authRepository.currentUser;
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final locationData = await LocationService.getCurrentLocation();
      final String resolvedAddress = (locationData['display_name'] as String?)?.isNotEmpty == true
          ? (locationData['display_name'] as String)
          : (locationData['address'] as String? ?? 'Posisi Real GPS');
      final String district = (locationData['district'] as String?)?.isNotEmpty == true
          ? (locationData['district'] as String)
          : 'Kota/Kecamatan';
      final String subDistrict = (locationData['sub_district'] as String?)?.isNotEmpty == true
          ? (locationData['sub_district'] as String)
          : 'Kelurahan';

      final gpsAddr = await addressRepository.createAddress(
        receiverName: user?.username ?? 'Lokasi Saya (GPS Akurat)',
        phoneNumber: '081234567890',
        houseNumber: 'GPS',
        residenceName: 'Posisi Real Terdeteksi',
        addressNotes: 'Terdeteksi otomatis via Real GPS Browser/Device',
        streetName: resolvedAddress,
        district: district,
        subDistrict: subDistrict,
        token: token,
      );
      _addresses.insert(0, gpsAddr);
      _selectedAddress = gpsAddr;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitOrder() async {
    final token = authRepository.token;
    final user = authRepository.currentUser;
    if (token == null) {
      _errorMessage = 'Sesi login berakhir, silakan login kembali';
      notifyListeners();
      return false;
    }

    // Ensure service is selected
    if (_selectedService == null && _services.isNotEmpty) {
      _selectedService = _services.first;
    }
    if (_selectedService == null) {
      try {
        final fetchedServices = await orderRepository.getServices(token);
        if (fetchedServices.isNotEmpty) {
          _services = fetchedServices;
          _selectedService = _services.first;
        }
      } catch (_) {}
    }

    // Ensure address is selected
    if (_selectedAddress == null && _addresses.isNotEmpty) {
      _selectedAddress = _addresses.first;
    }

    // If still null or no addresses exist, create one dynamically to ensure ordering never fails
    if (_selectedAddress == null && user != null) {
      try {
        final locationData = await LocationService.getCurrentLocation();
        final String resolvedAddress = (locationData['address'] as String?) ?? 'Kragilan, Sragen, Central Java';

        final realGpsAddress = await addressRepository.createAddress(
          receiverName: user.username,
          phoneNumber: '081234567890',
          houseNumber: 'GPS',
          residenceName: 'Posisi Real Terdeteksi',
          addressNotes: 'Terdeteksi otomatis via Real GPS Browser/Device',
          streetName: resolvedAddress,
          district: 'Bojongsoang',
          subDistrict: 'Sukapura',
          token: token,
        );
        _addresses.insert(0, realGpsAddress);
        _selectedAddress = realGpsAddress;
      } catch (_) {
        // Fallback: try fetching addresses again
        try {
          final fetched = await addressRepository.getAddresses(user.id, token);
          if (fetched.isNotEmpty) {
            _addresses = fetched;
            _selectedAddress = _addresses.first;
          }
        } catch (_) {}
      }
    }

    // Final safety check: If selectedAddress or selectedService still missing, set fallback ID=1
    int serviceId = _selectedService?.id ?? 1;
    int addressId = _selectedAddress?.id ?? (_addresses.isNotEmpty ? _addresses.first.id : 1);

    if (addressId == 0 && user != null) {
      // Ensure addressId > 0 by creating address in DB
      try {
        final created = await addressRepository.createAddress(
          receiverName: user.username,
          phoneNumber: '081234567890',
          houseNumber: 'GPS',
          residenceName: 'Posisi Real Terdeteksi',
          addressNotes: 'Auto-created for Order',
          streetName: 'Kragilan, Sragen, Central Java',
          district: 'Sragen',
          subDistrict: 'Kragilan',
          token: token,
        );
        addressId = created.id;
        _selectedAddress = created;
      } catch (_) {
        addressId = 1;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await orderRepository.createOrder(
        serviceId: serviceId,
        addressId: addressId,
        token: token,
      );
      _isLoading = false;
      _isFindingCourier = true; // Slide to searching courier state
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

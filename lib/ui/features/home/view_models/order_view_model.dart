import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/address_repository.dart';
import '../../../../data/repositories/order_repository.dart';
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

  void toggleItem(String item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
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

  Future<void> loadInitialData() async {
    final token = authRepository.token;
    final user = authRepository.currentUser;
    if (token == null || user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Load Services
      final fetchedServices = await orderRepository.getServices(token);
      _services = fetchedServices;
      if (_services.isNotEmpty) {
        _selectedService = _services.first;
      }

      // 2. Load Addresses
      final fetchedAddresses = await addressRepository.getAddresses(user.id, token);
      _addresses = fetchedAddresses;

      // If user has no address, automatically seed/create a default address
      if (_addresses.isEmpty) {
        final defaultAddress = await addressRepository.createAddress(
          receiverName: 'Pondok Sukses',
          phoneNumber: '+6281234567890',
          houseNumber: 'No. 1',
          residenceName: 'Pondok Sukses',
          addressNotes: 'Dekat Telkom University',
          streetName: 'Jl. Telekomunikasi',
          district: 'Bojongsoang',
          subDistrict: 'Bojongsoang',
          token: token,
        );
        _addresses.add(defaultAddress);
      }

      _selectedAddress = _addresses.first;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitOrder() async {
    final token = authRepository.token;
    if (token == null || _selectedAddress == null || _selectedService == null) {
      _errorMessage = 'Alamat atau layanan belum dipilih';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await orderRepository.createOrder(
        serviceId: _selectedService!.id,
        addressId: _selectedAddress!.id,
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

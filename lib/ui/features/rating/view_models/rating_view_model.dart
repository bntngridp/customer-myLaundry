import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/rating_repository.dart';
import '../../../../domain/models/rating.dart';

class RatingViewModel extends ChangeNotifier {
  final RatingRepository ratingRepository;
  final AuthRepository authRepository;

  bool _isSubmitting = false;
  String? _errorMessage;
  RatingModel? _submittedRating;

  double _courierScore = 5.0;
  double _branchScore = 5.0;
  List<String> _selectedTags = [];
  final TextEditingController reviewController = TextEditingController();

  RatingViewModel({
    required this.ratingRepository,
    required this.authRepository,
  });

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  RatingModel? get submittedRating => _submittedRating;
  double get courierScore => _courierScore;
  double get branchScore => _branchScore;
  List<String> get selectedTags => _selectedTags;

  final List<String> availableTags = [
    'Cepat & Rapi',
    'Kurir Ramah',
    'Wangi Tahan Lama',
    'Pakaian Bersih Sempurna',
    'Tepat Waktu',
    'Pelayanan Mulus',
  ];

  void setCourierScore(double score) {
    _courierScore = score;
    notifyListeners();
  }

  void setBranchScore(double score) {
    _branchScore = score;
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  Future<bool> submitRating(String orderId) async {
    final token = authRepository.token;
    if (token == null) {
      _errorMessage = 'Sesi habis, silakan login kembali.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rating = await ratingRepository.submitRating(
        orderId: orderId,
        courierScore: _courierScore,
        branchScore: _branchScore,
        tags: _selectedTags.join(', '),
        reviewText: reviewController.text.trim(),
        token: token,
      );
      _submittedRating = rating;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void resetForm() {
    _courierScore = 5.0;
    _branchScore = 5.0;
    _selectedTags = [];
    reviewController.clear();
    _errorMessage = null;
    _isSubmitting = false;
    _submittedRating = null;
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}

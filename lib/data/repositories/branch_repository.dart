import '../../domain/models/branch.dart';
import '../services/branch_service.dart';

class BranchRepository {
  final BranchService branchService;

  BranchRepository({required this.branchService});

  Future<List<BranchModel>> getBranches({double? lat, double? lng}) async {
    final rawList = await branchService.getBranches(lat: lat, lng: lng);
    return rawList.map((json) => BranchModel.fromJson(json)).toList();
  }
}

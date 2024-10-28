import 'package:get/get.dart';
import 'package:mary_cruz_app/core/models/testimony_model.dart';
import 'package:mary_cruz_app/core/supabase/supabase_instance.dart';

class TestimonyController extends GetxController {
  var testimonyList = <TestimonyModel>[].obs;
  var isLoading = false.obs;
  var error = false.obs;

  getTtestimonyList() async {
    try {
      isLoading.value = true;
      error.value = false;
      final response = await supabase.from('testimonios').select();

      final List<TestimonyModel> testimonyList = response
          .map((e) {
            return TestimonyModel.fromJson(e);
          })
          .toList()
          .cast<TestimonyModel>();


      this.testimonyList.value = testimonyList;
      isLoading.value = false;
    } catch (e) {
      print("Error al obtener el cronograma $e");
      testimonyList.value = [];
      isLoading.value = false;
      error.value = true;
    }
  }
}

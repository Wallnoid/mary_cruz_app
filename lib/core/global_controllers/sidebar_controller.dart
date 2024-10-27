import 'package:get/get.dart';
import 'package:mary_cruz_app/core/models/sidebar_option.dart';
import 'package:mary_cruz_app/core/supabase/supabase_instance.dart';

class SidebarController extends GetxController {
  var listSidebarOptions = [].obs;

  getSidebarOptions() async {
    try {
      final data = await supabase
          .from('opciones_menu')
          .select()
          .order('orden', ascending: true);

      final List<SidebarOptions> sidebarOptions =
          data.map((e) => SidebarOptions.fromMap(e)).toList();

      print(sidebarOptions);

      listSidebarOptions.value = sidebarOptions;
    } catch (e) {
      print("Error al obtener las opciones del menú $e");

      listSidebarOptions.value = [
        SidebarOptions(id: "", title: "Candidatos" /*"Home"*/, isVisible: true, order: 1),
      ];

      for (var i = 0; i < 20; i++) {   //aumentar si se aumenta el menu 
        listSidebarOptions.add(SidebarOptions(
            id: i.toString(),
            title: "Opción $i",
            isVisible: false,
            order: i + 1));
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mary_cruz_app/core/enums/sidebar.dart';
import 'package:mary_cruz_app/core/ui/components/custom_appbar.dart';
import 'package:mary_cruz_app/core/ui/components/sidebar.dart';
import 'package:mary_cruz_app/testimony/provider/testimony_provider.dart';
import 'package:mary_cruz_app/testimony/ui/components/testimony_card.dart';

class TestimonyPage extends StatefulWidget {
  const TestimonyPage({super.key});

  @override
  State<TestimonyPage> createState() => _TestimonyPageState();
}

class _TestimonyPageState extends State<TestimonyPage> {
  TestimonyController controller =
      Get.put(TestimonyController(), permanent: true);

  @override
  void initState() {
    super.initState();
    print('initState');

    controller.getTtestimonyList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (!controller.isLoading.value && controller.error.value) {
        return const Scaffold(
          appBar: CustomAppbar(
            title: 'Testimonios',
          ),
          drawer: GlobalSidebar(
            selectedIndex: SideBar.testimony,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error de conexión',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('Inténtelo más tarde.')
                ],
              ),
            ),
          ),
        );
      }

      return SafeArea(
        child: Scaffold(
          appBar: const CustomAppbar(
            title: 'Testimonios',
          ),
          drawer: const GlobalSidebar(
            selectedIndex: SideBar.testimony,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.from(
                  controller.testimonyList.map(
                    (x) =>
                        x.isVisble ? TestimonyCard(testimony: x) : Container(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

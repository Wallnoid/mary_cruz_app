import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mary_cruz_app/candidates/provider/candidates_controller.dart';
import 'package:mary_cruz_app/candidates/ui/widgets/candidate_card.dart';
import 'package:mary_cruz_app/core/enums/sidebar.dart';
import 'package:mary_cruz_app/core/ui/components/custom_appbar.dart';
import 'package:mary_cruz_app/core/ui/components/sidebar.dart';

class CandidatesPage extends StatefulWidget {
  const CandidatesPage({super.key});

  @override
  State<CandidatesPage> createState() => _CandidatesPageState();
}

class _CandidatesPageState extends State<CandidatesPage> {
  CandidatesController controller =
      Get.put(CandidatesController(), permanent: true);

  @override
  void initState() {
    super.initState();

    controller.getCandidates();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (!controller.isLoading.value && controller.error.value) {
        return const Scaffold(
          appBar: CustomAppbar(
            title: 'Candidatos',
          ),
          drawer: GlobalSidebar(
            selectedIndex: SideBar.candidates,
          ),
          body: Center(
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
        );
      }
      return SafeArea(
        child: Scaffold(
          appBar: const CustomAppbar(
            title: 'Candidatos',
          ),
          drawer: const GlobalSidebar(
            selectedIndex: SideBar.candidates,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  Column(
                    children: List<Widget>.from(
                      controller.candidates.map(
                        (x) => CandidateCard(
                          candidate: x,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

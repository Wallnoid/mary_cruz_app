import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mary_cruz_app/core/enums/sidebar.dart';
import 'package:mary_cruz_app/core/ui/components/custom_appbar.dart';
import 'package:mary_cruz_app/core/ui/components/custom_containers/info_container.dart';
import 'package:mary_cruz_app/core/ui/components/sidebar.dart';
import 'package:mary_cruz_app/proposals/models/proposal_model.dart';
import '../../../core/ui/components/hearts_score.dart';
import '../../controllers/filter_controller.dart';
import '../../data/proposals_datasource.dart';
import '../widgets/filter_dialog.dart';

class ProposalsPage extends StatefulWidget {
  const ProposalsPage({super.key});

  @override
  State<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends State<ProposalsPage> {
  List<ProposalModel> _proposals = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _fetchProposals();
  }



  Future<void> _fetchProposals() async {
    try {
      final proposals = await ProposalsDataSource().getPropuestas();

      setState(() {
        _proposals = proposals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al obtener propuestas: $e');
    }
  }

  Future<void> _refreshProposals() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchProposals();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      //isScrollControlled: true,
      builder: (BuildContext context) {
        return FilterDialog();
      },
    );
  }

  final FilterController controller = Get.put(FilterController());


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(
          title: 'Propuestas',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshProposals,
            ),
          ],
        ),
        drawer: const GlobalSidebar(
          selectedIndex: SideBar.proposals,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _proposals.isEmpty
            ? const Center(child: Text('No hay propuestas disponibles'))
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_alt_sharp),
                    onPressed: () {
                      _showFilterDialog();
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProposals,
                child: _buildProposalsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalsList() {
    return ListView.builder(
      itemCount: _proposals.length,
      itemBuilder: (context, index) {
        final proposalItem = _proposals[index];
        return InfoContainer(
          title: proposalItem.titulo,
          description: proposalItem.descripcion,
          imageUrl: proposalItem.imageUrl,
          imageHint: proposalItem.descripcion,
          footer: Column(
            children: [
              const Divider(),
              Row(
                children: [
                  for (var facultad in proposalItem.facultades)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Chip(
                        label: Text(
                          (facultad.siglas).toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor:
                        Theme.of(context).colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  for (var enfoque in proposalItem.enfoques)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Chip(
                        label: Text(
                          (enfoque.titulo).toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor:
                        Theme.of(context).colorScheme.tertiary,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                ],
              ),
              const Divider(),
              HeartsScore(
                proposal: proposalItem,
              ),
            ],
          ),
        );
      },
    );
  }
}

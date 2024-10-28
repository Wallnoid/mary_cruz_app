import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<ProposalModel> _proposalsAux = [];

  bool _isLoading = true;


  @override
  void initState() {
    super.initState();

        SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Cambia el color aquí
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _fetchProposals();
  }



  Future<void> _fetchProposals() async {
    try {
      final proposals = await ProposalsDataSource().getPropuestas();

      setState(() {
        _proposals = proposals;
        _proposalsAux = proposals;
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
    controller.eraseInfo();
    await _fetchProposals();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      //isScrollControlled: true,
      builder: (BuildContext context) {
        return FilterDialog( facultadesGeneral: controller.facultades, enfoquesGeneral: controller.enfoques, candidatesGeneral: controller.candidatos,);
      },
    );
  }

  final FilterController controller = Get.put(FilterController());


  @override
  Widget build(BuildContext context) {
    return Obx(() {   

      if (controller.hasInfo()) { 
        //print("si");
        print("proposal ");
        // filtros
        if(controller.candidatos.isNotEmpty && controller.enfoques.isEmpty){  //facultad
         _proposals = _proposalsAux.where((e) {
            return controller.candidatos.any((el) {
              return e.candidatos.any((element) => element.name == el.name);
            });
          }).toList();
        }else if(controller.candidatos.isEmpty && controller.enfoques.isNotEmpty){  // enfoque
          

          _proposals = _proposalsAux.where((e) {
            return controller.enfoques.any((el) {
              return e.enfoques.any((element) => element.titulo == el.titulo);
            });
          }).toList();
          
          
        }else if(controller.candidatos.isNotEmpty && controller.enfoques.isNotEmpty){
          _proposals = _proposalsAux.where((e) {
              return controller.candidatos.any((el) {
                return e.candidatos.any((element) => element.name == el.name);
              }) || controller.enfoques.any((el) {
                return e.enfoques.any((element) => element.titulo == el.titulo);
              });
          }).toList();
          
            }else{
        _proposals = _proposalsAux;
      }


      }else{
        _proposals = _proposalsAux;
      }
      
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
              ? const Center(
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
          )
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    controller.hasInfo()?
                     Expanded(
                      flex: 2,
                       child: Column(
                         children: [ 
                        (controller.candidatos.length > 0) ?
                           SizedBox(
                              height: 20, 
                             child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                           
                                itemCount: controller.candidatos.length,
                                itemBuilder: (context, index) {
                                  return  Padding(
                                    padding: const EdgeInsets.only(right: 3.0),
                                    child: Container(  
                                      //width: ScreenUtil().setWidth(35.0),
                                      //backgroundColor: Theme.of(context).colorScheme.secondary,
                                    
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary, // Background color
                                          borderRadius: BorderRadius.circular(8), // Rounded corners
                                         
                                      ),
                                      child: Text(" ${controller.candidatos[index].name.toUpperCase()}  ", 
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,     
                                          )),
                                    ),
                                  );
                                }
                              ),
                           ): SizedBox(height: 0.0, width: 0.0,),
                     (controller.enfoques.length > 0) ?
      
                           Padding(
                             padding: const EdgeInsets.only(top: 3.0),
                             child: SizedBox(
                                height: 20, 
                               child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                             
                                  itemCount: controller.enfoques.length,
                                  itemBuilder: (context, index) {
                                    return  Padding(
                                      padding: const EdgeInsets.only(right: 3.0),
                                      child: Container(  
                                        //width: ScreenUtil().setWidth(45.0),
                                        //backgroundColor: Theme.of(context).colorScheme.secondary,
                                      
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.secondary, // Background color
                                            borderRadius: BorderRadius.circular(8), // Rounded corners
                                           
                                        ),
                                        child: Text(" ${controller.enfoques[index].titulo}  ",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,  
                                            )),
                                      ),
                                    );
                                  }
                                ),
                             ),
                           ): SizedBox(height: 0.0, width: 0.0,),
                           
                         ],
                       ),
                     )
                      : Text(
                       'Filtro' ,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         IconButton(
                          icon: const Icon(Icons.filter_alt_sharp),
                          onPressed: () {
                            _showFilterDialog();
                          },
                        ),
                        controller.hasInfo()?
                         IconButton( 
                          icon: const Icon(Icons.delete, color: Colors.red,), 
                          onPressed: () {
                            controller.eraseInfo();
                          },
                        ): SizedBox(height: 0.0, width: 0.0,)
      
                    ],)
                   
      
                   
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
              proposalItem.candidatos.length>0? 
              const Divider(): const SizedBox(height: 0.0, width: 0.0,),
              Row(
                children: [
                  
                          Expanded(
                            flex: 2,
                             child: 
                             proposalItem.candidatos.length>0?
                             SizedBox(
                                height: 30, 
                               child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                             
                                  itemCount: proposalItem.candidatos.length,
                                  itemBuilder: (context, index) {
                                    return  Padding(
                                      padding: const EdgeInsets.only(right: 3.0),
                                      child:   Chip(
                                          label: Text("${proposalItem.candidatos[index].name}" ,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor:
                                          Theme.of(context).colorScheme.tertiary,
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          side: const BorderSide(color: Colors.white, width: 1),
                                        ),
                                    );
                                  }
                                ),
                             ): const SizedBox(height: 0.0,width: 0.0,),
                           )
                ],
              ),
              
              proposalItem.enfoques.length>0? 
              const Divider(): const SizedBox(height: 0.0, width: 0.0,),
              Row(
                children: [  

                          Expanded(
                            flex: 2,
                             child: proposalItem.enfoques.length>0? 
                             SizedBox(
                                height: 30, 
                               child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                             
                                  itemCount: proposalItem.enfoques.length,
                                  itemBuilder: (context, index) {
                                    return  Padding(
                                      padding: const EdgeInsets.only(right: 3.0),
                                      child:   Chip(
                                          label: Text("${proposalItem.enfoques[index].titulo}" ,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor:
                                          Theme.of(context).colorScheme.tertiary,
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          side: const BorderSide(color: Colors.white, width: 1),
                                        ),
                                    );
                                  }
                                ),
                             ): const SizedBox(height: 0.0,width: 0.0,),
                           )
                  
                  /*for (var enfoque in proposalItem.enfoques)
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
                    ),*/
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

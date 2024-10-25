import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importa para inicializar la localización
import 'package:mary_cruz_app/challenges/ui/widgets/add_challenge_dialog.dart';
import 'package:mary_cruz_app/core/enums/sidebar.dart';
import 'package:mary_cruz_app/core/ui/components/custom_appbar.dart';
import 'package:mary_cruz_app/core/ui/components/custom_containers/info_container.dart';
import 'package:mary_cruz_app/core/ui/components/sidebar.dart';
import 'package:mary_cruz_app/news/models/news_model.dart';
import 'package:mary_cruz_app/news/data/news_datasource.dart';

import '../../../core/ui/components/hearts_score.dart';
import '../data/challenges_datasource.dart';
import '../models/challenge_model.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  List<ChallengeModel> _challenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _fetchChallenges();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('es_ES', null);
  }

  Future<void> _fetchChallenges() async {
    try {
      final challenges = await ChallengesDataSource().getAllChallenges();
      setState(() {
        _challenges = challenges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al obtener retos: $e');
    }
  }

  Future<void> _refreshChallenges() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchChallenges();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(
          title: 'Retos',
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showStepperDialog,
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        drawer: const GlobalSidebar(
          selectedIndex: SideBar.challenges,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _challenges.isEmpty
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
            : RefreshIndicator(
          onRefresh: _refreshChallenges,
          child: _buildChallengesList(),
        ),
      ),
    );
  }

  void _showStepperDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: StepperDialog(),
        );
      },
    );
  }
  Widget _buildChallengesList() {
    return ListView.builder(
      itemCount: _challenges.length,
      itemBuilder: (context, index) {
        final challenge = _challenges[index];
        return InfoContainer(
          title: challenge.nombre,
          description: challenge.description,
          imageUrl: challenge.imgUrl,
          imageHint: challenge.imgHint,
          footer: SizedBox(),
        );
      },
    );
  }
}


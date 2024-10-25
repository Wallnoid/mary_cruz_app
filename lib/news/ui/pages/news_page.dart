import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importa para inicializar la localización
import 'package:mary_cruz_app/core/enums/sidebar.dart';
import 'package:mary_cruz_app/core/models/user_model.dart';
import 'package:mary_cruz_app/core/models/vote_model.dart';
import 'package:mary_cruz_app/core/ui/components/custom_appbar.dart';
import 'package:mary_cruz_app/core/ui/components/custom_containers/info_container.dart';
import 'package:mary_cruz_app/core/ui/components/sidebar.dart';
import 'package:mary_cruz_app/news/models/news_model.dart';
import 'package:mary_cruz_app/news/data/news_datasource.dart';

import '../../../core/data/users_datasource.dart';
import '../../../core/ui/components/hearts_score.dart';
import '../../../core/utils/cellphone_info.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsModel> _news = [];
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

    _initializeLocale();
    _fetchNews();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('es_ES', null);
  }

  Future<void> _fetchNews() async {
    try {
      final news = await NewsDataSource().getAllNews();
      setState(() {
        _news = news;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al obtener noticias: $e');
    }
  }

  Future<void> _refreshNews() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchNews();
  }

  Map<String, List<NewsModel>> _groupNewsByDate(List<NewsModel> news) {
    Map<String, List<NewsModel>> groupedNews = {};
    for (var newsItem in news) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(newsItem.createdAt);
      if (!groupedNews.containsKey(formattedDate)) {
        groupedNews[formattedDate] = [];
      }
      groupedNews[formattedDate]?.add(newsItem);
    }
    return groupedNews;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(
          title: 'Noticias',
        ),
        drawer: const GlobalSidebar(
          selectedIndex: SideBar.news,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _news.isEmpty
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
          onRefresh: _refreshNews,
          child: _buildNewsList(),
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    final groupedNews = _groupNewsByDate(_news);
    final sortedKeys = groupedNews.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: groupedNews.values.fold(0, (prev, element) => prev + element.length) + sortedKeys.length,
      itemBuilder: (context, index) {
        int newsIndex = 0;
        for (var date in sortedKeys) {
          if (index == newsIndex) {
            return _buildDateDivider(date);
          }
          newsIndex++;
          final newsList = groupedNews[date]!;
          if (index - newsIndex < newsList.length) {
            return InfoContainer(
              title: newsList[index - newsIndex].titulo,
              description: newsList[index - newsIndex].descripcion,
              imageUrl: newsList[index - newsIndex].urlImagen,
              imageHint: newsList[index - newsIndex].imagenHint,
              footer: HeartsScore(
                news: newsList[index - newsIndex],
              ),
            );
          }
          newsIndex += newsList.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDateDivider(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 1.5,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('dd MMMM yyyy', 'es_ES').format(DateTime.parse(date)),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 1.5,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:mary_cruz_app/actualization/first_page.dart';
import 'package:mary_cruz_app/candidates/ui/pages/candidate_description_page.dart';
import 'package:mary_cruz_app/candidates/ui/pages/candidates_page.dart';
import 'package:mary_cruz_app/events/pages/events_page.dart';
import 'package:mary_cruz_app/survey/pages/survey_page.dart';
import 'package:mary_cruz_app/testimony/pages/testimony_page.dart';
import '../../../challenges/ui/challenges_page.dart';
import '../../../comments/ui/opinions_page.dart';
import '../../../home/ui/pages/home_page.dart';
import '../../../news/ui/pages/news_page.dart';
import '../../../play/pages/play_page.dart';
import '../../../proposals/ui/pages/proposals_page.dart';

class GlobalRouteGet {
  static const initialRoute = '/actualization';

  static final List<GetPage> routes = [
    GetPage(
        name: '/', // '/candidates',
        page: () => const CandidatesPage(),
        children: [
          GetPage(
              name: '/candidate-description',
              page: () => const CandidateDescriptionPage(),
              transition: Transition.fadeIn),
        ],
        transition: Transition.fadeIn),
    GetPage(
        name: '/agenda', page: () => const HomePage(), transition: Transition.fadeIn),
    GetPage(
        name: '/actualization',
        page: () => const FirstPage(),
        transition: Transition.fadeIn),
    GetPage(
        name: '/proposals',
        page: () => const ProposalsPage(),
        transition: Transition.fadeIn),
    GetPage(
        name: '/news',
        page: () => const NewsPage(),
        transition: Transition.fadeIn),
    GetPage(
        name: '/events',
        page: () => const EventsPage(),
        transition: Transition.fadeIn),
    GetPage(
        name: '/testimony',
        page: () => const TestimonyPage(),
        transition: Transition.fadeIn),
    GetPage(
        name: '/opinions',
        page: () => const OpinionsPage(),
        transition: Transition.fadeIn),
    GetPage(
        name: '/challenges',
        page: () => const ChallengesPage(),
        transition: Transition.fadeIn),
    GetPage(
      name: '/survey',
      page: () => const SurveyPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/play',
      page: () =>  const PlayPage(),
      transition: Transition.fadeIn,
    ),
  ];
}

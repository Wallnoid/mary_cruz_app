import 'package:get/get.dart';
import 'package:mary_cruz_app/core/models/diary_model.dart';
import 'package:mary_cruz_app/core/models/section_per_month_model.dart';
import 'package:mary_cruz_app/core/supabase/supabase_instance.dart';

class DiaryController extends GetxController {
  var diaryList = <DiaryModel>[].obs;
  var isLoading = false.obs;
  var error = false.obs;

  var sectionsPerMonth = <SectionPerMonthModel>[].obs;

  hidePastDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<DiaryModel> filteredDiaryList = diaryList.where((diary) {
      final diaryDate =
          DateTime(diary.date.year, diary.date.month, diary.date.day);
      return diaryDate.isAfter(today) || diaryDate.isAtSameMomentAs(today);
    }).toList();

    diaryList.value = filteredDiaryList;
    createSectionsPerMonth();
  }

  createSectionsPerMonth() {
    final Map<int, List<DiaryModel>> sectionsPerMonth = {};

    for (var diary in diaryList) {
      if (!diary.isVisible) {
        continue;
      }

      final month = diary.date.month;

      if (!sectionsPerMonth.containsKey(month)) {
        sectionsPerMonth[month] = [];
      }

      sectionsPerMonth[month]?.add(diary);
    }

    sectionsPerMonth.forEach((month, diaryList) {
      diaryList.sort((a, b) {
        final dayComparison = a.date.day.compareTo(b.date.day);
        if (dayComparison != 0) {
          return dayComparison;
        }
        return a.initTime.compareTo(b.initTime);
      });
    });

    final sortedMonths = sectionsPerMonth.keys.toList()..sort();

    final List<SectionPerMonthModel> sectionsPerMonthList =
        sortedMonths.map((month) {
      return SectionPerMonthModel(
        month: month,
        diaryList: sectionsPerMonth[month] ?? [],
      );
    }).toList();

    this.sectionsPerMonth.value = sectionsPerMonthList;
  }

  getDiary() async {
    try {
      isLoading.value = true;
      error.value = false;
      final response = await supabase.from('cronograma').select();

      final List<DiaryModel> diaryList = response
          .map((e) {
            return DiaryModel.fromJson(e);
          })
          .toList()
          .cast<DiaryModel>();

      this.diaryList.value = diaryList;
      isLoading.value = false;

      hidePastDates();
    } catch (e) {
      print("Error al obtener el cronograma $e");
      this.diaryList.value = [];
      isLoading.value = false;
      error.value = true;
    }
  }
}

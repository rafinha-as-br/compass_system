import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_matrix/features/travels/domain/usecases/timeline_analyzer.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// TimelineProblem view class, used to represent [TimelineProblem]
class TimelineProblemViewModel{
  /// Title of the problem
  final String title;
  /// Contains the description of the problem, having the name and details of the entities involved
  final String description;
  /// Problem type
  final TimelineProblemType type;


  TimelineProblemViewModel({
    required this.title,
    required this.description,
    required this.type,
  });

  /// color getter for UI
  Color get problemColor {
    return Colors.amber.shade700;
  }

  /// Mapper method from [TimelineProblem] to [TimelineProblemViewModel],
  /// the texts are localized with [l10n] and name the cause and the dates involved.
  factory TimelineProblemViewModel.fromTimelineProblem(
    TimelineProblem problem,
    ItineraryStepViewModel step1,
    ItineraryStepViewModel step2,
    AppLocalizations l10n,
  ){
    final shortDate = DateFormat(l10n.localeName.startsWith('pt') ? 'dd/MM' : 'MM/dd').format;
    final fullDate = DateFormat('dd/MM/yyyy HH:mm').format;

    switch(problem.type){
      case TimelineProblemType.conflict:
        return TimelineProblemViewModel(
          type: problem.type,
          title: l10n.timelineProblemConflictTitle,
          description: l10n.timelineProblemConflictDescription(
            step1.title, fullDate(step1.finishDate), step2.title, fullDate(step2.startDate),
          ),
        );
      case TimelineProblemType.emptyGap:
        return TimelineProblemViewModel(
          type: problem.type,
          title: l10n.timelineProblemEmptyGapTitle,
          description: l10n.timelineProblemEmptyGapDescription(
            step1.title, fullDate(step1.finishDate), step2.title, fullDate(step2.startDate),
          ),
        );
      case TimelineProblemType.invalidChronologicalOrder:
        return TimelineProblemViewModel(
          type: problem.type,
          title: l10n.timelineProblemChronologicalOrderTitle,
          description: l10n.timelineProblemChronologicalOrderDescription(step1.title, step2.title),
        );
      case TimelineProblemType.invalidDate:
        return TimelineProblemViewModel(
          type: problem.type,
          title: l10n.timelineProblemInvalidDateTitle,
          description: l10n.timelineProblemInvalidDateDescription(step1.title),
        );
      case TimelineProblemType.outsideStepPeriod:
        final inner = step1.buildInternalTimeline()![1];
        final isFlight = step1 is TravelSegmentStepViewModel && step1.transport is AirplaneViewModel;
        return TimelineProblemViewModel(
          type: problem.type,
          title: l10n.timelineProblemOutsideStepPeriodTitle,
          description: isFlight
              ? l10n.timelineProblemFlightOutsideStepPeriodDescription(
                  shortDate(inner.startDate), shortDate(step1.startDate), shortDate(step1.finishDate),
                )
              : l10n.timelineProblemContentOutsideStepPeriodDescription(
                  shortDate(inner.startDate), shortDate(inner.finishDate),
                  shortDate(step1.startDate), shortDate(step1.finishDate),
                ),
        );
    }
  }

}

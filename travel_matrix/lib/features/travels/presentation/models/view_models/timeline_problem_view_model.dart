
import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/domain/usecases/timeline_analyzer.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:intl/intl.dart';

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
    return Colors.yellow;
  }

  /// Mapper method from [TimelineProblem] to [TimelineProblemViewModel]
  factory TimelineProblemViewModel.fromTimelineProblem(TimelineProblem problem, ItineraryStepViewModel step1, ItineraryStepViewModel step2){
    final title = _typeToTitleString(problem.type);
    final description = _typeToDescriptionString(problem.type, step1, step2);
    return TimelineProblemViewModel(
      title: title,
      description: description,
      type: problem.type,
    );
  }

}



String _typeToTitleString(TimelineProblemType type){
  switch(type){
    case TimelineProblemType.conflict:
      return 'Conflict';
    case TimelineProblemType.emptyGap:
      return 'Empty Gap';
    case TimelineProblemType.invalidChronologicalOrder:
      return 'Invalid Chronological Order';
      case TimelineProblemType.invalidDate:
      return 'Invalid Date';
  }
}

String _typeToDescriptionString(TimelineProblemType type, ItineraryStepViewModel step1, ItineraryStepViewModel step2){
  switch(type){
    case TimelineProblemType.conflict:
      return 'Date conflict between ${_formatDate(step1.finishDate)} from "${step1.title}" and ${_formatDate(step2.startDate)} from "${step2.title}"';
    case TimelineProblemType.emptyGap:
      return 'Big empty Gap between ${_formatDate(step1.finishDate)} from "${step1.title}" and ${_formatDate(step2.startDate)} from "${step2.title}"';
    case TimelineProblemType.invalidChronologicalOrder:
      return 'Invalid Chronological Order between "${step1.title}" and "${step2.title}"';
    case TimelineProblemType.invalidDate:
      return 'Invalid Date on "${step1.title}"';
  }
}


String _formatDate(DateTime date){
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

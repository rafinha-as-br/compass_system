

import 'package:flutter/foundation.dart';

/// Analyses the timeline to find any possible [TimelineProblemType],
/// having 3 types of analysis, which are:
/// 1. Invalid dates analyser
/// 2. Invalid chronological order analyser
/// 3. Gaps & start/finish analyser between the nodes on the sorted list
List<TimelineProblem> timelineAnalyzer(List<TimelineNode> nodes){

  /// Duration allowed gap const value
  const Duration allowedGap = Duration(hours: 1);

  final List<TimelineProblem> problems = [];

  /// Helper method to add a problem to the list
  void addProblem(String nodeId1, String nodeId2, TimelineProblemType type){
    problems.add(TimelineProblem(nodeId1: nodeId1, nodeId2: nodeId2, type: type));
  }

  /// 1. Invalid dates analyser
  for(var node in nodes){
    if(node.startDate.isAfter(node.finishDate)){
      addProblem(
        node.domainId,
        node.domainId,
        TimelineProblemType.invalidDate,
      );
    }
  }

  /// If there is already errors, return the list before proceeding with the analysis
  if(problems.isNotEmpty){
    return problems;
  }

  /// Sorting the nodes by start date
  final sortedNodes = [...nodes]
    ..sort((a, b) => a.startDate.compareTo(b.startDate));

  /// 2. Invalid chronological order analyser
  for (int i = 0; i < sortedNodes.length - 1; i++) {


    if(sortedNodes[i].sequenceIndex != i){
      final misplacedNode = sortedNodes[i];
      final expectedNode = sortedNodes[misplacedNode.sequenceIndex];

      addProblem(
        misplacedNode.domainId,
        expectedNode.domainId,
        TimelineProblemType.invalidChronologicalOrder,
      );
    }
  }

  /// If there is already errors, return the list before proceeding with the gap analysis
  if(problems.isNotEmpty){
    return problems;
  }

  /// 3. Gap & overlap analyser between the nodes on the sorted list
  for (int i = 0; i < sortedNodes.length - 1; i++) {
    final node = sortedNodes[i];
    final nextNode = sortedNodes[i + 1];
    final gap = nextNode.startDate.difference(node.finishDate);
    // gap analyser between finish/start dates of two objects
    if (gap > allowedGap) {
      addProblem(
        node.domainId,
        nextNode.domainId,
        TimelineProblemType.emptyGap,
      );
    }
    /// date analyser
    if (nextNode.startDate.isBefore(node.finishDate)) {
      addProblem(
        node.domainId,
        nextNode.domainId,
        TimelineProblemType.conflict,
      );
    }
  }


  return problems;
}

/// Represents a problem on the timeline
class TimelineProblem {
  /// Id of the first entity
  final String nodeId1;
  /// Id of the second entity
  final String nodeId2;
  /// Type of the problem
  final TimelineProblemType type;

  TimelineProblem({required this.nodeId1, required this.nodeId2, required this.type});

  /// Bool to check if there is a problem on that entity
  bool involves(String nodeId){
    return nodeId1 == nodeId || nodeId2 == nodeId;
  }

}

@immutable
/// Represents a short period of time
class TimelineNode {
  /// Id used for local reference
  final String domainId;
  /// Start date for the period
  final DateTime startDate;
  /// Finish date for the period
  final DateTime finishDate;
  /// Index in the timeline
  final int sequenceIndex;

  const TimelineNode({
    required this.domainId,
    required this.startDate,
    required this.finishDate,
    required this.sequenceIndex
  });
}

/// Type of problems on the timeline
enum TimelineProblemType{
  /// Conflict between start/finish dates of two objects
  conflict,
  /// Gap between finish/start dates of two objects
  emptyGap,
  /// The sorted list is different than the steps list
  invalidChronologicalOrder,
  /// Invalid date
  invalidDate
}

/// Severity of the timeline problem
enum TimelineProblemSeverity {
  warning,
  error,
}

extension TimelineProblemTypeSeverity on TimelineProblemType {
  TimelineProblemSeverity get severity {
    switch(this) {
      case TimelineProblemType.invalidDate:
        return TimelineProblemSeverity.error;

      case TimelineProblemType.invalidChronologicalOrder:
        return TimelineProblemSeverity.error;

      case TimelineProblemType.conflict:
        return TimelineProblemSeverity.warning;

      case TimelineProblemType.emptyGap:
        return TimelineProblemSeverity.warning;
    }
  }
}


/// Annotations =======================================================================================================
/// Final objective: Have "$type between $id1 and $id2" string representation
/// on UI: involves(String nodeId) -> Boolean to check if there is a problem on that entity


class RouteViewModel{
  final String id;
  final String startDate;
  final String endDate;
  final String start;
  final String destination;
  final List<InterestPointViewModel> interests;

  RouteViewModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.start,
    required this.destination,
    required this.interests
  });


}

class InterestPointViewModel{
  final String id;
  final String name;
  final String description;

  InterestPointViewModel({
    required this.id,
    required this.name,
    required this.description
  });
}
/// Mirrors backend `StatsDto` from `GET /api/stats`.
class Stats {
  const Stats({
    required this.activePosts,
    required this.newApplicants,
    required this.interviewsToday,
  });

  final int activePosts;
  final int newApplicants;
  final int interviewsToday;

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      activePosts: (json['activePosts'] as num).toInt(),
      newApplicants: (json['newApplicants'] as num).toInt(),
      interviewsToday: (json['interviewsToday'] as num).toInt(),
    );
  }
}

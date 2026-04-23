/// Domain model for a job listing. Mirrors the backend `JobDto` served
/// by `GET /api/jobs` — see backend `jobs/dto/JobDto.java`.
class Job {
  const Job({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.experience,
    required this.salaryRange,
    required this.postedBy,
    required this.closingDate,
  });

  final String id;
  final String title;
  final String location;

  /// Wire-form employment type. One of: `Full-time`, `Contract`,
  /// `Part-time`, `Internship`.
  final String type;
  final String experience;
  final String salaryRange;
  final String postedBy;

  /// ISO-8601 date (`YYYY-MM-DD`) emitted by the backend's `LocalDate`
  /// serialisation. Kept as-is so the UI can format it consistently.
  final String closingDate;

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      experience: json['experience'] as String,
      salaryRange: json['salaryRange'] as String,
      postedBy: json['postedBy'] as String,
      closingDate: json['closingDate'] as String,
    );
  }
}

/// Matches the backend's shared `PageResponse<T>` envelope. See
/// `common/web/PageResponse.java` on the server.
class JobPage {
  const JobPage({
    required this.content,
    required this.page,
    required this.size,
    required this.total,
  });

  final List<Job> content;
  final int page;
  final int size;
  final int total;

  factory JobPage.fromJson(Map<String, dynamic> json) {
    final raw = (json['content'] as List<dynamic>? ?? const <dynamic>[]);
    return JobPage(
      content: raw
          .cast<Map<String, dynamic>>()
          .map(Job.fromJson)
          .toList(growable: false),
      page: (json['page'] as num? ?? 0).toInt(),
      size: (json['size'] as num? ?? 0).toInt(),
      total: (json['total'] as num? ?? 0).toInt(),
    );
  }
}

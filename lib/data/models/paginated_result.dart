class PaginatedResult<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginatedResult({
    required this.data,
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
  });

  bool get hasMore => currentPage < lastPage;
  bool get isEmpty => data.isEmpty;

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final list = (json['data'] as List? ?? [])
        .map((e) => fromJsonT(Map<String, dynamic>.from(e as Map)))
        .toList();

    final meta = json['meta'] as Map<String, dynamic>? ?? json;

    return PaginatedResult(
      data: list,
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 10,
      total: meta['total'] as int? ?? list.length,
    );
  }
}

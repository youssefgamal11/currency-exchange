enum BlocStatus {
  initial,
  loading,
  success,
  failure,
  uploading,
  updated;

  bool get isInitial => this == BlocStatus.initial;
  bool get isLoading => this == BlocStatus.loading;
  bool get isSuccess => this == BlocStatus.success;
  bool get isFailure => this == BlocStatus.failure;
  bool get isUploading => this == BlocStatus.uploading;
  bool get isUpdated => this == BlocStatus.updated;
}

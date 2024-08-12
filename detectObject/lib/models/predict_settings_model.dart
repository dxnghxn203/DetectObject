class PredictSettingsModel {
  double currentExposureOffset = 1;
  double currentThreshold = 0.75;
  double currentIoU = 0.15;
  PredictSettingsModel(
      this.currentExposureOffset, this.currentIoU, this.currentThreshold);

  getCurrentExposureOffset() {
    return int.parse((currentExposureOffset * 100).toStringAsFixed(0));
  }

  getCurrentIoU() {
    return int.parse((currentIoU * 100).toStringAsFixed(0));
  }

  getCurrentThreshold() {
    return int.parse((currentThreshold * 100).toStringAsFixed(0));
  }
}

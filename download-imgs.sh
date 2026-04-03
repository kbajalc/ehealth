#!/usr/bin/env bash
# Download all images for GUIDE.md into the imgs/ directory.
# Run from the repository root: bash download-imgs.sh

set -euo pipefail

DEST="$(dirname "$0")/imgs"
mkdir -p "$DEST"

REFERER="https://projects-raspberry.com/e-health-sensor-platform-v2-0-for-arduino-and-raspberry-pi-biometric-medical-applications/"
UA="Mozilla/5.0 (X11; Linux x86_64; rv:115.0) Gecko/20100101 Firefox/115.0"

URLS=(
  "https://projects-raspberry.com/storage/2015/09/e-Health-Sensor-Platform-V2.0-for-Arduino-and-Raspberry-Pi.jpg"
  "https://projects-raspberry.com/storage/2015/05/e-Health-Sensor-Platform-V2.0-for-Arduino-and-Raspberry-Pi.jpg"
  "https://projects-raspberry.com/storage/2015/09/e-Health-shield-over-Raspberry-Pi.png"
  "https://projects-raspberry.com/storage/2015/09/Sensor-Platform.png"
  "https://projects-raspberry.com/storage/2015/09/Connecting-the-sensor-3.png"
  "https://projects-raspberry.com/storage/2015/09/Insert-your-finger-into-the-sensor-and-press-ON-button..png"
  "https://projects-raspberry.com/storage/2015/09/After-a-few-seconds-you-will-get-the-values-in-the-sensor-screen..png"
  "https://projects-raspberry.com/storage/2015/09/Arduino-IDE-serial-port-terminal.png"
  "https://projects-raspberry.com/storage/2015/09/Mobile-App-1.png"
  "https://projects-raspberry.com/storage/2015/09/GLCD-2.png"
  "https://projects-raspberry.com/storage/2015/09/Schematic-representation-of-normal-ECG.png"
  "https://projects-raspberry.com/storage/2015/09/Connecting-the-sensor-4.png"
  "https://projects-raspberry.com/storage/2015/09/Connect_the_three_leads.png"
  "https://projects-raspberry.com/storage/2015/09/Connect-the-ECG-lead-to-the-electrodes..png"
  "https://projects-raspberry.com/storage/2015/09/Remove-the-protective-plastic.png"
  "https://projects-raspberry.com/storage/2015/09/Place-the-electrodes-as-shown-below.png"
  "https://projects-raspberry.com/storage/2015/09/Mobile-App-2.png"
  "https://projects-raspberry.com/storage/2015/09/GLCD-3.png"
  "https://projects-raspberry.com/storage/2015/09/KST-program-shows-the-ECG-wave.png"
  "https://projects-raspberry.com/storage/2015/09/Airflow-breathing.png"
  "https://projects-raspberry.com/storage/2015/09/Stay-put-prongs-position-sensor-precisely-in-airflow-path.png"
  "https://projects-raspberry.com/storage/2015/09/Connecting-the-sensor-5.png"
  "https://projects-raspberry.com/storage/2015/09/Connect-the-red-wire-with-the-positive-terminal.png"
  "https://projects-raspberry.com/storage/2015/09/After-connecting-the-cables-tighten-the-screws.png"
  "https://projects-raspberry.com/storage/2015/09/Place-the-sensor-as-shown-in-the-picture-below.png"
  "https://projects-raspberry.com/storage/2015/09/Arduino-IDE-serial-port-terminal-1.png"
  "https://projects-raspberry.com/storage/2015/09/Smartphone-app.png"
  "https://projects-raspberry.com/storage/2015/09/GLCD-4.png"
  "https://projects-raspberry.com/storage/2015/09/KST-program-shows-the-airflow-wave.png"
  "https://projects-raspberry.com/storage/2015/09/Temperature-sensor-features.png"
  "https://projects-raspberry.com/storage/2015/09/Sensor-Calibration-1.png"
  "https://projects-raspberry.com/storage/2015/09/multimeter-1.png"
  "https://projects-raspberry.com/storage/2015/09/Place-multimeter-ends-at-the-extremes-of-the-resistors-and-measure-the-resistance-value.png"
  "https://projects-raspberry.com/storage/2015/09/In-this-case-we-would-not-change-the-value.png"
  "https://projects-raspberry.com/storage/2015/09/Connecting-the-sensor-6.png"
  "https://projects-raspberry.com/storage/2015/09/Here-is-the-USB-output-using-the-Arduino-IDE-serial-port-terminal-1.png"
  "https://projects-raspberry.com/storage/2015/09/Mobile-App-3.png"
  "https://projects-raspberry.com/storage/2015/09/GLCD.png"
  "https://projects-raspberry.com/storage/2015/09/Blood-pressure-sensor-features.png"
  "https://projects-raspberry.com/storage/2015/09/Compatible-with-ehealth-V1.png"
  "https://projects-raspberry.com/storage/2015/09/The-connection-of-this-sensor-in-other-e-Health-versions-is-very-simple.png"
  "https://projects-raspberry.com/storage/2015/09/ou-must-use-the-GLCD-connector-and-connect-the-device-as-shown-in-the-next-picture.png"
  "https://projects-raspberry.com/storage/2015/09/Connecting-the-sensor.png"
  "https://projects-raspberry.com/storage/2015/09/Place-the-sphygmomanometer-on-your-arm.png"
  "https://projects-raspberry.com/storage/2015/09/The-sensor-will-begin-to-make-a-measurement.png"
  "https://projects-raspberry.com/storage/2015/09/It-will-store-the-values-in-the-memory.png"
  "https://projects-raspberry.com/storage/2015/09/The-cable-is-composed-of-two-adapter-cables-as-shown-in-the-following-image.png"
  "https://projects-raspberry.com/storage/2015/09/Here-is-the-USB-output-using-the-Arduino-IDE-serial-port-terminal.png"
  "https://projects-raspberry.com/storage/2015/09/Patient-position-and-falls.png"
  "https://projects-raspberry.com/storage/2015/09/Body-position.png"
  "https://projects-raspberry.com/storage/2015/09/Connecting-the-sensor-1.png"
  "https://projects-raspberry.com/storage/2015/09/Place-the-tape-around-the-chest-and-the-connector-placed-down.png"
  "https://projects-raspberry.com/storage/2015/09/Upload-the-code-and-watch-the-Serial-monitor.png"
  "https://projects-raspberry.com/storage/2015/09/Mobile-App.png"
  "https://projects-raspberry.com/storage/2015/09/GLCD-1.png"
  "https://projects-raspberry.com/storage/2015/09/GSR-sensor-features.png"
  "https://projects-raspberry.com/storage/2015/09/Sensor-Calibration.png"
  "https://projects-raspberry.com/storage/2015/09/multimeter.png"
  "https://projects-raspberry.com/storage/2015/09/Connecting-the-sensor-2.png"
  "https://projects-raspberry.com/storage/2015/09/The_galvanic_skin_sensor_has_two_contacts_and_it_works_like_a_ohmmeter.png"
)

OK=0; SKIP=0; FAIL=0

for URL in "${URLS[@]}"; do
  FNAME="${URL##*/}"
  DEST_FILE="$DEST/$FNAME"

  if [[ -f "$DEST_FILE" && $(wc -c < "$DEST_FILE") -gt 500 ]]; then
    echo "  SKIP  $FNAME"
    (( SKIP++ )) || true
    continue
  fi

  if curl -fsSL \
       --retry 3 --retry-delay 2 \
       -A "$UA" \
       -H "Referer: $REFERER" \
       -H "Accept: image/avif,image/webp,image/png,image/jpeg,*/*" \
       -o "$DEST_FILE" \
       "$URL"; then
    SIZE=$(wc -c < "$DEST_FILE")
    echo "  OK    $FNAME  (${SIZE} bytes)"
    (( OK++ )) || true
  else
    echo "  FAIL  $FNAME"
    rm -f "$DEST_FILE"
    (( FAIL++ )) || true
  fi
done

echo ""
echo "Done: $OK downloaded, $SKIP skipped, $FAIL failed"
echo "Images saved to: $DEST"

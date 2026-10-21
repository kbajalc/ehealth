#!/usr/bin/env python3
"""Read lines from an Arduino serial port and print them.

Requires pyserial: pip install pyserial

Usage:
    python3 misc/serial_read.py                  # auto-detect port, 9600 baud
    python3 misc/serial_read.py -p /dev/cu.usbserial-110 -b 115200
"""
import argparse
import glob
import sys

import serial


def find_port():
    # macOS: /dev/cu.usbmodem* (Uno R3) or /dev/cu.usbserial* (clones); Linux: ttyACM*/ttyUSB*
    patterns = ["/dev/cu.usbmodem*", "/dev/cu.usbserial*", "/dev/ttyACM*", "/dev/ttyUSB*"]
    for pattern in patterns:
        ports = sorted(glob.glob(pattern))
        if ports:
            return ports[0]
    return None


def main():
    parser = argparse.ArgumentParser(description="Read lines from an Arduino serial port and print them.")
    parser.add_argument("-p", "--port", help="serial port (default: auto-detect)")
    parser.add_argument("-b", "--baud", type=int, default=9600, help="baud rate (default: 9600)")
    args = parser.parse_args()

    port = args.port or find_port()
    if not port:
        sys.exit("No serial port found. Use -p to specify one.")

    print(f"Reading {port} at {args.baud} baud (Ctrl+C to stop)", file=sys.stderr)
    try:
        with serial.Serial(port, args.baud, timeout=1) as ser:
            while True:
                line = ser.readline()
                if line:
                    print(line.decode("utf-8", errors="replace").rstrip())
    except serial.SerialException as e:
        sys.exit(f"Serial error: {e}")
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()

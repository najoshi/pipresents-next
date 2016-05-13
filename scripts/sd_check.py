#!/usr/bin/env python

import os
import signal
import sys
import time
import RPi.GPIO as gpio
import subprocess

def signal_term_handler(signal, frame):
    gpio.cleanup()
    sys.exit(0)

def shutdown():
    gpio.cleanup()
    #subprocess.call("sudo shutdown -h now", shell=True)
    os.system ("sudo shutdown -h now")
    sys.exit(0)
    #subprocess.call("echo gotsignal >> /home/pi/tmp.out", shell=True)

gpio.setmode(gpio.BOARD)
PIN1 = 18

def main():
    gpio.setup(PIN1, gpio.IN, pull_up_down = gpio.PUD_DOWN)
    signal.signal(signal.SIGTERM, signal_term_handler)

    #subprocess.call("echo starting >> /home/pi/tmp.out", shell=True)

    if (gpio.input(PIN1)):
        has_input = True
    else:
        has_input = False

    while True:
        if (not has_input and gpio.input(PIN1)):
            has_input = True
            shutdown()

        if (has_input and not gpio.input(PIN1)):
            has_input = False
            shutdown()

        time.sleep(1)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        gpio.cleanup()

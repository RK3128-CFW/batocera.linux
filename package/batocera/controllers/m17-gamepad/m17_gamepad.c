// SPDX-License-Identifier: GPL-2.0-or-later
/*
 *      M17 gpio to M17 gamepad converter
 *
 *      Authors:
 *      Cesar Talon <ctalon@gmail.com> [@acmeplus]
 *
 *      v1.0 2023/10/31
 */
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <libevdev/libevdev.h>
#include <libevdev/libevdev-uinput.h>

int main() {
    int fd = open("/dev/input/event1", O_RDONLY);
    if (fd < 0) {
        perror("Failed to open device");
        return 1;
    }

    struct libevdev *original_dev = NULL;
    if (libevdev_new_from_fd(fd, &original_dev) < 0) {
        perror("Failed to init libevdev for original device");
        close(fd);
        return 1;
    }

    if (libevdev_grab(original_dev, LIBEVDEV_GRAB) < 0) {
        perror("Failed to grab original device");
        libevdev_free(original_dev);
        close(fd);
        return 1;
    }

    struct libevdev *virtual_dev = libevdev_new();
    libevdev_set_name(virtual_dev, "m17_gamepad");

    // Add gamepad capabilities
    libevdev_enable_event_type(virtual_dev, EV_KEY);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_A, NULL);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_B, NULL);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_X, NULL);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_Y, NULL);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_TL, NULL);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_TR, NULL);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_TL2, NULL);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_TR2, NULL);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_START, NULL);
    libevdev_enable_event_code(virtual_dev, EV_KEY, BTN_SELECT, NULL);

    // Add HAT switch capabilities
    libevdev_enable_event_type(virtual_dev, EV_ABS);
    struct input_absinfo absinfo = {.value = 0, .minimum = -1, .maximum = 1};
    libevdev_enable_event_code(virtual_dev, EV_ABS, ABS_HAT0X, &absinfo);
    libevdev_enable_event_code(virtual_dev, EV_ABS, ABS_HAT0Y, &absinfo);

    struct libevdev_uinput *uidev = NULL;
    if (libevdev_uinput_create_from_device(virtual_dev, LIBEVDEV_UINPUT_OPEN_MANAGED, &uidev) < 0) {
        perror("Failed to create uinput device");
        libevdev_grab(original_dev, LIBEVDEV_UNGRAB);
        libevdev_free(virtual_dev);
        libevdev_free(original_dev);
        close(fd);
        return 1;
    }

    struct input_event ev;
    while (1) {
        if (libevdev_next_event(original_dev, LIBEVDEV_READ_FLAG_NORMAL, &ev) < 0) {
            continue;
        }

        if (ev.type == EV_KEY || ev.type == EV_ABS) {
            int code = -1;
            int value = ev.value;
	        int event_type = EV_KEY;

            if (ev.code == KEY_A) {
                code = BTN_A;
            } else if (ev.code == KEY_B) {
                code = BTN_B;
            } else if (ev.code == KEY_X) {
                code = BTN_X;
            } else if (ev.code == KEY_Y) {
                code = BTN_Y;
            } else if (ev.code == KEY_L) {
                code = BTN_TL;
            } else if (ev.code == KEY_R) {
                code = BTN_TR;
            } else if (ev.code == KEY_C) {
                code = BTN_TL2;
            } else if (ev.code == KEY_Z) {
                code = BTN_TR2;
            } else if (ev.code == KEY_ENTER) {
                code = BTN_START;
            } else if (ev.code == KEY_RIGHTSHIFT) {
                code = BTN_SELECT;
            } else if (ev.code == KEY_UP) {
                code = ABS_HAT0Y;
                value = ev.value ? -1 : 0;
		        event_type = EV_ABS;
            } else if (ev.code == KEY_DOWN) {
                code = ABS_HAT0Y;
                value = ev.value ? 1 : 0;
                event_type = EV_ABS;
            } else if (ev.code == KEY_LEFT) {
                code = ABS_HAT0X;
                value = ev.value ? -1 : 0;
                event_type = EV_ABS;
            } else if (ev.code == KEY_RIGHT) {
                code = ABS_HAT0X;
                value = ev.value ? 1 : 0;
                event_type = EV_ABS;
            }

            if (code != -1) {
                // printf("Sending event: Type=%d, Code=%d, Value=%d\n", event_type, code, value);
                if (libevdev_uinput_write_event(uidev, event_type, code, value) < 0) {
                    fprintf(stderr, "Failed to send event to virtual device\n");
                }
                if (libevdev_uinput_write_event(uidev, EV_SYN, SYN_REPORT, 0) < 0) {
                    fprintf(stderr, "Failed to send syn report to virtual device\n");
                }

            }
        }
    }

    libevdev_uinput_destroy(uidev);
    libevdev_grab(original_dev, LIBEVDEV_UNGRAB);
    libevdev_free(virtual_dev);
    libevdev_free(original_dev);
    close(fd);
    
    return 0;
}



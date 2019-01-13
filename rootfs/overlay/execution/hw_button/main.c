/*
 * Copyright (C) 2018-2019 Hunan ChenHan Information Technology Co., Ltd.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

/**
 * @author Ding Tao <i@dingtao.org>
 *
 * @date 8th Nov, 2018
 *
 * @file main.c
 *
 * @brief If user depress the reboot button and hold it within a certain
 *	  period of time, then reboot the whole system; if user depress the
 *	  reset button and hold it within a certain period of time, then
 *	  mark "ch_need_reset" U-boot environment variable as 1, then reboot,
 *	  the U-boot will pass "ch_need_reset" to ramfs to make sure the user
 *	  config file will be all erased before re-entry the system.
 * */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <unistd.h>
#include <sys/types.h>
#include <fcntl.h>
#include <error.h>
#include <pthread.h>

#include <linux/input.h>
#include <linux/input-event-codes.h>

#define BTN_REBOOT	BTN_0
#define BTN_RESET	BTN_1

pthread_t reboot_wait_thread_id;
pthread_t reset_wait_thread_id;

void do_reboot(void)
{
	system("reboot");
	return ;
}

void do_reset(void)
{
	/**
	 * TODO
	 * Add a way to edit the U-boot environment
	 * */
	system("reboot");
	return ;
}

void* reboot_wait_thread_entry(void* arg)
{
	int ret;
	int time;

	time = *(int*)arg;

	/* Set current thread can be canceled */
	ret = pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
	if (0 != ret)
		return (void*)-1;
	/* Set current thread cancel immediately */
	ret = pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, NULL);
	if (0 != ret)
		return (void*)-1;

	/**
	 * Add pthread_testcancel to make sure this thread can be canceld
	 * during sleep time. Sleep specific time to wait user release the
	 * reboot button.
	 * */
	pthread_testcancel();
	sleep(time);
	pthread_testcancel();

	/**
	 * If this thread did not canceled by main thread, that means the user
	 * has depress the reboot button for specific time and never release
	 * it, so we can do a reboot at here.
	 * */
	do_reboot();

	/* Never reached */
	return (void*)NULL;
}

void* reset_wait_thread_entry(void* arg)
{
	int ret;
	int time;

	time = *(int*)arg;

	/* Set current thread can be canceled */
	ret = pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
	if (0 != ret)
		return (void*)-1;
	/* Set current thread cancel immediately */
	ret = pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, NULL);
	if (0 != ret)
		return (void*)-1;

	/**
	 * Add pthread_testcancel to make sure this thread can be canceld
	 * during sleep time. Sleep specific time to wait user release the
	 * reset button.
	 * */
	pthread_testcancel();
	sleep(time);
	pthread_testcancel();

	/**
	 * If this thread did not canceled by main thread, that means the user
	 * has depress the reset button for specific time and never release
	 * it, so we can do a reset at here.
	 * */
	do_reset();

	/* Never reached */
	return (void*)NULL;
}

int listining_loop(int fd, int time)
{
	struct input_event ie;
	int ret;

	while (1) {
		if ( sizeof(ie) == read(fd, &ie, sizeof(ie)) ) {
			if (EV_KEY == ie.type &&
			    BTN_REBOOT == ie.code &&
			    1 == ie.value) {
				/* Reboot button is depressed */
				ret = pthread_create(&reboot_wait_thread_id,
						     NULL,
						     reboot_wait_thread_entry,
						     (void*)&time);
				if (0 != ret) {
					perror("Can not create a thread!\n");
					continue;
				}
			} else if (EV_KEY == ie.type &&
				   BTN_REBOOT == ie.code &&
				   0 == ie.value) {
				/* Reboot button is released */
				ret = pthread_cancel(reboot_wait_thread_id);
				if (0 != ret) {
					perror("Can not cancel a thread!\n");
					continue;
				}
			} else if (EV_KEY == ie.type &&
				   BTN_RESET == ie.code &&
				   1 == ie.value) {
				/* Reset button is depressed */
				ret = pthread_create(&reset_wait_thread_id,
						     NULL,
						     reset_wait_thread_entry,
						     (void*)&time);
				if (0 != ret) {
					perror("Can not create a thread!\n");
					continue;
				}
			} else if (EV_KEY == ie.type &&
				   BTN_RESET == ie.code &&
				   0 == ie.value) {
				/* Reset button is released */
				ret = pthread_cancel(reset_wait_thread_id);
				if (0 != ret) {
					perror("Can not cancel a thread!\n");
					continue;
				}
			}
		}
	}
	return 0;
}

void print_usage(void)
{
	printf("Usage: hw_button <dev> <time in second>\n"
	       "    <dev>:            The <dev> must use the input event "
	       "device like /dev/input/event0\n"
	       "    <time in second>: The <time in second> used to specifiy "
	       "certain period of time, suggest 5 seconds");
}

int main(int argc, char *argv[])
{
	int reset_button_fd;
	int time_in_second;

	if ( 3 != argc ) {
		print_usage();
		return -1;
	}

	reset_button_fd = open(argv[1], O_RDONLY);
	if ( reset_button_fd <= 0 ) {
		printf("Can not open device %s!\n", argv[1]);
		print_usage();
		return -1;
	}

	time_in_second = atoi(argv[2]);
	if ( time_in_second <= 0 ) {
		printf("Wrong argument: %s!\n", argv[2]);
		print_usage();
		return -1;
	}

	return listining_loop(reset_button_fd, time_in_second);
}


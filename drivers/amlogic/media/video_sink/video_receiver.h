/*
 * drivers/amlogic/media/video_sink/video_receiver.h
 *
 * Copyright (C) 2017 Amlogic, Inc. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 */

#ifndef VIDEO_RECEIVER_HEADER_HH
#define VIDEO_RECEIVER_HEADER_HH

#include <linux/amlogic/media/vfm/vframe.h>

struct video_layer_s;

struct recv_func_s {
	s32 (*early_proc)(struct video_recv_s *ins);
	struct vframe_s *(*dequeue_frame)(struct video_recv_s *ins);
	s32 (*return_frame)(struct video_recv_s *ins, struct vframe_s *vf);
	s32 (*late_proc)(struct video_recv_s *ins);
};

struct video_recv_s {
	char *recv_name;
	/* recv lock */
	spinlock_t lock;
	struct vframe_receiver_s handle;
	struct vframe_receiver_op_s *vf_ops;
	struct vframe_s local_buf;
	struct vframe_s *cur_buf;
	struct vframe_s *rdma_buf;
	struct vframe_s *buf_to_put;

	bool active;

	u32 notify_flag;
	u32 blackout;
	u32 frame_count;
	u32 drop_vf_cnt;
	u8 path_id;
	struct recv_func_s *func;
};

struct video_recv_s *create_video_receiver(const char *recv_name, u8 path_id);
void destroy_video_receiver(struct video_recv_s *ins);

#endif

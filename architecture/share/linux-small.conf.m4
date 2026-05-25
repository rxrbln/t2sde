dnl --- T2-COPYRIGHT-BEGIN ---
dnl t2/architecture/share/linux-small.conf.m4
dnl Copyright (C) 2022 - 2026 The T2 SDE Project
dnl SPDX-License-Identifier: GPL-2.0
dnl --- T2-COPYRIGHT-END ---

CONFIG_EXPERT=y

CONFIG_PREEMPT_NONE=y
CONFIG_HZ_PERIODIC=y
# CONFIG_HIGH_RES_TIMERS is not set

CONFIG_LOG_BUF_SHIFT=14

# CONFIG_NAMESPACES is not set
# CONFIG_IO_URING is not set
# CONFIG_MEMBARRIER is not set

# CONFIG_DEBUG_KERNEL is not set
# RUNTIME_TESTING_MENU is not set
# CONFIG_KALLSYMS is not set
# CONFIG_BPF is not set
# CONFIG_COMPACTION is not set
# CONFIG_KSM is not set
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_DEBUG_FS is not set

# CONFIG_FONT_TER16x32 is not set

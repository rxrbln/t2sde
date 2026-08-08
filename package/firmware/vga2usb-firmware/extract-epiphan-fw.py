#!/usr/bin/env python3
# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/vga2usb-firmware/extract-epiphan-fw.py
# Copyright (C) 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

# Copyright (C) 2026 Rene Rebe <rene@exactco.de>

# Extract the FPGA bitstreams and the Cypress EZ-USB firmware images
# embedded in Epiphan's proprietary vga2usb_bins.o into standalone files
# for request_firmware().
#
# FPGA container layout, recovered from fpga_firmware_alloc()/free() and
# v2ucom_grab_io_fpga_download() (.text+0x182a0):
#
#   struct fpga_firmware {          /* the fpga_firmware_* symbols */
#       const struct fw_segment *segs;  /* +0x00, relocation */
#       u32 nsegs;                      /* +0x08 */
#       u32 kind;                       /* +0x0c, bits consumed per source byte */
#       u64 total_size;                 /* +0x10, decompressed bytes */
#   };
#   struct fw_segment {             /* 0x18 bytes; stride confirmed by
#       u32 bits;                    * fpga_firmware_free()'s index*3*8 walk */
#       u32 pad;                        /* +0x04 */
#       const void *data;               /* +0x08, relocation */
#       u32 comp_size;                  /* +0x10 */
#       u32 method;                     /* +0x14, 0=none 1=rle 2=zlib */
#   };
#
# kind == 8: the decompressed segments are the raw bitstream, sent to the
# FPGA eight bits per byte.
#
# kind == 4: only four bits per byte are consumed, and the segments are a
# JTAG bit-bang script rather than a bitstream.  Each byte carries four TCK
# cycles in bit pairs, LSB pair first: even bits (mask 0x55) are TDI, odd
# bits (mask 0xaa) are TMS.  Replaying the TAP state machine yields the
# usual IDCODE / JPROGRAM / CFG_IN / JSTART sequence; the configuration
# data is the TDI of the long Shift-DR block, packed LSB-first.
#
# EZ-USB container layout, recovered from usb_board_download_firmware()
# (.text+0x1e30, "v2ucom_download_firmware_mem") - reached through the
# board descriptor field usb_board_*+0x28:
#
#   struct usb_fw {
#       u16 type;                       /* +0x00, 1 = EZ-USB FX2, 2 = FX3 */
#       u16 version;                    /* +0x02, checked against bcdDevice */
#       ...
#       u32 fpga_id;                    /* +0x14, checked with request 0xC6 */
#       u32 nrecs;                      /* +0x18 */
#       const struct fw_record *recs;   /* +0x20, relocation */
#   };
#   struct fw_record {              /* 0x18 bytes */
#       u32 addr;                       /* +0x00, wValue|wIndex of request 0xA0 */
#       u32 len;                        /* +0x04, decompressed bytes */
#       u32 comp_size;                  /* +0x08 */
#       u32 method;                     /* +0x0c, 0=none 1=rle 2=zlib */
#       const void *data;               /* +0x10, relocation */
#   };
#
# The records go out with the standard Cypress vendor request 0xA0 in
# 64-byte chunks; a record with data == NULL and len == 0 terminates an FX3
# image and its addr is the program entry point.

import argparse
import os
import re
import struct
import subprocess
import sys
import zlib

DEFAULT_OBJ = "usr/src/vga2usb-3.33.0.17/vga2usb_bins.o_shipped"
OUTDIR = "firmware/epiphan"

METHOD_NONE, METHOD_RLE, METHOD_ZLIB = 0, 1, 2

FW_FX2, FW_FX3 = 1, 2

# The Xilinx sync word, bit-reversed per byte the way the parts are fed.
XILINX_SYNC = bytes.fromhex("ffffffff5599aa66")

# Descriptor symbol -> file name under /lib/firmware/epiphan/
FIRMWARES = {
    "fpga_firmware_dvi2usb3":     "dvi2usb3.fpga",
    "fpga_firmware_dvi2usb3_rle": "dvi2usb3-usb2.fpga",
    "fpga_firmware_sdi2usb3":     "sdi2usb3.fpga",
    "fpga_firmware_sdi2usb3_rle": "sdi2usb3-usb2.fpga",
    "fpga_firmware_duo":          "dvi2usb-duo.fpga",
    "fpga_firmware_plus":         "dvi2usb-plus.fpga",
    "fpga_firmware_lr":           "vga2usb-lr.fpga",
    "fpga_firmware_lr_respin":    "vga2usb-lr-respin.fpga",
    "fpga_firmware_pror1":        "dvi2usb-r1.fpga",
    "fpga_firmware_pror2":        "dvi2usb-r2.fpga",
}

# One board symbol per distinct usb_fw descriptor -> file name.  Boards
# sharing a descriptor are reported as aliases.
EZUSB = {
    "usb_board_dvi2usb3_usb3":   "dvi2usb3.fx3",
    "usb_board_sdi2usb3_usb3":   "sdi2usb3.fx3",
    "usb_board_dvi2usb":         "dvi2usb.fx2",
    "usb_board_dvi2usbduo":      "dvi2usb-duo.fx2",
    "usb_board_dvi2usbrespin":   "dvi2usb-respin.fx2",
    "usb_board_kvm2usb":         "kvm2usb.fx2",
    "usb_board_vga2usb":         "vga2usb.fx2",
    "usb_board_vga2usblr":       "vga2usb-lr.fx2",
    "usb_board_vga2usblrrespin": "vga2usb-lr-respin.fx2",
}


def section(obj, want):
    out = subprocess.run(["readelf", "-S", "-W", obj],
                         capture_output=True, text=True, check=True).stdout
    for line in out.splitlines():
        m = re.match(r"\s*\[\s*\d+\]\s+(\S+)\s+\S+\s+([0-9a-f]+)\s+([0-9a-f]+)\s+([0-9a-f]+)",
                     line)
        if m and m.group(1) == want:
            return int(m.group(3), 16), int(m.group(4), 16)
    raise SystemExit(f"{obj}: section {want} not found")


def symbols(obj):
    out = subprocess.run(["nm", "--defined-only", obj],
                         capture_output=True, text=True, check=True).stdout
    syms = {}
    for line in out.splitlines():
        f = line.split()
        if len(f) == 3:
            syms[f[2]] = int(f[0], 16)
    return syms


def self_relocs(obj):
    """.rodata offset -> .rodata addend, for pointers internal to .rodata"""
    out = subprocess.run(["readelf", "-r", "-W", obj],
                         capture_output=True, text=True, check=True).stdout
    cur, rel = None, {}
    for line in out.splitlines():
        m = re.match(r"Relocation section '\.rela(\S+)'", line)
        if m:
            cur = m.group(1)
            continue
        if cur != ".rodata":
            continue
        m = re.match(r"([0-9a-f]{8,})\s+\S+\s+R_X86_64_64\s+[0-9a-f]+\s+(\S+)\s*\+\s*(\S+)",
                     line.strip())
        if m and m.group(2) == ".rodata":
            rel[int(m.group(1), 16)] = int(m.group(3), 16)
    return rel


def rle_decode(src, out_len):
    """Epiphan RLE, transcribed from the decompressor at .text+0x16bf0.

    A byte repeated twice introduces a run; the byte after the pair is the
    count of additional copies, and the state resets so that a run can be
    followed immediately by another pair.
    """
    out = bytearray()
    state, rep, last, i = 0, 0, 0, 0
    while len(out) < out_len:
        while rep > 0 and len(out) < out_len:
            out.append(last)
            rep -= 1
        if i >= len(src) or len(out) >= out_len:
            break
        c = src[i]
        i += 1
        if state == 0:
            out.append(c)
            last = c
            state = 1
        elif state == 1:
            out.append(c)
            if c == last:
                state = 2
            else:
                last = c
        else:
            rep = c
            state = 0
    return bytes(out)


def decode_segment(blob, seg_data_off, comp_size, method, want):
    raw = blob[seg_data_off:seg_data_off + comp_size]
    if method == METHOD_ZLIB:
        # Must feed exactly comp_size bytes: the stream is followed directly by
        # unrelated .rodata and over-feeding corrupts the final block.
        return zlib.decompressobj().decompress(raw)
    if method == METHOD_NONE:
        return raw
    if method == METHOD_RLE:
        return rle_decode(raw, want)
    raise ValueError(f"unknown compression method {method}")


# JTAG TAP: state -> (next on TMS=0, next on TMS=1)
TAP = {
    "TLR":   ("RTI",   "TLR"),   "RTI":   ("RTI",   "SelDR"),
    "SelDR": ("CapDR", "SelIR"), "CapDR": ("ShDR",  "Ex1DR"),
    "ShDR":  ("ShDR",  "Ex1DR"), "Ex1DR": ("PauDR", "UpdDR"),
    "PauDR": ("PauDR", "Ex2DR"), "Ex2DR": ("ShDR",  "UpdDR"),
    "UpdDR": ("RTI",   "SelDR"), "SelIR": ("CapIR", "TLR"),
    "CapIR": ("ShIR",  "Ex1IR"), "ShIR":  ("ShIR",  "Ex1IR"),
    "Ex1IR": ("PauIR", "UpdIR"), "PauIR": ("PauIR", "Ex2IR"),
    "Ex2IR": ("ShIR",  "UpdIR"), "UpdIR": ("RTI",   "SelDR"),
}


def jtag_shift_dr(segments):
    """Replay a (TDI,TMS) bit-bang script, return the longest Shift-DR run."""
    state, cur, best = "TLR", [], []
    for data, nclocks in segments:
        n = 0
        for byte in data:
            if n >= nclocks:
                break
            for shift in (0, 2, 4, 6):
                if n >= nclocks:
                    break
                n += 1
                if state == "ShDR":
                    cur.append((byte >> shift) & 1)
                elif cur:
                    best, cur = max(best, cur, key=len), []
                state = TAP[state][(byte >> (shift + 1)) & 1]
    return max(best, cur, key=len)


def pack_lsb_first(bits, start, count):
    out = bytearray()
    for i in range(start, start + count * 8, 8):
        v = 0
        for j in range(8):
            v |= bits[i + j] << j
        out.append(v)
    return bytes(out)


def bitstream_from_jtag(bits):
    """Cut the Xilinx bitstream out of a Shift-DR capture.

    The generator pads the front of the shift so the whole script is a whole
    number of bytes, and the tail bits are eaten by the bypass registers of
    the other devices in the chain, so neither end is byte aligned.  The sync
    word gives the alignment; everything before it is the pre-sync preamble
    the FPGA ignores anyway.
    """
    want = "".join(f"{b:08b}"[::-1] for b in XILINX_SYNC)
    pos = "".join(str(b) for b in bits).find(want)
    if pos < 0:
        raise ValueError("no Xilinx sync word in the Shift-DR data")
    return pack_lsb_first(bits, pos, (len(bits) - pos) // 8)


def extract_fpga(rodata, rel, desc, verbose):
    segs_off = rel.get(desc)
    if segs_off is None:
        raise ValueError("no relocation for segment array")

    nsegs, kind = struct.unpack_from("<II", rodata, desc + 0x08)
    total = struct.unpack_from("<Q", rodata, desc + 0x10)[0]
    if kind not in (4, 8):
        raise ValueError(f"unsupported container variant (kind {kind}, {nsegs} segments)")

    pieces = []
    for i in range(nsegs):
        seg = segs_off + i * 0x18
        bits = struct.unpack_from("<I", rodata, seg)[0]
        comp_size, method = struct.unpack_from("<II", rodata, seg + 0x10)
        data_off = rel.get(seg + 0x08)
        if data_off is None:
            raise ValueError(f"segment {i}: no relocation for data pointer")
        want = -(-bits // kind)
        piece = decode_segment(rodata, data_off, comp_size, method, want)
        if len(piece) != want:
            raise ValueError(f"segment {i}: got {len(piece)} bytes, expected {want}")
        if verbose:
            print(f"      seg {i}: {comp_size} -> {want} bytes, {bits} bits, "
                  f"method {method}, at .rodata+0x{data_off:x}")
        pieces.append((piece, bits))

    if sum(len(p) for p, _ in pieces) != total:
        raise ValueError(f"total {sum(len(p) for p, _ in pieces)} bytes, "
                         f"descriptor says {total}")

    if kind == 8:
        return b"".join(p for p, _ in pieces), kind
    return bitstream_from_jtag(jtag_shift_dr(pieces)), kind


def fw_records(rodata, rel, desc, verbose):
    """Decode a usb_fw descriptor into (type, [(addr, data), ...], entry)."""
    fwtype = struct.unpack_from("<H", rodata, desc)[0]
    nrecs = struct.unpack_from("<I", rodata, desc + 0x18)[0]
    recs_off = rel.get(desc + 0x20)
    if recs_off is None:
        raise ValueError("no relocation for record array")

    out, entry = [], None
    for i in range(nrecs):
        rec = recs_off + i * 0x18
        addr, length, comp_size, method = struct.unpack_from("<IIII", rodata, rec)
        data_off = rel.get(rec + 0x10)
        if data_off is None:
            entry = addr
            continue
        piece = decode_segment(rodata, data_off, comp_size, method, length)
        if len(piece) != length:
            raise ValueError(f"record {i}: got {len(piece)} bytes, expected {length}")
        if verbose:
            print(f"      rec {i:2}: 0x{addr:08x} {comp_size} -> {length} bytes, "
                  f"method {method}, at .rodata+0x{data_off:x}")
        out.append((addr, piece))
    return fwtype, out, entry


def build_fx2(records):
    """Flatten the 8051 records into an image starting at code address 0.

    The records tile the code space except for the unused interrupt vector
    slots and the padding ahead of the first routine, so zero fill is safe.
    """
    size = max(a + len(d) for a, d in records)
    img = bytearray(size)
    for addr, data in records:
        img[addr:addr + len(data)] = data
    if img[0] != 0x02:
        raise ValueError("image does not start with an 8051 LJMP")
    return bytes(img)


def build_fx3(records, entry):
    """Wrap the sections back into a Cypress FX3 boot image.

    bImageCTL is not kept by the driver - it only matters when the part boots
    from I2C/SPI, so it is emitted as zero.
    """
    if entry is None:
        raise ValueError("no terminator record, program entry point unknown")
    img = bytearray(b"CY\x00\xb0")
    csum = 0
    for addr, data in records:
        if len(data) % 4:
            raise ValueError(f"section 0x{addr:08x} is not a whole number of words")
        img += struct.pack("<II", len(data) // 4, addr) + data
        csum += sum(struct.unpack(f"<{len(data) // 4}I", data))
    img += struct.pack("<III", 0, entry, csum & 0xFFFFFFFF)
    return bytes(img)


def main():
    ap = argparse.ArgumentParser(
        description="Extract Epiphan FPGA and EZ-USB firmware from vga2usb_bins.o")
    ap.add_argument("-o", "--outdir", default=OUTDIR)
    ap.add_argument("-v", "--verbose", action="store_true")
    ap.add_argument("object", nargs="?", default=DEFAULT_OBJ)
    args = ap.parse_args()

    if not os.path.exists(args.object):
        raise SystemExit(f"{args.object}: not found")

    ro_off, ro_size = section(args.object, ".rodata")
    with open(args.object, "rb") as f:
        f.seek(ro_off)
        rodata = f.read(ro_size)

    syms = symbols(args.object)
    rel = self_relocs(args.object)

    os.makedirs(args.outdir, exist_ok=True)
    print(f"extracting from {args.object}")

    ok, want = 0, len(FIRMWARES) + len(EZUSB)

    for sym, fname in sorted(FIRMWARES.items()):
        if sym not in syms:
            if args.verbose:
                print(f"   {sym}: not present")
            continue
        try:
            data, kind = extract_fpga(rodata, rel, syms[sym], args.verbose)
            # Some images carry a longer run of 0xff dummy words ahead of it.
            if XILINX_SYNC not in data[:64]:
                raise ValueError("no Xilinx sync word at the start of the bitstream")
        except Exception as e:
            print(f"   {sym}: NOT DECODED: {e}", file=sys.stderr)
            continue
        with open(os.path.join(args.outdir, fname), "wb") as f:
            f.write(data)
        print(f"   {fname:24} {len(data):>9} bytes  FPGA bitstream (kind {kind})")
        ok += 1

    for sym, fname in sorted(EZUSB.items()):
        if sym not in syms:
            if args.verbose:
                print(f"   {sym}: not present")
            continue
        desc = rel.get(syms[sym] + 0x28)
        if desc is None:
            print(f"   {sym}: NOT DECODED: no usb_fw descriptor", file=sys.stderr)
            continue
        try:
            fwtype, records, entry = fw_records(rodata, rel, desc, args.verbose)
            if fwtype == FW_FX2:
                data, what = build_fx2(records), "EZ-USB FX2 8051 image"
            elif fwtype == FW_FX3:
                data, what = build_fx3(records, entry), "Cypress FX3 boot image"
            else:
                raise ValueError(f"unknown firmware type {fwtype}")
        except Exception as e:
            print(f"   {sym}: NOT DECODED: {e}", file=sys.stderr)
            continue
        with open(os.path.join(args.outdir, fname), "wb") as f:
            f.write(data)
        print(f"   {fname:24} {len(data):>9} bytes  {what}")
        ok += 1

    print(f"{ok}/{want} firmware image(s) written to {args.outdir}/")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())

diff -dNur pcd-0.0.3-orig/pcd_i18n.c pcd-0.0.3/pcd_i18n.c
--- pcd-0.0.3-orig/pcd_i18n.c	2003-10-05 12:02:40.000000000 +0200
+++ pcd/pcd_i18n.c	2004-06-11 15:57:08.000000000 +0200
@@ -223,4 +223,3 @@
   },
   { NULL }
   };
-
diff -dNur pcd-0.0.3-orig/pcd_menu.c pcd-0.0.3/pcd_menu.c
--- pcd-0.0.3-orig/pcd_menu.c	2003-05-18 18:17:52.000000000 +0200
+++ pcd/pcd_menu.c	2004-06-11 15:50:05.000000000 +0200
@@ -22,6 +22,9 @@
 
 class cPcdControl : cPcdViewerControl {
 private:
+#if VDRVERSNUM >= 10307
+  cSkinDisplayReplay *display;
+#endif
   bool visible, modeOnly;
   static int image;
   static cPCD *pcd;
@@ -39,6 +42,9 @@
 cPcdControl::cPcdControl(void)
 : cPcdViewerControl(image, pcd)
 {
+#if VDRVERSNUM >= 10307
+  display = NULL;
+#endif
   visible = modeOnly = false;
 }
 
@@ -64,7 +70,11 @@
 void cPcdControl::Hide(void)
 {
   if (visible) {
+#if VDRVERSNUM >= 10307
+     delete display;
+#else
      Interface->Close();
+#endif
      needsFastResponse = visible = false;
      modeOnly = false;
      }
diff -dNur pcd-0.0.3-orig/pcd_menu.h pcd-0.0.3/pcd_menu.h
--- pcd-0.0.3-orig/pcd_menu.h	2003-02-12 22:13:29.000000000 +0100
+++ pcd/pcd_menu.h	2004-06-11 15:47:00.000000000 +0200
@@ -14,7 +14,12 @@
 #ifndef __PCD_MENU_H
 #define __PCD_MENU_H
 
+#include <vdr/config.h>
+#if VDRVERSNUM >= 10307
+#include <vdr/osdbase.h>
+#else
 #include <vdr/osd.h>
+#endif
 #include "pcd_func.h"
 #include "pcd_viewer.h"
 
diff -dNur pcd-0.0.3-orig/pcd_mpeg.c pcd-0.0.3/pcd_mpeg.c
--- pcd-0.0.3-orig/pcd_mpeg.c	2003-10-05 16:19:42.000000000 +0200
+++ pcd/pcd_mpeg.c	2004-06-11 15:56:04.000000000 +0200
@@ -19,6 +19,7 @@
 #define STARTCODE_SIZE    6
 #define PTS_SIZE          5
 #define PACKET_DATA_SIZE  0x2000
+#define DEFAULT_FRAME_RATE_BASE 1001000
 
 
 // --- cMpegFrame ------------------------------------------------------------
@@ -48,7 +49,7 @@
   avContext->bit_rate = 400000;
   avContext->width = width;
   avContext->height = height;
-  avContext->frame_rate = (pal ? 25 : 30) * FRAME_RATE_BASE;
+  avContext->frame_rate = (pal ? 25 : 30) * DEFAULT_FRAME_RATE_BASE;
   avContext->gop_size = 1;
   avContext->flags |= CODEC_FLAG_QSCALE;
 
diff -dNur pcd-0.0.3-orig/pcd_viewer.c pcd-0.0.3/pcd_viewer.c
--- pcd-0.0.3-orig/pcd_viewer.c	2003-05-18 20:46:40.000000000 +0200
+++ pcd/pcd_viewer.c	2004-06-11 15:53:58.000000000 +0200
@@ -435,7 +435,11 @@
   else
      tick = PcdSetupData.SlideInterval;
   dsyslog("PCD: slideshow %s", tick>-1 ? "on" : "off");
+#if VDRVERSNUM >= 10307
+  Skins.Message(mtInfo, tick>-1 ? tr("Slideshow on") : tr("Slideshow off"));
+#else
   Interface->Info(tick>-1 ? tr("Slideshow on") : tr("Slideshow off"));
+#endif
 }
 
 bool cPcdViewer::SkipImages(int Images)

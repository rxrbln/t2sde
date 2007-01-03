diff -ruN vcd-0.0.6c/vcd.c vcd-0.0.6c-work/vcd.c
--- vcd-0.0.6c/vcd.c	2003-11-24 19:48:28.000000000 +0100
+++ vcd-0.0.6c-work/vcd.c	2004-06-18 12:20:09.178647561 +0200
@@ -175,7 +175,11 @@
               }
            }
         else
-           Interface->Info(tr("No VideoCD detected"));
+#if VDRVERSNUM >= 10307
+					Skins.Message(mtInfo, tr("No VideoCD detected"));
+#else
+					Interface->Info(tr("No VideoCD detected"));
+#endif
         }
      else {
         if (VcdSetupData.PlaySequenceReplay && psd_size) {
@@ -186,7 +190,11 @@
         }
      }
   else
-     Interface->Info(tr("No disc inserted"));
+#if VDRVERSNUM >= 10307
+		Skins.Message(mtInfo, tr("No disc inserted"));
+#else
+		Interface->Info(tr("No disc inserted"));
+#endif
 
   return NULL;
 }
diff -ruN vcd-0.0.6c/vcd_menu_control.c vcd-0.0.6c-work/vcd_menu_control.c
--- vcd-0.0.6c/vcd_menu_control.c	2003-11-01 14:19:38.000000000 +0100
+++ vcd-0.0.6c-work/vcd_menu_control.c	2004-06-18 12:20:09.181647311 +0200
@@ -33,6 +33,9 @@
 cMenuSpiControl::cMenuSpiControl(void)
 : cVcdViewerControl(spi, vcd)
 {
+#if VDRVERSNUM >= 10307
+	display = NULL;
+#endif
   visible = modeOnly = false;
 }
 
@@ -61,7 +64,11 @@
 void cMenuSpiControl::Hide(void)
 {
   if (visible) {
+#if VDRVERSNUM >= 10307
+		 delete display;
+#else
      Interface->Close();
+#endif
      needsFastResponse = visible = false;
      modeOnly = false;
      }
@@ -106,7 +113,7 @@
 class cVcdProgressBar : public cBitmap {
  protected:
     int total;
-    int Pos(int p) { return p * width / total; }
+    int Pos(int p) { return p * cBitmap::Width() / total; }
  public:
     cVcdProgressBar(int Width, int Height, int Current, int Total);
 };
@@ -114,12 +121,14 @@
 cVcdProgressBar::cVcdProgressBar(int Width, int Height, int Current, int Total)
 :cBitmap(Width, Height, 2)
 {
+#if VDRVERSNUM < 10307
   total = Total;
   if (total > 0) {
      int p = Pos(Current);
      Fill(0, 0, p, Height - 1, clrGreen);
      Fill(p + 1, 0, Width - 1, Height - 1, clrWhite);
   }
+#endif
 }
 
 
@@ -133,6 +142,9 @@
 cMenuVcdControl::cMenuVcdControl(void)
 : cVcdPlayerControl(track, vcd)
 {
+#if VDRVERSNUM >= 10307
+	display = NULL;
+#endif
   visible = modeOnly = shown = displayFrames = false;
   timeoutShow = 0;
   timeSearchActive = false;
@@ -183,7 +195,11 @@
 void cMenuVcdControl::Hide(void)
 {
   if (visible) {
+#if VDRVERSNUM >= 10307
+		 delete display;
+#else
      Interface->Close();
+#endif
      needsFastResponse = visible = false;
      modeOnly = false;
      }
@@ -191,6 +207,7 @@
 
 void cMenuVcdControl::DisplayAtBottom(const char *s)
 {
+#if VDRVERSNUM < 10307
   if (s) {
      int w = cOsd::WidthInCells(s);
      int d = max(Width() - w, 0) / 2;
@@ -201,6 +218,7 @@
      }
   else
      Interface->Fill(12, 2, Width() - 22, 1, clrBackground);
+#endif
 }
 
 void cMenuVcdControl::ShowMode(void)
@@ -219,7 +237,11 @@
            Interface->Open(9, -1);
            Interface->Clear();
            XXX*/
+#if VDRVERSNUM >= 10307
+					 display = Skins.Current()->DisplayReplay(false);
+#else
            Interface->Open(0, -1); //XXX remove when displaying replay mode differently
+#endif
            visible = modeOnly = true;
            }
 
@@ -235,9 +257,13 @@
         if (p)
            *p = Speed > 0 ? '1' + Speed - 1 : ' ';
 
+#if VDRVERSNUM >= 10307
+				display->SetMode(Play, Forward, Speed);
+#else
         eDvbFont OldFont = Interface->SetFont(fontFix);
         DisplayAtBottom(buf);
         Interface->SetFont(OldFont);
+#endif
         }
      }
 }
@@ -248,19 +274,35 @@
 
   if (GetIndex(Current, Total) && Total > 0) {
      if (!visible) {
+#if VDRVERSNUM >= 10307
+			  display = Skins.Current()->DisplayReplay(false);
+#else
         Interface->Open(Setup.OSDwidth, -3);
+#endif
         needsFastResponse = visible = true;
         }
      if (Initial) {
+#if VDRVERSNUM < 10307
         Interface->Clear();
+#endif
         lastCurrent = lastTotal = -1;
         }
      if (title) 
+#if VDRVERSNUM >= 10307
+				display->SetTitle(title);
+#else
         Interface->Write(0, 0, title);
+#endif
      if (Total != lastTotal) {
+#if VDRVERSNUM >= 10307
+				display->SetTotal(IndexToHMSF(Total));
+        if (!Initial)
+					Skins.Flush();
+#else
         Interface->Write(-7, 2, IndexToHMSF(Total));
         if (!Initial)
            Interface->Flush();
+#endif
         }
      if (Current != lastCurrent || Total != lastTotal) {
 #ifdef DEBUG_OSD
@@ -268,13 +310,24 @@
         Interface->Fill(0, 1, p, 1, clrGreen);
         Interface->Fill(p, 1, Width() - p, 1, clrWhite);
 #else
+#if VDRVERSNUM >= 10307
+				display->SetProgress(Current, Total);
+        if (!Initial)
+					Skins.Flush();
+#else
         cVcdProgressBar ProgressBar(Width() * cOsd::CellWidth(), cOsd::LineHeight(), Current, Total);
         Interface->SetBitmap(0, cOsd::LineHeight(), ProgressBar);
         if (!Initial)
            Interface->Flush();
 #endif
+#endif
+#if VDRVERSNUM >= 10307
+				display->SetCurrent(IndexToHMSF(Current, displayFrames));
+				Skins.Flush();
+#else
         Interface->Write(0, 2, IndexToHMSF(Current, displayFrames));
         Interface->Flush();
+#endif
         lastCurrent = Current;
         }
      lastTotal = Total;
@@ -298,7 +351,11 @@
   char cm10 = timeSearchPos > 1 ? m10 : '-';
   char cm1  = timeSearchPos > 0 ? m1  : '-';
   sprintf(buf + len, "%c%c:%c%c", ch10, ch1, cm10, cm1);
+#if VDRVERSNUM >= 10307
+	display->SetJump(buf);
+#else
   DisplayAtBottom(buf);
+#endif
 }
 
 void cMenuVcdControl::TimeSearchProcess(eKeys Key)
@@ -451,8 +508,10 @@
      }
   if (DoShowMode)
      ShowMode();
+#if VDRVERSNUM < 10307
   if (DisplayedFrames && !displayFrames)
      Interface->Fill(0, 2, 11, 1, clrBackground);
+#endif
   return osContinue;
 }
 
diff -ruN vcd-0.0.6c/vcd_menu_control.h vcd-0.0.6c-work/vcd_menu_control.h
--- vcd-0.0.6c/vcd_menu_control.h	2003-10-21 22:01:57.000000000 +0200
+++ vcd-0.0.6c-work/vcd_menu_control.h	2004-06-18 12:20:09.183647144 +0200
@@ -18,6 +18,9 @@
 
 class cMenuSpiControl : public cVcdViewerControl {
 private:
+#if VDRVERSNUM >= 10307
+	cSkinDisplayReplay *display;
+#endif
   bool visible, modeOnly;
   static int spi;
   static cVcd *vcd;
@@ -34,6 +37,9 @@
 
 class cMenuVcdControl : public cVcdPlayerControl {
 private:
+#if VDRVERSNUM >= 10307
+	cSkinDisplayReplay *display;
+#endif
   bool visible, modeOnly, shown, displayFrames;
   time_t timeoutShow;
   bool timeSearchActive, timeSearchHide;
diff -ruN vcd-0.0.6c/vcd_psd.h vcd-0.0.6c-work/vcd_psd.h
--- vcd-0.0.6c/vcd_psd.h	2003-10-22 13:21:17.000000000 +0200
+++ vcd-0.0.6c-work/vcd_psd.h	2004-06-18 12:20:09.185646977 +0200
@@ -14,7 +14,12 @@
 #define __VCD_PSD_H
 
 
+#include <vdr/config.h>
+#if VDRVERSNUM >= 10307
+#include <vdr/osdbase.h>
+#else
 #include <vdr/osd.h>
+#endif
 #include "vcd_func.h"
 
 

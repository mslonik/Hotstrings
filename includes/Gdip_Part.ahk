; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_Startup(multipleInstances:=0) {
	pToken := 0
	If (multipleInstances=0)
	{
	   if !DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
		 DllCall("LoadLibrary", "str", "gdiplus")
	} Else DllCall("LoadLibrary", "str", "gdiplus")
  
	VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", "UPtr*", pToken, "UPtr", &si, "UPtr", 0)
	return pToken
  }
  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Gdip_Shutdown(pToken) {
	DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
	hModule := DllCall("GetModuleHandle", "Str", "gdiplus", "UPtr")
	if hModule
	   DllCall("FreeLibrary", "UPtr", hModule)
	return 0
  }
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  Gdip_DisposeImage(pBitmap, noErr:=0) {
	; modified by Marius Șucan to help avoid crashes 
	; by disposing a non-existent pBitmap
	
	   If (StrLen(pBitmap)<=2 && noErr=1)
		 Return 0
	
	   r := DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
	   If (r=2 || r=1) && (noErr=1)
		 r := 0
	   Return r
	}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_SetBitmapToClipboard(pBitmap, hBitmap := 0) {
	local	;added by ms, force-local; warning related to E
; modified by Marius Șucan to have this function report errors
; you can feed this function a hBitmap directly
; return value: 0 = succes

   off1 := A_PtrSize = 8 ? 52 : 44
   off2 := A_PtrSize = 8 ? 32 : 24
   r1 := DllCall("OpenClipboard", "UPtr", 0)
   If !r1
      Return -1

   If !hBitmap
   {
      If pBitmap
         hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap, 0)
   }

   If !hBitmap
   {
      DllCall("CloseClipboard")
      Return -3
   }

   r2 := DllCall("EmptyClipboard")
   If !r2
   {
      DeleteObject(hBitmap)
      DllCall("CloseClipboard")
      Return -2
   }

   DllCall("GetObject", "UPtr", hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), "UPtr", &oi)
   hdib := DllCall("GlobalAlloc", "uint", 2, "UPtr", 40+NumGet(oi, off1, "UInt"), "UPtr")
   pdib := DllCall("GlobalLock", "UPtr", hdib, "UPtr")
   DllCall("RtlMoveMemory", "UPtr", pdib, "UPtr", &oi+off2, "UPtr", 40)
   DllCall("RtlMoveMemory", "UPtr", pdib+40, "UPtr", NumGet(oi, off2 - A_PtrSize, "UPtr"), "UPtr", NumGet(oi, off1, "UInt"))
   DllCall("GlobalUnlock", "UPtr", hdib)
   r3 := DllCall("SetClipboardData", "uint", 8, "UPtr", hdib) ; CF_DIB = 8
   DllCall("CloseClipboard")
   DllCall("GlobalFree", "UPtr", hdib)
   DeleteObject(hBitmap)
   E := r3 ? 0 : -4    ; 0 - success
   Return E
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_CreateBitmapFromFile(sFile, IconNumber:=1, IconSize:="", useICM:=0) {
	local	;added by ms, force-local; warning related to Height
	pBitmap := 0, pBitmapOld := 0, hIcon := 0
	SplitPath sFile,,, Extension
	if RegExMatch(Extension, "^(?i:exe|dll)$")
	{
	   Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
	   BufSize := 16 + (2*A_PtrSize)
  
	   VarSetCapacity(buf, BufSize, 0)
	   For eachSize, Size in StrSplit( Sizes, "|" )
	   {
		 DllCall("PrivateExtractIcons", "str", sFile, "int", IconNumber-1, "int", Size, "int", Size, "UPtr*", hIcon, "UPtr*", 0, "uint", 1, "uint", 0)
		 if !hIcon
		    continue
  
		 if !DllCall("GetIconInfo", "UPtr", hIcon, "UPtr", &buf)
		 {
		    DestroyIcon(hIcon)
		    continue
		 }
  
		 ; hbmMask  := NumGet(buf, 12 + (A_PtrSize - 4))
		 hbmColor := NumGet(buf, 12 + (A_PtrSize - 4) + A_PtrSize)
		 if !(hbmColor && DllCall("GetObject", "UPtr", hbmColor, "int", BufSize, "UPtr", &buf))
		 {
		    DestroyIcon(hIcon)
		    continue
		 }
		 break
	   }
	   if !hIcon
		 return -1
  
	   Width := NumGet(buf, 4, "int")
	   Height := NumGet(buf, 8, "int")
	   hbm := CreateDIBSection(Width, -Height)
	   hdc := CreateCompatibleDC()
	   obm := SelectObject(hdc, hbm)
	   if !DllCall("DrawIconEx", "UPtr", hdc, "int", 0, "int", 0, "UPtr", hIcon, "uint", Width, "uint", Height, "uint", 0, "UPtr", 0, "uint", 3)
	   {
		 SelectObject(hdc, obm)
		 DeleteObject(hbm)
		 DeleteDC(hdc)
		 DestroyIcon(hIcon)
		 buf := ""
		 return -2
	   }
  
	   VarSetCapacity(dib, 104, 0)
	   DllCall("GetObject", "UPtr", hbm, "int", A_PtrSize = 8 ? 104 : 84, "UPtr", &dib) ; sizeof(DIBSECTION) = 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize
	   Stride := NumGet(dib, 12, "Int")
	   Bits := NumGet(dib, 20 + (A_PtrSize = 8 ? 4 : 0), "Int") ; padding
	   pBitmapOld := Gdip_CreateBitmap(Width, Height, 0, Stride, Bits)
	   pBitmap := Gdip_CreateBitmap(Width, Height)
	   _G := Gdip_GraphicsFromImage(pBitmap)
	   Gdip_DrawImage(_G, pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
	   SelectObject(hdc, obm)
	   DeleteObject(hbm)
	   DeleteDC(hdc)
	   Gdip_DeleteGraphics(_G)
	   Gdip_DisposeImage(pBitmapOld)
	   DestroyIcon(hIcon)
	   dib := "", buf := ""
	} else
	{
	   function2call := (useICM=1) ? "ICM" : ""
	   gdipLastError := DllCall("gdiplus\GdipCreateBitmapFromFile" function2call, "WStr", sFile, "UPtr*", pBitmap)
	}
  
	return pBitmap
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_DeleteGraphics(pGraphics) {
   If (pGraphics!="")
      return DllCall("gdiplus\GdipDeleteGraphics", "UPtr", pGraphics)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IsNumber(Var) {
   Static number := "number"
   If Var Is number
      Return 1
   Return 0
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
CreateColourMatrix(clrMatrix, ByRef ColourMatrix) {
   VarSetCapacity(ColourMatrix, 100, 0)
   Matrix := RegExReplace(RegExReplace(clrMatrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
   Matrix := StrSplit(Matrix, "|")
   Loop 25
   {
      M := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index - 1, 6) ? 0 : 1
      NumPut(M, ColourMatrix, (A_Index - 1)*4, "float")
   }
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_SetImageAttributesColorMatrix(clrMatrix, ImageAttr:=0, grayMatrix:=0, ColorAdjustType:=1, fEnable:=1, ColorMatrixFlag:=0) {
	local	;added by ms, force-local; warning related to E
   If (StrLen(clrMatrix)<5 && ImageAttr)
      Return -1

   If (StrLen(clrMatrix)<5) || (ColorMatrixFlag=2 && StrLen(grayMatrix)<5)
      Return

   CreateColourMatrix(clrMatrix, ColourMatrix)
   If (ColorMatrixFlag=2)
      CreateColourMatrix(grayMatrix, GrayscaleMatrix)

   If !ImageAttr
   {
      created := 1
      ImageAttr := Gdip_CreateImageAttributes()
   }

   E := DllCall("gdiplus\GdipSetImageAttributesColorMatrix"
         , "UPtr", ImageAttr
         , "int", ColorAdjustType
         , "int", fEnable
         , "UPtr", &ColourMatrix
         , "UPtr", &GrayscaleMatrix
         , "int", ColorMatrixFlag)

   gdipLastError := E
   E := created=1 ? ImageAttr : E
   return E
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_CreateImageAttributes() {
   ImageAttr := 0
   gdipLastError := DllCall("gdiplus\GdipCreateImageAttributes", "UPtr*", ImageAttr)
   return ImageAttr
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_GetImageWidth(pBitmap) {
	local	;added by ms, force-local; warning related to Width
   Width := 0
   gdipLastError := DllCall("gdiplus\GdipGetImageWidth", "UPtr", pBitmap, "uint*", Width)
   return Width
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_GetImageHeight(pBitmap) {
	local	;added by ms, force-local; warning related to Height
   Height := 0
   gdipLastError := DllCall("gdiplus\GdipGetImageHeight", "UPtr", pBitmap, "uint*", Height)
   return Height
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_DrawImage(pGraphics, pBitmap, dx:="", dy:="", dw:="", dh:="", sx:="", sy:="", sw:="", sh:="", Matrix:=1, Unit:=2, ImageAttr:=0) {
	local	;added by ms, force-local; warning related to E
   If (!pGraphics || !pBitmap)
      Return 2

   If !ImageAttr
   {
      if !IsNumber(Matrix)
         ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
      else if (Matrix!=1)
         ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")
   } Else usrImageAttr := 1

   If (dx!="" && dy!="" && dw="" && dh="" && sx="" && sy="" && sw="" && sh="")
   {
      sx := sy := 0
      sw := dw := Gdip_GetImageWidth(pBitmap)
      sh := dh := Gdip_GetImageHeight(pBitmap)
   } Else If (sx="" && sy="" && sw="" && sh="")
   {
      If (dx="" && dy="" && dw="" && dh="")
      {
         sx := dx := 0, sy := dy := 0
         sw := dw := Gdip_GetImageWidth(pBitmap)
         sh := dh := Gdip_GetImageHeight(pBitmap)
      } Else
      {
         sx := sy := 0
         Gdip_GetImageDimensions(pBitmap, sw, sh)
      }
   }

   E := DllCall("gdiplus\GdipDrawImageRectRect"
            , "UPtr", pGraphics
            , "UPtr", pBitmap
            , "float", dX, "float", dY
            , "float", dW, "float", dH
            , "float", sX, "float", sY
            , "float", sW, "float", sH
            , "int", Unit
            , "UPtr", ImageAttr ? ImageAttr : 0
            , "UPtr", 0, "UPtr", 0)

   If (E=1 && A_LastError=8) ; out of memory
      E := 3

   if (ImageAttr && usrImageAttr!=1)
      Gdip_DisposeImageAttributes(ImageAttr)

   return E
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_DisposeImageAttributes(ImageAttr) {
   If (ImageAttr!="")
      return DllCall("gdiplus\GdipDisposeImageAttributes", "UPtr", ImageAttr)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height) {
	local	;added by ms, force-local;	
   Width := 0, Height := 0
   If StrLen(pBitmap)<3
      Return 2

   E := Gdip_GetImageDimension(pBitmap, Width, Height)
   Width := Round(Width)
   Height := Round(Height)
   return E
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_GetImageDimension(pBitmap, ByRef w, ByRef h) {
   w := 0, h := 0
   If !pBitmap
      Return 2

   return DllCall("gdiplus\GdipGetImageDimension", "UPtr", pBitmap, "float*", w, "float*", h)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_GraphicsFromImage(pBitmap, InterpolationMode:="", SmoothingMode:="", PageUnit:="", CompositingQuality:="") {
   pGraphics := 0
   gdipLastError := DllCall("gdiplus\GdipGetImageGraphicsContext", "UPtr", pBitmap, "UPtr*", pGraphics)
   If (gdipLastError=1 && A_LastError=8) ; out of memory
      gdipLastError := 3

   If (pGraphics!="" && !gdipLastError)
   {
      If (InterpolationMode!="")
         Gdip_SetInterpolationMode(pGraphics, InterpolationMode)
      If (SmoothingMode!="")
         Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
      If (PageUnit!="")
         Gdip_SetPageUnit(pGraphics, PageUnit)
      If (CompositingQuality!="")
         Gdip_SetCompositingQuality(pGraphics, CompositingQuality)
   }
   return pGraphics
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_SetPageUnit(pGraphics, Unit) {
; Sets the unit of measurement for a pGraphics object.
; Unit of measuremnet options:
; 0 - World coordinates, a non-physical unit
; 1 - Display units
; 2 - A unit is 1 pixel
; 3 - A unit is 1 point or 1/72 inch
; 4 - A unit is 1 inch
; 5 - A unit is 1/300 inch
; 6 - A unit is 1 millimeter
   If !pGraphics
      Return 2

   Return DllCall("gdiplus\GdipSetPageUnit", "UPtr", pGraphics, "int", Unit)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_SetInterpolationMode(pGraphics, InterpolationMode) {
; InterpolationMode options:
; Default = 0
; LowQuality = 1
; HighQuality = 2
; Bilinear = 3
; Bicubic = 4
; NearestNeighbor = 5
; HighQualityBilinear = 6
; HighQualityBicubic = 7
   If !pGraphics
      Return 2
   Return DllCall("gdiplus\GdipSetInterpolationMode", "UPtr", pGraphics, "int", InterpolationMode)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_SetSmoothingMode(pGraphics, SmoothingMode) {
; SmoothingMode options:
; Default = 0
; HighSpeed = 1
; HighQuality = 2
; None = 3
; AntiAlias = 4
; AntiAlias8x4 = 5
; AntiAlias8x8 = 6
   If !pGraphics
      Return 2

   Return DllCall("gdiplus\GdipSetSmoothingMode", "UPtr", pGraphics, "int", SmoothingMode)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_SetCompositingMode(pGraphics, CompositingMode) {
; CompositingMode_SourceOver = 0 (blended / default)
; CompositingMode_SourceCopy = 1 (overwrite)
   If !pGraphics
      Return 2

   return DllCall("gdiplus\GdipSetCompositingMode", "UPtr", pGraphics, "int", CompositingMode)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_SetCompositingQuality(pGraphics, CompositionQuality) {
; CompositionQuality options:
; 0 - Gamma correction is not applied.
; 1 - Gamma correction is not applied. High speed, low quality.
; 2 - Gamma correction is applied. Composition of high quality and speed.
; 3 - Gamma correction is applied.
; 4 - Gamma correction is not applied. Linear values are used.
   If !pGraphics
      Return 2

   Return DllCall("gdiplus\GdipSetCompositingQuality", "UPtr", pGraphics, "int", CompositionQuality)
} 
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_CreateBitmap(Width, Height, PixelFormat:=0, Stride:=0, Scan0:=0) {
; By default, this function creates a new 32-ARGB bitmap.
; modified by Marius Șucan
   If (!Width || !Height)
   {
      gdipLastError := 2
      Return
   }

   pBitmap := 0
   If !PixelFormat
      PixelFormat := 0x26200A  ; 32-ARGB

   gdipLastError := DllCall("gdiplus\GdipCreateBitmapFromScan0"
      , "int", Width  , "int", Height
      , "int", Stride , "int", PixelFormat
      , "UPtr", Scan0 , "UPtr*", pBitmap)

   Return pBitmap
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Gdip_CreateHBITMAPFromBitmap(pBitmap, Background:=0xffffffff) {
	; background should be zero, to not alter alpha channel of the image
	   hBitmap := 0
	   If !pBitmap
	   {
		 gdipLastError := 2
		 Return
	   }
	
	   gdipLastError := DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UPtr", pBitmap, "UPtr*", hBitmap, "int", Background)
	   return hBitmap
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DeleteObject(hObject) {
	return DllCall("DeleteObject", "UPtr", hObject)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
CreateCompatibleDC(hdc:=0) {
   return DllCall("CreateCompatibleDC", "UPtr", hdc)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SelectObject(hdc, hgdiobj) {
   return DllCall("SelectObject", "UPtr", hdc, "UPtr", hgdiobj)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DeleteDC(hdc) {
   return DllCall("DeleteDC", "UPtr", hdc)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DestroyIcon(hIcon) {
	return DllCall("DestroyIcon", "UPtr", hIcon)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
CreateDIBSection(w, h, hdc:="", bpp:=32, ByRef ppvBits:=0, Usage:=0, hSection:=0, Offset:=0) {
; A GDI function that creates a new hBitmap,
; a device-independent bitmap [DIB].
; A DIB consists of two distinct parts:
; a BITMAPINFO structure describing the dimensions
; and colors of the bitmap, and an array of bytes
; defining the pixels of the bitmap. 

   hdc2 := hdc ? hdc : GetDC()
   VarSetCapacity(bi, 40, 0)
   NumPut(40, bi, 0, "uint")
   NumPut(w, bi, 4, "uint")
   NumPut(h, bi, 8, "uint")
   NumPut(1, bi, 12, "ushort")
   NumPut(bpp, bi, 14, "ushort")
   NumPut(0, bi, 16, "uInt")

   hbm := DllCall("CreateDIBSection"
               , "UPtr", hdc2
               , "UPtr", &bi    ; BITMAPINFO
               , "UInt", Usage
               , "UPtr*", ppvBits
               , "UPtr", hSection
               , "UInt", OffSet, "UPtr")

   if !hdc
      ReleaseDC(hdc2)
   return hbm
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
GetDC(hwnd:=0) {
   return DllCall("GetDC", "UPtr", hwnd)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ReleaseDC(hdc, hwnd:=0) {
   return DllCall("ReleaseDC", "UPtr", hwnd, "UPtr", hdc)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
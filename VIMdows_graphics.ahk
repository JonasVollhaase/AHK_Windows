
; ----------------------------------------- Setup ----------------------------------------- 

#SingleInstance, Force

chosenColor := "0xffff0000"
Width 		:= A_ScreenWidth
Height		:= A_ScreenHeight

; ----------------------------------------- Functions ----------------------------------------- 

SetupGdip()
{
	global
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, "gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system"
		ExitApp
	}
	OnExit("ExitFunction")
	

	Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
	Gui, 1: Show, NA


	hwnd1 := WinExist() 					; Get a handle to this window we have created in order to update it later
	hbm := CreateDIBSection(Width, Height) 	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
	hdc := CreateCompatibleDC() 			; Get a device context compatible with the screen
	obm := SelectObject(hdc, hbm)			; Select the bitmap into the device context
	G := Gdip_GraphicsFromHDC(hdc) 			; Get a pointer to the graphics of the bitmap, for use with drawing functions
	Gdip_SetSmoothingMode(G, 4) 			; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)

}

ShowGraphics()
{
	global
	SetupGdip()
	pBrush := Gdip_BrushCreateSolid(chosenColor) ; Create a slightly transparent (66) blue brush (ARGB = Transparency, red, green, blue) to draw a rectangle
	; topleft
	Gdip_FillRectangle(G, pBrush, 10, 10, 25, 10)
	Gdip_FillRectangle(G, pBrush, 10, 10, 10, 25)

	; topright
	Gdip_FillRectangle(G, pBrush, A_ScreenWidth - 35, 10, 25, 10)
	Gdip_FillRectangle(G, pBrush, A_ScreenWidth - 20, 10, 10, 25)

	; botright
	Gdip_FillRectangle(G, pBrush, A_ScreenWidth - 35, A_ScreenHeight - 20, 25, 10)
	Gdip_FillRectangle(G, pBrush, A_ScreenWidth - 20, A_screenheight - 35, 10, 25)

	; botleft
	Gdip_FillRectangle(G, pBrush, 10, A_ScreenHeight - 20, 25, 10)
	Gdip_FillRectangle(G, pBrush, 10, A_ScreenHeight - 35, 10, 25)

	;mid
	Gdip_FillRectangle(G, pBrush, A_ScreenWidth/2 -10, 10, 20, 10)
	Gdip_FillRectangle(G, pBrush, A_ScreenWidth/2 -10, A_ScreenHeight - 20, 20, 10)


	; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen So this will position our gui at (0,0) with the Width and Height specified earlier
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)	
	
	Gdip_DeleteBrush(pBrush) 	; Delete the brush as it is no longer needed and wastes memory
	SelectObject(hdc, obm) 		; Select the object back into the hdc
	DeleteObject(hbm) 			; Now the bitmap may be deleted
	DeleteDC(hdc) 				; Also the device context related to the bitmap may be deleted
	Gdip_DeleteGraphics(G) 		; The graphics may now be deleted
	
	; gdi+ may now be shutdown on exiting the program
	Gdip_Shutdown(pToken)
}

DeleteGraphics()
{
	global
	toggle := false
	SetupGdip()
	Gdip_GraphicsClear(G)  		;This sets the entire area of the graphics to 'transparent'
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)  ;This is what actually changes the display
}

ExitFunction()
{
	global
	;The cleanup code is moved to here because the functions
	;on hotkeys need these resources to still exist

	Gdip_DeleteBrush(pBrush) 	; Delete the brush as it is no longer needed and wastes memory
	SelectObject(hdc, obm) 		; Select the object back into the hdc
	DeleteObject(hbm) 			; Now the bitmap may be deleted
	DeleteDC(hdc) 				; Also the device context related to the bitmap may be deleted
	Gdip_DeleteGraphics(G) 		; The graphics may now be deleted
	; gdi+ may now be shutdown on exiting the program
	Gdip_Shutdown(pToken)
	ExitApp
}

ToggleGraphics()
{
	global
    if (toggle = true)
	{
        ShowGraphics()
    }
    else
	{
		DeleteGraphics()
    }

return	
}
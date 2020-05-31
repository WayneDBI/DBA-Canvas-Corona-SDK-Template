------------------------------------------------------------------------------------------------------------------------------------
-- DBA Canvas
------------------------------------------------------------------------------------------------------------------------------------
-- Developed by Deep Blue Apps.com [http:www.deepbueapps.com]
-- Artwork is for visual representation only and MUST NOT BE re-sold. Always adapt and change this template
-- to make it your own. Lua source files are not to be re-sold or hosted elsewhere.
-- Developing your own app using this template as a basis is fully allowed.
------------------------------------------------------------------------------------------------------------------------------------
-- Built using CORONA SDK [2012.894]
-- We do not guarantee the functionality in earlier or later versions of the Corona SDK
------------------------------------------------------------------------------------------------------------------------------------
-- Abstract: A Raw painting template, which enables users to build painting applications.
-- End users simply select a 'canvas' to start off with, then using a set of basic painting
-- tools, can colour in there master piece. By supplying your end users with various types of
-- Canvas's, you could build, Painting Apps, Cross Word Puzzles, Word Search, Kids Activities
-- Artistic apps etc etc. Simply add new images and thumbnails to this template to see them
-- added to you finished app.
-- Note 1: To use the template as is, you must supply your own art.
-- Note 2: Change the GLOBAL Variables in the [main.lua] file with the number of images you are going to use.
-- The code will automatically add them to slide panels, add the Page Indicators and select
-- the correct image once a user has tapped an image.
------------------------------------------------------------------------------------------------------------------------------------
-- Slider Code based on source by Microsheep. Adapted for use in the DBA Canvas Template
------------------------------------------------------------------------------------------------------------------------------------
--
-- maincanvas.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- 26-09-2012   : V2.5
------------------------------------------------------------------------------------------------------------------------------------


-- Collect relevant external libraries

local widget 		= require "widget"
local storyboard 	= require( "storyboard" )
local scene 		= storyboard.newScene()
local widget = require "widget-v1"

math.randomseed( os.time() )

---------------------------------------------------------------------------------------------------------
-- Setup environment Variables
---------------------------------------------------------------------------------------------------------
local lineWidth 			= 27 			--Default/Starting Brush Width
     
imageOverlay 				= nil

local panelOffScreenStart 	= 250
-- Default start Colour [Blue]
myRed 						= 22
myGreen 					= 0
myBlue 						= 255

brushColour = {R=myRed, G=myGreen, B=myBlue}
 
brushVisual 				= nil

local sliderRed
local sliderGreen
local sliderBlue

baseLayer = display.newGroup();
paintLayer = display.newGroup();
overlayLayer = display.newGroup();
configLayer = display.newGroup();
openPanelLayer = display.newGroup();
groupingLayer = display.newGroup();

--saveGroupLayer = display.newGroup()

swatchesLayer = display.newGroup();

doSponge 						= true
paintOpacity 					= 1.0

local bg						= nil
local flatBG					= nil
local savedImage				= nil
local tempBG					= nil

local fSoundPlaying 			= false    	-- sound playback state
local fSoundPaused 				= false    	-- sound playback state

brushStrokesTable 				= {} 		--Table to hold our Paint Brush Strokes.

local strokeCounter 			= 0			-- track the strokes the user has made
local maxStrokesTillFlatten 	= 1000		-- how many strokes allowed until flatten Starts? Vary this number on the DEVICE you are using..


---------------------------------------------------------------------------------------------------------
-- Setup Audio Recording Format
---------------------------------------------------------------------------------------------------------
local dataFileName = "DBACanvasbaseAudio"
if "simulator" == system.getInfo("environment") then
    dataFileName = dataFileName .. ".aif"
else
    if "iPhone OS" == system.getInfo( "platformName" ) then
        dataFileName = dataFileName .. ".aif"
    elseif "android" == system.getInfo( "platformName" ) then
        dataFileName = dataFileName .. ".pcm"
    elseif "iPad OS" == system.getInfo( "platformName" ) then
        dataFileName = dataFileName .. ".aif"
    end
end


----------------------------------------------------------------------------------------------------
-- Extra cleanup routines
----------------------------------------------------------------------------------------------------
local coronaMetaTable = getmetatable(display.getCurrentStage())
	isDisplayObject = function(aDisplayObject)
	return (type(aDisplayObject) == "table" and getmetatable(aDisplayObject) == coronaMetaTable)
end

local function cleanGroupsInternal ( objectOrGroup )
    if(not isDisplayObject(objectOrGroup)) then return end
		if objectOrGroup.numChildren then
			-- we have a group, so first clean that out
			while objectOrGroup.numChildren > 0 do
				-- clean out the last member of the group (work from the top down!)
				cleanGroupsInternal ( objectOrGroup[objectOrGroup.numChildren])
			end
		end
			objectOrGroup:removeSelf()
    return
end


---------------------------------------------------------------------------------------------------------
-- explode - a routine we'll use later to extract data from a buttons ID
---------------------------------------------------------------------------------------------------------
function explode(div,str)
	  if (div=='') then return false end
	  local pos,arr = 0,{}
	  -- for each divider found
	  for st,sp in function() return string.find(str,div,pos,true) end do
		-- Attach chars left of current divider
		table.insert(arr,string.sub(str,pos,st-1)) 
		pos = sp + 1 -- Jump past current divider
	  end
	  -- Attach chars right of last divider
	  table.insert(arr,string.sub(str,pos)) 
	  return arr
end


-- Called when the scene's view does not exist:
function scene:createScene( event )

	local screenGroup = self.view

	local function eraseCanvas()
		--Remove the previous base layer objects !! THIS CLEARS THE RAM VERY VERY IMPORTANT!!!	
		--print (groupingLayer.numChildren)
		createBlankBase()
	end

	---------------------------------------------------------------------------------------------------------
	-- Create a Blank Background
	---------------------------------------------------------------------------------------------------------
	local function createBlankBase()
		
		--Remove the previous base layer objects !! THIS CLEARS THE RAM VERY VERY IMPORTANT!!!	
		for i = 1, baseLayer.numChildren do
			baseLayer:remove(i)   
		end
		
		cleanGroupsInternal(paintLayer)

		bg = nil
		bg = display.newRect(0,0,_w,_h)
		bg:setFillColor(255,255,255)
		baseLayer:insert( bg )
		groupingLayer:insert( baseLayer )
		
	end
	
	createBlankBase()	
	
	---------------------------------------------------------------------------------------------------------
	-- Flatten & Save our curent painting to Temp Disk - to save memory.
	---------------------------------------------------------------------------------------------------------
	local tempFileCount = 0
	function flattenBG( )
					
		--Create a unique filename to save our temp image
		tempFileCount = tempFileCount + 1
		local filename = "dbaPaintImageTemp" .. tempFileCount .. ".png"
		
		local saveGroupLayer = display.newGroup()
		
		print(baseLayer.numChildren)
		
		--Pass all the objects to save into a new Group
		saveGroupLayer:insert(baseLayer)
		saveGroupLayer:insert(paintLayer)
		
		--save a the merged image
		local flatBG = display.save( saveGroupLayer, filename, system.TemporaryDirectory)
		flatBG = nil

		--Remove the previous base layer objects !! THIS CLEARS THE RAM VERY VERY IMPORTANT!!!	
		for i = 1, baseLayer.numChildren do
			baseLayer:remove(i)   
		end

		--load the saved image back in as the new background
		bg = display.newImageRect( filename, system.TemporaryDirectory, display.contentWidth,display.contentHeight)
		bg.x = display.contentWidth/2
		bg.y = (display.contentHeight/2)
	
		--Add to the Base Layer
		baseLayer:insert(bg)
		
		--Re-Arrange the Layer ordering with our new image
		groupingLayer:insert(1, baseLayer)
		groupingLayer:insert(2, paintLayer)

		--remove all the other items in the display group
		for i = 1, #brushStrokesTable do
			brushStrokesTable[i]:removeSelf()
			brushStrokesTable[i] = nil
		end
		
		--delete the previous temp file
		filename = "dbaPaintImageTemp" .. (tempFileCount - 1) .. ".png"
		os.remove( system.pathForFile( filename, system.TemporaryDirectory  ) )
		native.setActivityIndicator(false)
		
		--reset stroke counter to 0
		strokeCounter = 0
		
	end
		
	groupingLayer:insert(paintLayer )
	
	---------------------------------------------------------------------------------------------------------
	-- Draw the OVERLAY IMAGE.
	---------------------------------------------------------------------------------------------------------
	imageOverlay = display.newImageRect( imagesPath.._G.whichImage, 1024,768 )
	imageOverlay.x = display.contentWidth/2
	imageOverlay.y = (display.contentHeight/2)
	
	-- Set the KEY-LINE DRAWING to multiply to avoid white hairlines...
	-- May need disabling for some Android Devices.
	imageOverlay.blendMode = "multiply"
	
	overlayLayer:insert( imageOverlay )
	
	---------------------------------------------------------------------------------------------------------
	-- Create the Show Panel Button/Layer etc.
	---------------------------------------------------------------------------------------------------------
	local function showPanel2( )
		transition.to( configLayer, { y=configLayer.y+50, time=100 } )
	end
	
	local function showPanel( event )
		
		if ( event.phase == "release" and openPanelLayer.alpha==1.0 ) then
			transition.to( configLayer, { alpha=1.0, y=(configLayer.y-panelOffScreenStart)-50, time=400, onComplete=showPanel2 } )
			transition.to( openPanelLayer, { alpha=0.0, time=300 } )
			return true
		end
	end
	
	local openPanel = widget.newButton{
		left = (_w/2)-29,
		top = _h-70,
		default = guiImages.."showPanelOff.png",
		over = guiImages.."showPanelOn.png",
		width = 58, height = 58,
		onRelease = showPanel
		}
	
	openPanelLayer:insert( openPanel )
	overlayLayer:insert( openPanelLayer )
	
	---------------------------------------------------------------------------------------------------------
	-- Create the Brush Editor Panel.
	---------------------------------------------------------------------------------------------------------
	local configPanel = display.newImageRect( guiImages.."optionsPanel.png", 822, 276 )
	configPanel:setReferencePoint( display.CenterReferencePoint )
	configPanel.x = _w/2
	configPanel.y = _h-(configPanel.height/2)
	configLayer:insert( configPanel )
	
	-- Enable the below 2 lines to stop drawing THROUGH the colour palette screen
	-- May cause interruptions in the drawing!
	--configPanel:addEventListener("touch", function() return true end)
	--configPanel:addEventListener("tap", function() return true end)
	
	local function closePanel2( )
		transition.to( configLayer, { alpha=0.0, y=panelOffScreenStart, time=400 } )
	end
	local function closePanel( event )
		if ( event.phase == "release" ) then
			transition.to( configLayer, { y=configLayer.y-50, time=100, onComplete=closePanel2 } )
			transition.to( openPanelLayer, { alpha=1.0, time=300 } )
			return true
		end
	end
	
	local closePanel = widget.newButton{
			left = configPanel.x-40,
			top = configPanel.y+60,
			default = guiImages.."closeButtonOff.png",
			over = guiImages.."closeButtonOn.png",
			width = 90, height = 82,
			onRelease = closePanel
			}
	
	configLayer:insert( closePanel )
	
	--Update the Slider values after a user selects a SWATCH colour
	local function refreshSliders()
		sliderRed:setValue(math.round(myRed/2.55))
		sliderGreen:setValue(math.round(myGreen/2.55))
		sliderBlue:setValue(math.round(myBlue/2.55))
	end
	
	local function refreshSwatch()
		colourVisual:setFillColor(myRed,myGreen,myBlue)
		brushColour = {R=myRed, G=myGreen, B=myBlue}
		
		--Update the RGB Display Values
		if (textRed) then textRed:removeSelf(); end	
			textRed = display.newText(math.round(myRed), configPanel.x-(configPanel.width/2)+720, configPanel.y-(configPanel.height/2)+148 , native.systemFont, 14)
			configLayer:insert( textRed )
		
		if (textGreen) then textGreen:removeSelf(); end	
			textGreen = display.newText(math.round(myGreen), configPanel.x-(configPanel.width/2)+720, configPanel.y-(configPanel.height/2)+177 , native.systemFont, 14)
			configLayer:insert( textGreen )
	
		if (textBlue) then textBlue:removeSelf(); end	
			textBlue = display.newText(math.round(myBlue), configPanel.x-(configPanel.width/2)+720, configPanel.y-(configPanel.height/2)+205 , native.systemFont, 14)
			configLayer:insert( textBlue )
	end
	
	local function refreshBrushSwatch()
		brushVisual:setFillColor(myRed,myGreen,myBlue)
		brushColour = {R=myRed, G=myGreen, B=myBlue}
	end
	
	-- brush Thickness Slider listener function
	local function sliderListener( event )
		if event.value > 1 then
		lineWidth = event.value/2
		
		if (brushVisual) then brushVisual:removeSelf(); end	
			brushVisual = display.newCircle(configPanel.x-(configPanel.width/2)+380, configPanel.y-(configPanel.height/2)+82,lineWidth/2)
			brushVisual:setFillColor(myRed,myGreen,myBlue)
			brushVisual.strokeWidth = 1
			brushVisual:setStrokeColor(190,190,190)
			configLayer:insert( brushVisual )
		else
			lineWidth = 1
		end
	end

	-- RGB [R] Slider listener function
	local function sliderOpacity( event )
		paintOpacity = event.value/100
--		refreshSwatch()
--		refreshBrushSwatch()
	end

	
	-- RGB [R] Slider listener function
	local function sliderR( event )
		myRed = event.value*2.55
		refreshSwatch()
		refreshBrushSwatch()
	end
	
	-- RGB [G] Slider listener function
	local function sliderG( event )
		myGreen = event.value*2.55
		refreshSwatch()
		refreshBrushSwatch()
	end
	
	-- RGB [B] Slider listener function
	local function sliderB( event )
		myBlue = event.value*2.55
		refreshSwatch()
		refreshBrushSwatch()
	end
	
	
	--Create the Brush Thickness Slider
		sliderBrush = widget.newSlider{
		top = configPanel.y-(configPanel.height/2)+65,
		left = configPanel.x-(configPanel.width/2)+185,
		width = 155,
		value = lineWidth*2,
		listener = sliderListener
		}
	configLayer:insert( sliderBrush )
	
	--Create the Opacity Slider
		sliderOpacity = widget.newSlider{
		top = configPanel.y-(configPanel.height/2)+95,
		left = configPanel.x-(configPanel.width/2)+185,
		width = 155,
		value = paintOpacity*100,
		listener = sliderOpacity
		}
	configLayer:insert( sliderOpacity )
	
	--Create the RGB [RED] Slider
	sliderRed = widget.newSlider{
		top = configPanel.y-(configPanel.height/2)+155,
		left = configPanel.x-(configPanel.width/2)+555,
		width = 150, value = myRed, listener = sliderR }
		
	configLayer:insert( sliderRed )
	
	--Create the RGB [GREEN] Slider
	sliderGreen = widget.newSlider{
		top = configPanel.y-(configPanel.height/2)+183,
		left = configPanel.x-(configPanel.width/2)+555,
		width = 150, value = myGreen, listener = sliderG }
		
	configLayer:insert( sliderGreen )
	
	--Create the RGB [BLUE] Slider
	sliderBlue = widget.newSlider{
		top = configPanel.y-(configPanel.height/2)+212,
		left = configPanel.x-(configPanel.width/2)+555,
		width = 150, value = myBlue, listener = sliderB }
		
	configLayer:insert( sliderBlue )
	
	
	
	--Create the Brush Size Circle Sprite
	brushVisual = display.newCircle(configPanel.x-(configPanel.width/2)+380, configPanel.y-(configPanel.height/2)+82,lineWidth/2)
	brushVisual:setFillColor(myRed,myGreen,myBlue)
	brushVisual.strokeWidth = 1
	brushVisual:setStrokeColor(190,190,190)
	configLayer:insert( brushVisual )
	
	--Create the Brush Colour Sprite
	colourVisual = display.newRoundedRect(configPanel.x-(configPanel.width/2)+359, configPanel.y-(configPanel.height/2)+136, 41, 83, 2)
	colourVisual:setFillColor(myRed,myGreen,myBlue)
	colourVisual.strokeWidth = 1
	colourVisual:setStrokeColor(190,190,190)
	configLayer:insert( colourVisual )
	
	--Create the Red, Green, Blue Text indicators
	textRed = display.newText(math.round(myRed), configPanel.x-(configPanel.width/2)+720, configPanel.y-(configPanel.height/2)+148 , native.systemFont, 14)
	textRed:setTextColor(255,255,255)
	configLayer:insert( textRed )
	
	textGreen = display.newText(math.round(myGreen), configPanel.x-(configPanel.width/2)+720, configPanel.y-(configPanel.height/2)+177 , native.systemFont, 14)
	textGreen:setTextColor(255,255,255)
	configLayer:insert( textGreen )
	
	textBlue = display.newText(math.round(myBlue), configPanel.x-(configPanel.width/2)+720, configPanel.y-(configPanel.height/2)+205 , native.systemFont, 14)
	textBlue:setTextColor(255,255,255)
	configLayer:insert( textBlue )
	
	---------------------------------------------------------------------------------------------------------
	-- Set the Editor Panel Offscreen when we start
	---------------------------------------------------------------------------------------------------------
	configLayer.y = panelOffScreenStart
	
	
	---------------------------------------------------------------------------------------------------------
	-- Erase options in our Editor Panel
	---------------------------------------------------------------------------------------------------------
	local erase = function()
		-- Handler that gets notified when the alert closes
		local function onComplete( event )
			if "clicked" == event.action then
			
				local i = event.index
				if 1 == i then
					createBlankBase()
					display.getCurrentStage():setFocus(nil)
					flattenBG()
				elseif 2 == i then
					-- Do nothing; dialog will simply dismiss
				end
			end
		end
		-- Show alert with Options. Trigger the wipe action if the user clicks the 1st button.
		local alert = native.showAlert( "Wipe Canvas?", "Are you sure you want to wipe the canvas clean?",  { "Yes", "Cancel" }, onComplete )
	
		return true
	end
	

	---------------------------------------------------------------------------------------------------------
	-- Go back to the Menu Screen
	---------------------------------------------------------------------------------------------------------
	local goMenu = function()
		-- Handler that gets notified when the alert closes
		local function onComplete( event )
			if "clicked" == event.action then
				local i = event.index
				if 1 == i then
					--createBlankBase()
					display.getCurrentStage():setFocus(nil)
					
					--Remove the previous base layer objects !! THIS CLEARS THE RAM VERY VERY IMPORTANT!!!	
					for i = 1, baseLayer.numChildren do
						baseLayer:remove(i)   
					end
					cleanGroupsInternal(paintLayer)
					bg = nil
					
					
					local function exitTheScene()
						storyboard.gotoScene( "mainMenu", "crossFade", 400 )
					end
					
					timer.performWithDelay(100, exitTheScene )
					
				elseif 2 == i then
					-- Do nothing; dialog will simply dismiss
				end
			end
		end
		-- Show alert with Options. Trigger the wipe action * Return to Menu if the user clicks the 1st button.
		local alert = native.showAlert( "Return to Menu?", "Are you sure you want to return to the Menu?",  { "Yes", "Cancel" }, onComplete )
	
		return true
	end


	---------------------------------------------------------------------------------------------------------
	-- Save the users design to the iPads Photo Album
	---------------------------------------------------------------------------------------------------------
	local goSave = function()
		transition.to( configLayer, { y=configLayer.y-50, time=100, onComplete=closePanel2 } )
		transition.to( openPanelLayer, { alpha=1.0, time=300 } )
		
		local function saveImageToAlbum()
			--Hide the Open Palette Sprite
			openPanelLayer.alpha=0.0
			
			-- Capture the screen
			local screenCap = display.captureScreen( true )
			--Alert the user to look in the library (device) 
			local alert = native.showAlert( "Success", "Your picture has been saved to your iPad's Photo Library", { "OK" } )
			
			--Show the Open Palette Sprite
			openPanelLayer.alpha=1.0
			
			--Remove the Captured Screen from the device / Canvas Window.
			screenCap:removeSelf()
		end
		
		timer.performWithDelay(600, saveImageToAlbum )
	
		return true
	end
	 
	--Get the Swatch Colour base on the info sent in the ID.
	local pickSwatch = function(event)
	--print (event.target.id)
		local gotRed = event.target.id
		local splitColours = explode(",", gotRed)
		myRed = splitColours[1]
		myGreen = splitColours[2]
		myBlue = splitColours[3]
		refreshSwatch()
		refreshBrushSwatch()
		refreshSliders()
		return true
	end
	 
	
	---------------------------------------------------------------------------------------------------------
	-- Voice recording Functions.
	---------------------------------------------------------------------------------------------------------
	-- Update the state dependent texts
	local function updateStatus ()
		local statusText = " "
		local statusText2 = " "
		if r then
			local recString = ""
			local fRecording = r:isRecording ()
			if fRecording then 
				recString = "RECORDING" 
			elseif fSoundPlaying then
				recString = "Playing"
			elseif fSoundPaused then
				recString = "Paused"
			else
				recString = "Idle"
			end
			statusText =  recString 
		end
		s:setText (statusText)
	end
	
	local function onCompleteSound (event)
		fSoundPlaying = false
		fSoundPaused = false
		--updateStatus ()	
	end

	---------------------------------------------------------------------------------------------------------
	-- Record the users voice
	---------------------------------------------------------------------------------------------------------
	local function goRecord ( event )
		if fSoundPlaying then
			fSoundPlaying = false
			fSoundPaused = true
			media.pauseSound()
		elseif fSoundPaused then
			fSoundPlaying = true   
			fSoundPaused = false
			media.playSound()
		else
			if r then
				if r:isRecording () then
					r:stopRecording()
					local filePath = system.pathForFile( dataFileName, system.DocumentsDirectory )
					-- Play back the recording
					local file = io.open( filePath, "r" )
					if file then
						io.close( file )
	--                  print("Play file: " .. filePath)
						fSoundPlaying = true
						fSoundPaused = false
						media.playSound( dataFileName, system.DocumentsDirectory, onCompleteSound )
					end                
				else
					fSoundPlaying = false
					fSoundPaused = false
					r:startRecording()
				end
			end
		end
		
		return true
		--updateStatus ()
	end

	---------------------------------------------------------------------------------------------------------
	-- Save the Audio to the device
	---------------------------------------------------------------------------------------------------------
	local filePath = system.pathForFile( dataFileName, system.DocumentsDirectory )
	print("Creating data file at " .. filePath)
	r = media.newRecording(filePath)

	---------------------------------------------------------------------------------------------------------
	-- Stop the Audio from Playing
	---------------------------------------------------------------------------------------------------------
	local function goStop()
		if r then
			if r:isRecording () then
				r:stopRecording()
			end
			if fSoundPlaying then
				fSoundPlaying = false
				fSoundPaused = true
				media.pauseSound()
			end 
		end
		return true
	end

	---------------------------------------------------------------------------------------------------------
	-- Play the Users recorded Audio
	---------------------------------------------------------------------------------------------------------
	local function goPlay()
		if r then
        	if r:isRecording () then
                r:stopRecording()
			end
            local filePath = system.pathForFile( dataFileName, system.DocumentsDirectory )
            -- Play back the recording
            local file = io.open( filePath, "r" )
			if file then
				io.close( file )
				fSoundPlaying = true
				fSoundPaused = false
				media.playSound( dataFileName, system.DocumentsDirectory, onCompleteSound )
			end
		end
		return true
	end

	---------------------------------------------------------------------------------------------------------
	-- Editor Panel Buttons.
	---------------------------------------------------------------------------------------------------------
	local menuButton = widget.newButton{
			left = configPanel.x+87,
			top = configPanel.y-84,
			default = guiImages.."buttonMenuOff.png",
			over = guiImages.."buttonMenuOn.png",
			onRelease = goMenu
			}			
	configLayer:insert( menuButton )
	
	local menuSave = widget.newButton{
			left = configPanel.x+87,
			top = configPanel.y-55,
			default = guiImages.."buttonSaveOff.png",
			over = guiImages.."buttonSaveOn.png",
			onRelease = goSave
			}			
	configLayer:insert( menuSave )
	
	local eraseButton = widget.newButton{
			left = configPanel.x+220,
			top = configPanel.y-55,
			default = guiImages.."buttonClearOff.png",
			over = guiImages.."buttonClearOn.png",
			onRelease = erase
			}			
	configLayer:insert( eraseButton )
	
	local menuRecord = widget.newButton{
			left = configPanel.x+221,
			top = configPanel.y-84,
			default = guiImages.."buttonRecordOff.png",
			over = guiImages.."buttonRecordOn.png",
			onRelease = goRecord
			}			
	configLayer:insert( menuRecord )
	
	local menuStop = widget.newButton{
			left = configPanel.x+265,
			top = configPanel.y-84,
			default = guiImages.."buttonStopOff.png",
			over = guiImages.."buttonStopOn.png",
			onRelease = goStop
			}			
	configLayer:insert( menuStop )

	local menuPlay = widget.newButton{
			left = configPanel.x+310,
			top = configPanel.y-84,
			default = guiImages.."buttonPlayOff.png",
			over = guiImages.."buttonPlayOn.png",
			onRelease = goPlay
			}			
	configLayer:insert( menuPlay )
	
	--Setup the RUBBER Button. When called, we simply set the INK to white
	local rubberButton = widget.newButton{
			left = (configPanel.x-(configPanel.width/2)+50),
			top = (configPanel.y-(configPanel.height/2)+128),
			default = guiImages.."buttonEraseOff.png",
			over = guiImages.."buttonEraseOn.png",
			onRelease = pickSwatch, id="255,255,255",
			}			
	configLayer:insert( rubberButton )
	
	---------------------------------------------------------------------------------------------------------
	-- Create the System created 30 Colour Swatches.
	-- First 2 colours are Black & White. The other 28 Swatches are Randomly Generated values
	---------------------------------------------------------------------------------------------------------
	
	--Setup our Swatch Palette
	local function createRandomSwatches()
	
		--Setup a DEFAULT WHITE swatch
		local s1 = widget.newButton{
		id="255,255,255", defaultColor={255,255,255,255}, left = (configPanel.x-(configPanel.width/2)+92)+(25), top = (configPanel.y-(configPanel.height/2)+148)+0, width = 24, height = 24, cornerRadius=0, strokeColor={160,160,160,255}, onRelease=pickSwatch}
		swatchesLayer:insert( s1 )
		
		--Setup a DEFAULT BLACK swatch
		local s1 = widget.newButton{
		id="0,0,0", defaultColor={0,0,0,255}, left = (configPanel.x-(configPanel.width/2)+92)+(50), top = (configPanel.y-(configPanel.height/2)+148)+0, width = 24, height = 24, cornerRadius=0, strokeColor={160,160,160,255}, onRelease=pickSwatch}
		swatchesLayer:insert( s1 )
	
		--Setup our 28 RANDOM MIX swatches
		for i = 3, 9 do
			local mr = math.random(0, 255)
			local mg = math.random(0, 255)
			local mb = math.random(0, 255)
			local s1 = widget.newButton{
			id=mr..","..mg..","..mb, defaultColor={mr, mg, mb,255}, left = (configPanel.x-(configPanel.width/2)+92)+(25*i), top = (configPanel.y-(configPanel.height/2)+148)+0, width = 24, height = 24, cornerRadius=0, strokeColor={160,160,160,255}, onRelease=pickSwatch}
			swatchesLayer:insert( s1 )
		end
		
		for i = 1, 9 do
			local mr = math.random(0, 255)
			local mg = math.random(0, 255)
			local mb = math.random(0, 255)
			local s1 = widget.newButton{
			id=mr..","..mg..","..mb, defaultColor={mr, mg, mb,255}, left = (configPanel.x-(configPanel.width/2)+92)+(25*i), top = (configPanel.y-(configPanel.height/2)+148)+25, width = 24, height = 24, cornerRadius=0, strokeColor={160,160,160,255}, onRelease=pickSwatch}
			swatchesLayer:insert( s1 )
		end
		
		for i = 1, 9 do
			local mr = math.random(0, 255)
			local mg = math.random(0, 255)
			local mb = math.random(0, 255)
			local s1 = widget.newButton{
			id=mr..","..mg..","..mb, defaultColor={mr, mg, mb,255}, left = (configPanel.x-(configPanel.width/2)+92)+(25*i), top = (configPanel.y-(configPanel.height/2)+148)+50, width = 24, height = 24, cornerRadius=0, strokeColor={160,160,160,255}, onRelease=pickSwatch}
			swatchesLayer:insert( s1 )
		end
		
		--Insert the Swatches LAYER into the main Config Panel Layer
		--We do this, so later on, the user can create NEW swatches. So we
		--Need a way to destroy the OLD swatches and re-create them
		configLayer:insert( swatchesLayer )
	end
	
	--Create the Swatch Palettes. Also used for creating a NEW set.
	local function resetSwatches()
		--Destroy any previous references to the Swatch LAYER.
		if(swatchesLayer)then swatchesLayer:removeSelf();end
		
		--Create a new accessible Swatch Layer for the other functions.
		swatchesLayer = display.newGroup();
		
		--Now Re-Create the new RANDOM Swatches.
		createRandomSwatches()
		
		return true
	end
	
	
	--Setup the RE-MIX SWATCHES Button
	local randomSwatch = widget.newButton{
			left = (configPanel.x-(configPanel.width/2)+430),
			top = (configPanel.y-(configPanel.height/2)+128),
			default = guiImages.."buttonMixOff.png",
			over = guiImages.."buttonMixOn.png",
			onRelease = resetSwatches,
			}			
	configLayer:insert( randomSwatch )
		
	--Call the above routine to give us our initial Random Colours
	resetSwatches()
	
	-- Insert the Config Panel into the Overall Group layer
	overlayLayer:insert( configLayer )
	groupingLayer:insert( overlayLayer )
	
	screenGroup:insert( groupingLayer )
	--screenGroup:insert( saveGroupLayer )


	---------------------------------------------------------------------------------------------------------
	-- Paint Brush Function
	---------------------------------------------------------------------------------------------------------
	local function newBrushStroke(event)
			local function drawLine()
			
				--increment the strokes counter
				strokeCounter = strokeCounter + 1
				--print(strokeCounter)
				
				local line = display.newLine(linePoints[#linePoints-1].x,linePoints[#linePoints-1].y,linePoints[#linePoints].x,linePoints[#linePoints].y)
					line:setColor(brushColour.R, brushColour.G, brushColour.B);
					
					if (paintOpacity < 1.0) then
						line.alpha = 0.0
					else
						line.alpha = paintOpacity
					end
					
					line.width=lineWidth;
					brushStrokesTable[i]:insert(line)
  
				local brushCircle = display.newCircle(linePoints[#linePoints].x,linePoints[#linePoints].y,lineWidth/2)
					brushCircle:setFillColor(brushColour.R, brushColour.G, brushColour.B)
					brushCircle.alpha = paintOpacity
					brushStrokesTable[i]:insert(brushCircle)
					paintLayer:insert( brushStrokesTable[i])
			end
	 
			if event.phase=="began" then
			
				i = #brushStrokesTable+1
				brushStrokesTable[i]=display.newGroup()
				display.getCurrentStage():setFocus(event.target)
				
				local brushCircle = display.newCircle(event.x,event.y,lineWidth/2)
					brushCircle:setFillColor(brushColour.R, brushColour.G, brushColour.B)
					brushCircle.alpha = paintOpacity
					brushStrokesTable[i]:insert(brushCircle)
					paintLayer:insert( brushStrokesTable[i])
						 
				linePoints = nil
				linePoints = {};
				
				local pt = {}
					pt.x = event.x;
					pt.y = event.y;
					table.insert(linePoints,pt);
											
			elseif event.phase=="moved" then
				local pt = {}
					pt.x = event.x;
					pt.y = event.y;
								
				if not (pt.x==linePoints[#linePoints].x and pt.y==linePoints[#linePoints].y) then
					table.insert(linePoints,pt)
					drawLine()
				end
			
			elseif event.phase=="cancelled" or "ended" then
				display.getCurrentStage():setFocus(nil)
				i=nil
				
				if (strokeCounter > maxStrokesTillFlatten) then

					local function doActivityWindow()
						flattenBG()
					end
					
					--Show activity then flatten!
					native.setActivityIndicator(true)
					timer.performWithDelay(5, doActivityWindow )
					
				end
			end
			
		return true
	
	end     
	
	---------------------------------------------------------------------------------------------------------
	-- Events Listener to detect screen touches.
	---------------------------------------------------------------------------------------------------------
	groupingLayer:addEventListener("touch",newBrushStroke)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	storyboard.purgeScene( "mainMenu" )
	storyboard.removeScene( "mainMenu" )
	---------------------------------------------------------------------------------------------
	-- Add Listeners to our SCENE
	---------------------------------------------------------------------------------------------
end
		
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	print( "Scene1: exitScene event" )
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )

end



---------------------------------------------------------------------------------
-- END OF SCENE IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------


return scene
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
-- mainMenu.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- 26-09-2012   : V2.5
------------------------------------------------------------------------------------------------------------------------------------

-- require controller module
local storyboard 			= require "storyboard"
local scene 				= storyboard.newScene()
local ui 					= require("ui")
local widget 				= require "widget"

require "gameUI"

local sliderPanel			= nil
local sliderPanelSprite		= nil
local this_btn 				= nil
local menuGroup 			= display.newGroup()
local infoGroup 			= display.newGroup()
local setIncrementor 		= 1

local SliderPanelGroup 		= display.newGroup()



-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
		------------------------------------------------------------------------------------------------------------------------------------
		-- Function to hold the users chosen image from the Thumbnail selections in the Global Variable.
		------------------------------------------------------------------------------------------------------------------------------------
		local function thumbnailSelect(event)
			--if (event.phase == "release") then
				_G.whichImage = event.target.tag..".png" --Set up the users selected image
				print (_G.whichImage)			
				print("Going to canvas")
				storyboard.gotoScene( "mainCanvas", "crossFade", 400 )
			--end
			return true
		end
		
		------------------------------------------------------------------------------------------------------------------------------------
		-- Create A Group (Layer) to hold our Sliding Sprites
		------------------------------------------------------------------------------------------------------------------------------------
		local SliderPanelGroup = display.newGroup()
		SliderPanelGroup.y = _h-235
			
		------------------------------------------------------------------------------------------------------------------------------------
		-- Create the Background Image
		------------------------------------------------------------------------------------------------------------------------------------
		local image = display.newImageRect( guiImages.."menuScreen.png",1024,768 )
		image.x = display.contentWidth/2
		image.y = display.contentHeight/2
		image.alpha = 1.0
		screenGroup:insert( image )
	
		------------------------------------------------------------------------------------------------------------------------------------
		-- Shoe the Info Page Button function
		------------------------------------------------------------------------------------------------------------------------------------
		local function gotoInfoPage()
			--local alert = native.showAlert( "DBA Canvas Info", "This Popup window will be replaced by a Info Scene. In Development.", { "OK" } )
			transition.to (	infoGroup, {alpha=1.0, y=0, time=200} )	
			transition.to (	SliderPanelGroup, {alpha=0.0, time=200} )	
		end
		
	
		------------------------------------------------------------------------------------------------------------------------------------
		-- Setup the Info Button
		------------------------------------------------------------------------------------------------------------------------------------
		local infoButton = widget.newButton{
			left = (_w/2)-70,
			top = _h-60,
			defaultFile = guiImages.."buttonInfoOff.png",
			overFile = guiImages.."buttonInfoOn.png",
			onRelease = gotoInfoPage,
			}			
		screenGroup:insert( infoButton )


	local function init()
	
		------------------------------------------------------------------------------------------------------------------------------------
		-- Create the Sliding Panels
		------------------------------------------------------------------------------------------------------------------------------------
		local sliderPanel = require( "slider" )
		sliderPanel:init()
		local sliderPanelSprite = sliderPanel:getSprite()
		SliderPanelGroup:insert( sliderPanelSprite )
		
		local sliderSpriteThumbnail = nil
		local sliderPanelIndicatorButtons = nil
		local this_btn = nil
		
		------------------------------------------------------------------------------------------------------------------------------------
		-- Loop through, creating the Slide Panels. We create enough Slide Panels to hold all of our Thumbnail images
		------------------------------------------------------------------------------------------------------------------------------------
		for i = 1, (numberOfImages/thumbnailsPerSlide) do --Here we are looping through how many Slide Panels to Create.
			sliderSpriteThumbnail = createSlidePanels( i )
			sliderPanelIndicatorButtons = renderSlideBtn( i, _w )
			sliderPanel.addSlide( sliderSpriteThumbnail, sliderPanelIndicatorButtons )
		end
		screenGroup:insert(SliderPanelGroup)

	end
	
	------------------------------------------------------------------------------------------------------------------------------------
	-- This function is called on each iteration of the Slide Creation Loop (above)
	-- Here we are placing each of the thumbnails within the correct slider panel
	-- and setting up the thumbnail to act like a Button, with a EventListener.
	-- Looks scarier than it is really.
	------------------------------------------------------------------------------------------------------------------------------------
	function createSlidePanels( slideIndex )
		local sliderSpriteThumbnail = display.newGroup()
		
		for i = 1, thumbnailsPerSlide do  		--Here we are looping through how many Thumbnails to show on each Slide Panel
			setIncrementor = setIncrementor + 1 --Which Image/Thumbnail to create.
			local	thumbNail = display.newImage( thumbnailPath.."thumbnail"..(setIncrementor-1)..".png" )
					thumbNail.x = 40+(160*i)
					thumbNail.y = 80
					thumbNail.tag = "image"..(setIncrementor-1)
					thumbNail:addEventListener( "tap", thumbnailSelect)
					sliderSpriteThumbnail:insert( thumbNail )
		end
		
		local bck_sprt = display.newImage( guiImages.."slideArea.png" )
		bck_sprt.width = _w
		sliderSpriteThumbnail:insert( bck_sprt )
		
		--Insert the new Slide Panel into our Screen Group
		screenGroup:insert( sliderSpriteThumbnail )

		return sliderSpriteThumbnail
	end
	----------------------------------------------------------------------------------------------------
	

	----------------------------------------------------------------------------------------------------
	-- Create the Dots at bottom of the Screen
	----------------------------------------------------------------------------------------------------
	function renderSlideBtn( btnIndex, slideWidth )
		-- We setup how many 'dots' there are by dividing how many thumbnails and Panels.
		-- Note you must ensure the number of Thumbnails EVENLY divides into the panels.
		-- If you do not, tere will be an error...
		local numBtns = (numberOfImages/thumbnailsPerSlide)  
		
		-- Setup the Dots, to show how many slides there are.
		local sliderPanelIndicatorButtons = display.newGroup()
			sliderPanelIndicatorButtons.x = 0.5 * slideWidth + (btnIndex - 0.5 * numBtns - 1) * 20
			sliderPanelIndicatorButtons.y = 152
			sliderPanelIndicatorButtons.id = btnIndex
		
		-- Set up an ON dot for the specific panel
		local slidePanelIndicatorButton_ON = display.newImage( guiImages.."dotOn.png" )
			sliderPanelIndicatorButtons:insert(slidePanelIndicatorButton_ON)
		
		-- Set up an OFF dot for the specific panel
		local slidePanelIndicatorButton_OFF = display.newImage( guiImages.."dotOff.png" )
			sliderPanelIndicatorButtons:insert(slidePanelIndicatorButton_OFF)
			slidePanelIndicatorButton_OFF.isVisible = false
		
		return sliderPanelIndicatorButtons
	end

	----------------------------------------------------------------------------------------------------
	-- build the Info Screen
	----------------------------------------------------------------------------------------------------
	infoGroup.y 	= _h+50 --Move the Info Panel off screen
	infoGroup.alpha = 0.0	--Set the Group Layers opacity to 0 (Keep it hidden)
	local infoImage	= display.newImageRect( guiImages.."infoPanel.png", 1024,768 )
	infoImage.x 	= display.contentWidth/2
	infoImage.y		= display.contentHeight/2
	infoImage.alpha	= 1.0
	infoGroup:insert( infoImage )
	
	----------------------------------------------------------------------------------------------------
	-- Close the Info Screen Function. Using a transition effect to move it off screen
	----------------------------------------------------------------------------------------------------
	local function closeInfoScreen()
		local t1 = transition.to (	infoGroup, {alpha=1.0, y=_h+50, time=200} )	
		local t2 = transition.to (	SliderPanelGroup, {alpha=1.0, time=200} )	
	end
	
	----------------------------------------------------------------------------------------------------
	-- Open a URL from the show Web site button
	----------------------------------------------------------------------------------------------------
	local function openURLButton()
		system.openURL( openURLPage ) -- open URL in browser (Page from variable setup in main.lua
	end
	
	----------------------------------------------------------------------------------------------------
	-- Setup the close button on the INFO PANEL
	----------------------------------------------------------------------------------------------------
	local infoButton1 = widget.newButton{
		left = (_w/2)-60,
		top = _h-95,
		defaultFile = guiImages.."buttonCloseWindowOff.png",
		overFile = guiImages.."buttonCloseWindowOn.png",
		onRelease = closeInfoScreen,
		}			
	infoGroup:insert( infoButton1 )
	
	----------------------------------------------------------------------------------------------------
	-- Setup the show URL Button on the INFO PANEL
	----------------------------------------------------------------------------------------------------
	local infoButton2 = widget.newButton{
		left = (_w/2)+100,
		top = _h-280,
		defaultFile = guiImages.."buttonWebOff.png",
		overFile = guiImages.."buttonWebOn.png",
		onRelease = openURLButton,
		}			
	infoGroup:insert( infoButton2 )
	--Insert the Info Group Layer into the Main Layer
	screenGroup:insert( infoGroup )

	
	
	----------------------------------------------------------------------------------------------------
	-- START the code running with the init()
	----------------------------------------------------------------------------------------------------
	init()
end




-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	--Lots of cleanup - and then some more
	storyboard.purgeScene ( "mainCanvas" )
	storyboard.removeScene( "main" )
	storyboard.removeScene( "mainCanvas" )
	storyboard.removeAll() 
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
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
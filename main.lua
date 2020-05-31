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
-- main.lua
--
------------------------------------------------------------------------------------------------------------------------------------
-- 26-09-2012   : V2.5
------------------------------------------------------------------------------------------------------------------------------------

-- Hide the OS Status Bar
display.setStatusBar( display.HiddenStatusBar )

-- require controller module
local storyboard 		= require "storyboard"
local scene 			= storyboard.newScene()
local fps = require("fps")

------------------------------------------------------------------------------------------------------------------------------------
-- Defina Global Variables. Note we only create a few to keep memory as clean as possible
-- Also, I like to hold variables pointing to the various location to the Assets. This allows
-- me to keep the Project files tidy and organised. Normally we would not set up so many globals
-- we would set up local variables in the various Lua files. But to make changing this Template
-- Easier, I've set them up so you can change the key data in just the MAIN file.
------------------------------------------------------------------------------------------------------------------------------------
_G.whichImage			= "image1.png" 					-- Later on, we'll change this global data, with the users selection.
_G._w 					= display.contentWidth  		-- Get the devices Width
_G._h 					= display.contentHeight 		-- Get the devices Height
_G.deviceOrientation	= "Landscape"  					-- Change to "Landscape" as required. Note you will need to change the Config & Build settings Lua Files too.
_G.numberOfImages		= 10							-- Change according to how many images you have
_G.thumbnailsPerSlide	= 5								-- How many thumbnails do you want to show per slide.
_G.imagesPath			= "images/_Drawings/"			-- Define the root path to our Drawings.
_G.thumbnailPath		= "images/_Thumbnails/"			-- Define the root path to our Thumbnail/mini Drawings.
_G.guiImages			= "images/_GUI/"				-- Define the root path to the various GUI graphics.
_G.openURLPage			= "http://www.deepblueapps.com" -- Define the Web Site the [Open Web Site] button will load.

------------------------------------------------------------------------------------------------------------------------------------
-- Show or Hide the Debug Data?
-- Enable debug by setting to [true] to see FPS and Memory usage set to [False] to hide.
------------------------------------------------------------------------------------------------------------------------------------
local doDebug 			= false

if (doDebug) then
	local performance = fps.PerformanceOutput.new();
	performance.group.x, performance.group.y = (display.contentWidth/2)-320,  10;
	performance.alpha = 0.3; -- So it doesn't get in the way of the rest of the scene
end


------------------------------------------------------------------------------------------------------------------------------------
-- START -> Jump to the main menu screen.
------------------------------------------------------------------------------------------------------------------------------------
local function startMenu()
	storyboard.gotoScene( "mainMenu" )
end

startMenu()
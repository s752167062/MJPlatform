
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 1136,
    height = 640,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio > 1.8 then
            -- IPHONE X
            return {autoscale = "EXACT_FIT"}
        end
    end
}

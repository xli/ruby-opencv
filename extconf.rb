#!/usr/bin/env ruby
#/usr/local/bin/ruby
=begin
create Makefile script for Ruby/OpenCV

usage : ruby extconf.rb
        make && make install

VC : ruby extconf.rb
     nmake
=end
require "mkmf"

# option "opencv"
# extconf.rb --with-opencv-lib=/path/to/opencv/lib
# extconf.rb --with-opencv-include=/path/to/opencv/include

dir_config("opencv", "/usr/local/include", "/usr/local/lib")
if CONFIG["arch"].include?("darwin")
  dir_config("ffcall", "/opt/local/include", "/opt/local/lib")
else
  dir_config("ffcall", "/usr/local/include", "/usr/local/lib")
end
dir_config("libxml2", "/usr/include", "/usr/lib")

opencv_headers = ["opencv2/core/core_c.h", "opencv2/core/core.hpp", "opencv2/imgproc/imgproc_c.h",
                  "opencv2/imgproc/imgproc.hpp", "opencv2/video/tracking.hpp", "opencv2/features2d/features2d.hpp",
                  "opencv2/flann/flann.hpp", "opencv2/calib3d/calib3d.hpp", "opencv2/objdetect/objdetect.hpp",
                  "opencv2/legacy/compat.hpp", "opencv2/legacy/legacy.hpp", "opencv2/highgui/highgui_c.h",
                  "opencv2/highgui/highgui.hpp"]

opencv_libraries = ["opencv_calib3d", "opencv_contrib", "opencv_core", "opencv_features2d",
                    "opencv_flann", "opencv_gpu", "opencv_highgui", "opencv_imgproc",
                    "opencv_legacy", "opencv_ml", "opencv_objdetect", "opencv_video"]


puts ">> check require libraries..."
case CONFIG["arch"]
when /mswin32/
  have_library("msvcrt", nil)
  opencv_libraries.each{|lib|
    have_library(lib)
  }
else
  opencv_libraries.each{|lib|
    raise "lib#{lib} not found." unless have_library(lib)
  }
  #have_library("ml")
  have_library("stdc++")
end

# check require headers
puts ">> check require headers..."
opencv_headers.each{|header|
  raise "#{header} not found." unless have_header(header)
}
#have_header("ml.h")
have_header("stdarg.h")

# check require functions.
# todo

# optional libraies check.
puts ">> ----- optional -----"
puts ">> check ffcall..."
# check ffcall
if have_library("callback") && have_header("callback.h")
  puts ">> support OpenCV::GUI::Window#set_trackbar"
else
  puts ">> ! unsupport OpenCV::GUI::Window#set_trackbar (if need it. install ffcall)"
  puts "http://www.haible.de/bruno/packages-ffcall.html"
end

# Quick fix for 1.8.7
$CFLAGS << " -I#{File.dirname(__FILE__)}/ext/opencv"

# step-final. create Makefile
create_makefile("opencv", "./ext/opencv")


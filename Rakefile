Config = RbConfig if defined? RbConfig and not defined? Config # 1.9.3 hack

require 'rake/clean'
require 'bundler/setup'
require "releasy"

require_relative "lib/alpha_channel/version"

CLEAN.include("*.log")
CLOBBER.include("doc/**/*")

Releasy::Project.new do
  name "Alpha Channel"
  version AlphaChannel::VERSION
  executable "bin/alpha_channel.rbw"
  files `git ls-files`.split("\n")
  files.exclude ".gitignore"
  exposed_files %w[README.html]
  add_link "http://spooner.github.com/games/alpha_channel", "Alpha Channel website"
  exclude_encoding

  add_build :osx_app do
    url "com.github.spooner.games.alpha_channel"
    wrapper "../releasy/wrappers/gosu-mac-wrapper-0.7.41.tar.gz"
    add_package :tar_gz
  end

  add_build :source do
    add_package :zip
  end

  add_build :windows_folder do
    icon "media/icon.ico"
    ocra_parameters "--no-enc"
    add_package :zip
  end

  add_build :windows_installer do
    icon "media/icon.ico"
    readme "README.html"
    start_menu_group "Spooner Games"
    add_package :zip
  end

  add_deploy :github
end


desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end

PIXEL_GLOW_IMAGE = "media/image/pixel_glow.png"
BEAM_IMAGE = "media/image/control_beam.png"
FRAGMENT_GLOW_IMAGE = "media/image/fragment_glow.png"
CORNER_IMAGE = "media/image/corner.png"

desc "Generate images"
task "generate:images" do
  require 'gosu'
  require 'texplay'
  $window = Gosu::Window.new 10, 10, false

  create_pixel_glow
  create_control_beam
  create_fragment_glow
  create_corner
end

def create_pixel_glow
  t = Time.now.to_f

  glow = TexPlay.create_image($window, 160, 160, color: :alpha)
  glow.refresh_cache

  center = glow.width / 2
  radius =  glow.width / 2
  pixel_width = 16 # Radius of the pixel.
  pixel_radius = radius - pixel_width # Radius of the glow outside the pixel itself.

  glow.circle center, center, radius, color: :white, filled: true,
              color_control: lambda {|source, dest, x, y|
                # Glow starts at the edge of the pixel (well, its radius, since glow is circular, not rectangular)
                distance = Gosu::distance(center, center, x, y) - pixel_width
                dest[3] = (1 - (distance / pixel_radius)) ** 2
                dest
              }

  glow.save PIXEL_GLOW_IMAGE

  puts "Created #{PIXEL_GLOW_IMAGE} in #{"%.2f" % [Time.new.to_f - t]}"
end

def create_fragment_glow
  t = Time.now.to_f

  glow = TexPlay.create_image($window, 80, 80, color: :alpha)
  glow.refresh_cache

  center = radius = glow.width / 2

  glow.circle center, center, radius, color: :white, filled: true,
                color_control: lambda {|source, dest, x, y|
                  distance = Gosu::distance(center, center, x, y)
                  dest[3] = ((1 - (distance / radius)) ** 2) / 8.0
                  dest
                }

  glow.save FRAGMENT_GLOW_IMAGE

  puts "Created #{FRAGMENT_GLOW_IMAGE} in #{"%.2f" % [Time.new.to_f - t]}"
end

def create_control_beam
  t = Time.now.to_f

  image = TexPlay.create_image($window, 32, 32, color: :alpha)
  image.refresh_cache

  center = image.width / 2
  radius =  image.width / 2

  image.circle center, center, radius, color: :white, filled: true,
               color_control: lambda {|source, dest, x, y|
                 distance = Gosu::distance(center, center, x, y)
                 dest[3] = ((1 - (distance / radius)) ** 2) / 2
                 dest
               }

  image.save BEAM_IMAGE

  puts "Created #{BEAM_IMAGE} in #{"%.2f" % [Time.new.to_f - t]}"
end

def create_corner
  t = Time.now.to_f

  corner = TexPlay.create_image($window, 32, 32, color: :alpha)
  corner.refresh_cache

  center = 0
  radius =  corner.width

  corner.clear color: :black,
               color_control: lambda {|c, x, y|
                  distance = Gosu::distance(center, center, x, y)
                  if distance > radius
                    c[3] = ((0.25 - (distance / radius)) ** 2)
                  end
                  c
                }

  corner.save CORNER_IMAGE

  puts "Created #{CORNER_IMAGE} in #{"%.2f" % [Time.new.to_f - t]}"

end






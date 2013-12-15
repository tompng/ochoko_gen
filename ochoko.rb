require './lib/stl'
require './lib/util2d'

class Ochoko

  BASE_HEIGHT = 0.3
  CUP_HEIGHT = 1.5
  THICKNESS = 0.1
  W, H = 200, 200

  def self.create imgfile
    rand2d = Rand2D.new W, H, 0.1, 0.5
    texture = Texture.new imgfile

    line = -> t {
      r=0.8+0.4*(1-(1-t)**2)
      z=BASE_HEIGHT+CUP_HEIGHT*t
      [r,z]
    }

    stl = STL.new do
      pole W, H do |t1, z1|
        th = 2*Math::PI*t1
        if t = range(z1, 0..0.05)
          z2 = BASE_HEIGHT*t
          r2 = 0.9-0.1*t
        elsif t = range(z1, 0.05..0.75)
          r2, z2 = line.call t
          r2 -= THICKNESS/3*(1-texture.get(t1,1-t))
        elsif t = range(z1, 0.75..0.85)
          z2=CUP_HEIGHT+BASE_HEIGHT+Math.sin(Math::PI*t)*THICKNESS/2
          r2=1.2+(Math.cos(Math::PI*t)-1)*THICKNESS/2
        elsif t = range(z1, 0.85..1)
          r2, z2 = line.call 1-t
          r2 -= THICKNESS
        end
        rnd = 1+0.04*rand2d.get(t1, z2)
        {
          x: 20*rnd*r2*Math.cos(th),
          y: 20*rnd*r2*Math.sin(th),
          z: 20*z2
        }
      end
    end

    stl.data
  end
end

File.open 'ochoko.stl', 'w' do |f|
  f.write Ochoko.create 'image.png'
end

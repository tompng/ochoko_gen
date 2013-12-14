require 'chunky_png'

module Array2DGetter
  def [] x, y
    @data[x % width][y % height]
  end

  def get x, y
    #avoid bug ((-5e-17)%1).in?(0..1) => false
    ix,dx=(x%1%1*@width).divmod 1
    iy,dy=(y%1%1*@height).divmod 1
    jx=(ix+1) % @width
    jy=(iy+1) % @height
    @data[ix][iy]*(1-dx)*(1-dy)+
    @data[jx][iy]*dx*(1-dy)+
    @data[ix][jy]*(1-dx)*dy+
    @data[jx][jy]*dx*dy
  end
end

class Rand2D
  attr_reader :width, :height
  include Array2DGetter

  def initialize width, height, wscale, hscale = wscale
    @width, @height = width, height
    arr2d=height.times.map{
      width.times.map{2*rand-1}
    }.map{|line|
      Rand2D.smooth line, width*wscale
    }.transpose.map{|line|
      Rand2D.smooth line, height*hscale
    }
    deviation = Math.sqrt arr2d.map{|line|line.map{|x|x*x}.inject(:+)}.inject(:+)/width/height
    @data = arr2d.map{|line|line.map{|x|x/deviation}}
  end

  def self.smooth array, scale
    exp=->arr,e{
      z=0
      arr.each{|v|z=z*e+v}
      z*=1/(1-e**arr.size)
      arr.map{|v|z=z*e+v}
    }
    e=Math.exp(-3.0/scale)
    reversed=array.reverse
    sum1=exp.(array,e)
    sum2=exp.(array,e*e)
    rsum1=exp.(reversed,e).reverse
    rsum2=exp.(reversed,e*e).reverse
    array.size.times.map{|i|
      2*(sum1[i]+rsum1[i])-(sum2[i]+rsum2[i])-array[i]
    }
  end
end

class Texture
  attr_reader :width, :height
  include Array2DGetter

  def initialize file
    img = ChunkyPNG::Image.from_file file
    @width, @height = img.width, img.height
    @data = width.times.map{|x|
      height.times.map{|y|
        ChunkyPNG::Color.grayscale_teint(img[x,y]).fdiv(0xff)
      }
    }
  end
end

class STL
  module P3
    def self.dist2 a, b
      dx,dy,dz=b[:x]-a[:x],b[:y]-a[:y],b[:z]-a[:z]
      dx*dx+dy*dy+dz*dz
    end
    def self.dist a, b
      Math.sqrt diff2(a,b)
    end
    def self.near? a, b, dist
      dist2(a, b) < dist*dist
    end
    def self.interpolate_axis axis,p,px,py,pxy,x,y
      p[axis]*(1-x)*(1-y)+
      px[axis]*x*(1-y)+
      py[axis]*(1-x)*y+
      pxy[axis]*x*y
    end
    def self.average_axis axis, points
      points.map{|p|p[axis]}.inject(&:+).fdiv points.size
    end
    def self.average points
      {
        x: average_axis(:x, points),
        y: average_axis(:y, points),
        z: average_axis(:z, points)
      }
    end
    def self.interpolate *args
      {
        x: interpolate_axis(:x, *args),
        y: interpolate_axis(:y, *args),
        z: interpolate_axis(:z, *args)
      }
    end
  end

  def reducepole_rec x, y, w, h, points, flags, maxdist, procs
    pquads = points[x][y], points[x+w][y], points[x][y+h], points[x+w][y+h]
    unless (w==1&&h==1)||(0..w).all?{|ix|(0..h).all?{|iy|
              P3.near? points[x+ix][y+iy], P3.interpolate(*pquads, ix.fdiv(w), iy.fdiv(h)), maxdist
            }}
      if w > h
        reducepole_rec x, y, w/2, h, points, flags, maxdist, procs
        reducepole_rec x+w/2, y, w-w/2, h, points, flags, maxdist, procs
      else
        reducepole_rec x, y, w, h/2, points, flags, maxdist, procs
        reducepole_rec x, y+h/2, w, h-h/2, points, flags, maxdist, procs
      end
      return
    end
    (0..w).each{|ix|(0..h).each{|iy|
      points[x+ix][y+iy] = P3.interpolate *pquads, ix.fdiv(w), iy.fdiv(h)
    }}
    flags[x][y] = flags[x+w][y] = flags[x][y+h] = flags[x+w][y+h] = true

    procs << ->{
      coords = []
      w.times{|i|coords << points[x+i][y] if flags[x+i][y]}
      h.times{|i|coords << points[x+w][y+i] if flags[x+w][y+i]}
      w.times{|i|coords << points[x+w-i][y+h] if flags[x+w-i][y+h]}
      h.times{|i|coords << points[x][y+h-i] if flags[x][y+h-i]}
      if coords.size > 4
        center = P3.average coords
        coords.size.times{|i|
          face center, coords[i], coords[i-1]
        }
      else
        (coords.size-2).times{|i|
          face coords[0], coords[i+2], coords[i+1]
        }
      end
    }
  end

  def reducepole tlevel, zlevel, maxdist, &block
    points=(0..zlevel).map{|z|(0...tlevel).map{|t|block.(t.fdiv(tlevel), z.fdiv(zlevel))}}
    flags=(0..zlevel).map{(0...tlevel).map{nil}}
    procs = []
    reducepole_rec 0, -1, zlevel, tlevel, points, flags, maxdist, procs
    procs.each &:call
    [0, zlevel].each{|z|
      levelpoints = points[z]
      levelflags = flags[z]
      coords = (1..tlevel).map{|t|levelflags[t] && levelpoints[t]}.compact
      center = P3.average coords
      coords.size.times do |i|
        face center, coords[i-1], coords[i], z==0
      end
    }
  end

end

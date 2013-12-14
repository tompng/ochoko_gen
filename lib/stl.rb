class STL
  def initialize file, &block
    name = file.gsub /^[a-zA-Z0-9]/, ''
    @buffer = []
    stlputs "solid #{name}"
    begin
      instance_eval &block
    ensure
      stlputs "endsolid #{name}"
    end
    File.open(file,'w'){|f|f.write @buffer.join("\n")}
  end

  def range t, range
    (t-range.begin)/(range.end-range.begin) if range.include? t
  end

  def pole tlevel, zlevel, &block
    points=(0..zlevel).map{|z|
      (0...tlevel).map{|t|
        block.(t.fdiv(tlevel), z.fdiv(zlevel), tlevel, zlevel)
      }
    }
    [0, zlevel].each{|z|
      coords = points[z]
      center = Hash[[:x,:y,:z].map{|k|[k,coords.map{|p|p[k]}.inject(&:+)/tlevel]}]
      tlevel.times do |i|
        face center, coords[i-1], coords[i], z==0
      end
    }
    zlevel.times do |z0|
      z1 = z0 + 1
      tlevel.times do |t1|
        t0 = t1 - 1
        face points[z0][t0], points[z0][t1], points[z1][t0]
        face points[z1][t0], points[z0][t1], points[z1][t1]
      end
    end
  end

  private

  def stlputs str
    @buffer << str
  end

  def face p1,p2,p3,flip=false
    p2,p3=p3,p2 if flip
    stlputs "facet normal 0 0 0"
    stlputs "outer loop"
    [p1,p2,p3].each do |p|
      stlputs "vertex #{p[:x].round 4} #{p[:y].round 4} #{p[:z].round 4}"
    end
    stlputs "endloop"
    stlputs "endfacet"
  end

end

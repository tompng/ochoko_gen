require './lib/stl'
require './lib/stl_reduce'
require './lib/util2d'

BASE_HEIGHT=0.3
CUP_HEIGHT=1.5
THICKNESS=0.15
BASE_RADIUS=0.8
BOTTOM_RADIUS=0.9
TOP_RADIUS=1.2

W=800/4
H=400/4

texture = Texture.new 'image.png'

STL.new 'ochoko', file: 'set_ochoko.stl' do
  rand2d = Rand2D.new W, H, 0.1, 0.5
  line=->t{
    [
      BASE_RADIUS+(TOP_RADIUS-BASE_RADIUS)*(1-(1-t)**2)*(1-Math.exp(-8*t)),
      BASE_HEIGHT+CUP_HEIGHT*t
    ]
  }
  reducepole W, H, 0.02 do |t1, z1|
    th = 2*Math::PI*t1
    pr,pz=0,0
    pos1,pos2,pos3,pos4=0.1,0.6,0.7,0.9
    if t = range(z1, 0..pos1)
      pz=BASE_HEIGHT*t
      pr=(BOTTOM_RADIUS+(BASE_RADIUS-BOTTOM_RADIUS)*t)*(0.96+0.04*Math.sqrt(1-Math.exp(-9*t)))
      pr-=(BASE_RADIUS-BOTTOM_RADIUS)*t*(1-Math.exp(-8*(1-t)))/8
    elsif t = range(z1, pos1..pos2)
      pr,pz=line.(t)
      tx,ty=1.4*t1,1-t
      pr*=1-THICKNESS/3*(1-texture.get(tx,ty)) if (0..1).include?(tx)&&(0..1).include?(ty)
    elsif t = range(z1, pos2..pos3)
      pz=CUP_HEIGHT+BASE_HEIGHT+Math.sin(Math::PI*t)*THICKNESS/2
      pr=TOP_RADIUS+(Math.cos(Math::PI*t)-1)*THICKNESS/2
    elsif t = range(z1, pos3..pos4)
      pr,pz=line.(1-t)
      pr-=THICKNESS
    elsif t = range(z1, pos4..1)
      pr=(BASE_RADIUS-THICKNESS)*Math.cos(t*Math::PI/2)
      pz=BASE_HEIGHT-BASE_HEIGHT*Math.sin(t*Math::PI/2)/4
    end
    cos = Math.cos th
    sin = Math.sin th
    pz*=1+0.02*rand2d.get(0.1*cos*pr,0.1*sin*pr)
    twist_tmp=Math.exp(8*(pz-(BASE_HEIGHT+0.5*CUP_HEIGHT)))
    twist=twist_tmp/(1+twist_tmp)
    pr*=1+0.04*rand2d.get(t1+0.1*twist,pz/(BASE_HEIGHT+CUP_HEIGHT+THICKNESS/2))
    {
      x:16*pr*cos-30,
      y:16*pr*sin,
      z:16*pz
    }
  end
end


TOKKURI_THICKNESS=THICKNESS
STL.new 'tokkuri', file: 'set_tokkuri.stl' do
  rand2d = Rand2D.new W, H, 0.1, 0.5
  line=->z{[1+2*z-4*z**2+2*z**5, z]}
  reducepole W, H, 0.02 do |t1, z1|
    th = 2*Math::PI*t1
    pr,pz=0,0
    pos1,pos2=0.7,0.8
    if t = range(z1, 0..pos1)
      pr,pz=line.(t)
      tx,ty=1.2*t1,2*(1-t)-0.8
      pr*=1-THICKNESS/3*(1-texture.get(tx,ty)) if (0..1).include?(tx)&&(0..1).include?(ty)
    elsif t = range(z1, pos1..pos2)
      c=TOKKURI_THICKNESS*(Math.cos(Math::PI*t)-1)/2
      s=TOKKURI_THICKNESS*Math.sin(Math::PI*t)/2
      pr=1+c+s
      pz=1+s/4
    elsif t = range(z1, pos2..1)
      pr,pz=line.(1-t)
      pr-=TOKKURI_THICKNESS
      pz=Math.sqrt((TOKKURI_THICKNESS**2/16+pz**2)/(1+TOKKURI_THICKNESS**2/16))
    end
    cos = Math.cos th
    sin = Math.sin th
    pr*=1-pz*pz/4
    twist_tmp=Math.exp(20*(pz-0.5))
    twist=twist_tmp/(1+twist_tmp)
    pr*=1+0.04*rand2d.get(t1+0.2*twist,pz)
    pz*=4
    pos={x:pr*cos,y:pr*sin,z:pz}
    effect = Math.exp(-pos[:x])*Math.exp(-pos[:y]*pos[:y])*Math.exp(2*(pos[:z]-4))
    pos[:z]*=1-0.015*effect
    pos[:y]*=1-0.5*(1-Math.exp(-effect*effect))
    pos[:x]*=1+0.05*effect
    pos[:x]*=20
    pos[:y]*=20
    pos[:z]*=20
    pos[:x]+=30
    pos
  end
end

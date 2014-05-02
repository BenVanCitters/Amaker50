PImage img;
float growMinutesTo100pct = 5.5;
long firstRender = -1;

void setup()
{
  size(displayWidth, displayHeight,P3D);
  noCursor();
  img = loadImage("brentFBbw.png");
  textureMode(NORMAL);
//  smooth(2);
}

void draw()
{
  background(0);
  float sz = (millis()-firstRender)/(growMinutesTo100pct*60*1000.f);
  sz = .1+pow(sz,5.5);;
  
  String s = "sz = " + sz + "\nCurMillis: " + (millis()-firstRender) + "\nfirstRender: " + firstRender;
  textSize(32);
  
  if(firstRender < 0)
    firstRender = millis();
  
  stroke(0,255,0);
  pushMatrix();
  translate(width/2,height/2);
//  scale(millis()/(6.5*60*1000.f));
  float halfHeight = sz*height/2.f;
  noStroke();
  beginShape(TRIANGLE_STRIP);
  texture(img);
  vertex(-halfHeight,-halfHeight,0,0);
  vertex(-halfHeight,halfHeight,0,1);
  vertex(halfHeight,-halfHeight,1,0);
  vertex(halfHeight,halfHeight,1,1);
  endShape();
  popMatrix();
// fill(0,255,0);
//  text(s,10,150);
println(s);
}

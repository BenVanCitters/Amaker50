import java.util.*;
import megamu.mesh.*;
import processing.video.*;

float[][] points;
ArrayList<VonShape> shapes;

PImage anti;

void setup()
{
  size(displayWidth,displayHeight,P3D);
//  size(700,550,P3D);
  noCursor();
//  smooth();
  anti = loadImage("anti2.png");
  textureMode(IMAGE);
  initVoronoi();  
}

public void initVoronoi()
{
  ArrayList<float[]> validPoints = new ArrayList<float[]>();
  fillArrayWithValidImagePoints(validPoints,200);
  
  points = new float[900][2];
  for(int i =0; i < points.length; i++)
  {
    if(validPoints.size() > 0)
    {
      int ptIndex = (int)random(validPoints.size());
      points[i] = validPoints.get(ptIndex);
      validPoints.remove(ptIndex);
    }  
  }

  validPoints.clear();
  fillArrayWithValidImagePoints(validPoints,200);
  Voronoi myVoronoi = new Voronoi( points );
  MPolygon[] myRegions= myVoronoi.getRegions();
  
  shapes = new ArrayList<VonShape>();
  for(int i = 0; i < myRegions.length; i++)
  {
    if(isRegionWithinBounds(myRegions[i], validPoints))
      shapes.add(new VonShape(myRegions[i],points[i]));
  }
}

void fillArrayWithValidImagePoints(ArrayList<float[]> validPoints,float brightnessThreshhold)
{
  anti.loadPixels();
  for(int i = 0; i < anti.pixels.length; i++)
  {
    if(brightness(anti.pixels[i]) > brightnessThreshhold)
    {
      int x = i%anti.width;
      int y = i/anti.width;
      validPoints.add(new float[]{x* width*1.f/anti.width,
                                  y* height*1.f/anti.height});
    }
  }
}

boolean isRegionWithinBounds(MPolygon poly, ArrayList<float[]> validPoints)
{
//    boolean result = true;
    float tmp[][] = poly.getCoords();

    float imgSpcCoord[] = new float[]{0,0};
    for(int i = 0; i < tmp.length; i++)
    {
      imgSpcCoord[0] = (int)(tmp[i][0]);// * anti.width*1.f/width); 
      imgSpcCoord[1] = (int)(tmp[i][1]);// * anti.height*1.f/height);
      boolean foundMatch = false;
      for(float[] coord : validPoints)
      { 
        float pointDiff[] = new float[]{tmp[i][0]-coord[0],tmp[i][1]-coord[1]};
        if(dist(0,0,pointDiff[0],pointDiff[1]) < 5)
        {
          foundMatch = true;
          break;
        }        
      }
      if(!foundMatch)
        return false;
//      result = result & foundMatch ;
    }
    return true;
}

void draw()
{
  background(255,0,0);
  //lights();
  float tm = millis()/1000.f;
  float lightpos[]= new float[]{width/2*(1+cos(tm/10)),height/2*(1+sin(tm/10)),5};
  pushMatrix();
  translate(lightpos[0],lightpos[1],lightpos[2]);
  fill(0,255,0);
  ellipse(0,0,50,50);
  popMatrix();
  for(VonShape shape : shapes)//for(int i = 0; i < shapes.size(); i++)
  {
    shape.update(lightpos,100);
    shape.draw(anti);
  }
  hint(DISABLE_DEPTH_TEST);
  for(VonShape shape : shapes)//  int i = 0; i < shapes.length; i++)
  {
//    VonShape shape = shapes.get(i);  
    shape.drawHalo();
  }   
  hint(ENABLE_DEPTH_TEST);
  println("frameRate: " + frameRate);
}

void keyPressed() 
{
  float amt = 0.0;
  float thtD = 0;
  
  if (key == 'a') 
  {
      amt = .4;
      thtD = .005;          
  }
  if (key == 's') 
  {
      amt = 4.0;
      thtD = .01;          
  }
  if (key == 'd') 
  {
      amt = 8.0;
      thtD = .02;          
  }
  if (key == 'f') 
  {
      amt = 12.0;
      thtD = .07;          
  }
  if (key == 'g') 
  {
      amt = 22.0;
      thtD = .1;          
  }
//  for(int i = 0; i < shapes.length; i++)
for(VonShape shape : shapes)
  {
    shape.applyForce(new float[]{0,0,0}, 
                             new float[]{random(thtD)-thtD/2,
                                         random(thtD)-thtD/2,
                                         random(thtD)-thtD/2});
  }
  if (key == 'q') 
  {
    initVoronoi();
  }
}

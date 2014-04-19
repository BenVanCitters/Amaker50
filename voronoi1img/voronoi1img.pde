import java.util.*;
import megamu.mesh.*;
import processing.video.*;

float[][] points;
MPolygon[] myRegions;
VonShape[] shapes;
Voronoi myVoronoi;
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
  ArrayList<int[]> validPoints;
  anti.loadPixels();
  for(int i = 0; i < anti.pixels.length; i++)
  {
    
  }
  
  
  points = new float[100][2];
  for(int i =0; i < points.length; i++)
  {
    int count = 2;
    for(int j = 0; j < count; j++)
      points[i][0] += random(width*1.0f/count); // first point, x
    for(int j = 0; j < count; j++)
      points[i][1] += random(height*1.0f/count); // first point, y      
  }

  myVoronoi = new Voronoi( points );
  myRegions = myVoronoi.getRegions();
  shapes = new VonShape[myRegions.length];
  for(int i = 0; i < myRegions.length; i++)
  {
    shapes[i] = new VonShape(myRegions[i],points[i]);
  }
}

void draw()
{
  background(0);
  lights();
  float lightpos[]= new float[]{mouseX,mouseY,-100};
  for(int i = 0; i < shapes.length; i++)
  {
    shapes[i].update(lightpos,100);
    shapes[i].draw(anti);
  }
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
  for(int i = 0; i < shapes.length; i++)
  {
    shapes[i].applyForce(new float[]{0,0,0}, 
                             new float[]{random(thtD)-thtD/2,
                                         random(thtD)-thtD/2,
                                         random(thtD)-thtD/2});
  }
  if (key == 'q') 
  {
    initVoronoi();
  }
}

import java.util.*;
import megamu.mesh.*;
import processing.video.*;

float[][] points;
ArrayList<VonShape> shapes;

RollingSampleListener rSlisten; 

int shaftStartColor = color(255,170,170,70);
int shaftEndColor = color(0,0,0,1);
PImage anti;

void setup()
{
  size(displayWidth,displayHeight,P3D);
//  size(700,550,P3D);
  textSize(25);
  noCursor();
//  smooth();
  anti = loadImage("newFif.png");
  textureMode(IMAGE);
  initVoronoi();  
  
  initAudio();
}

public void initAudio()
{
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 1024);
  rSlisten = new RollingSampleListener();
  in.addListener(rSlisten); 
}

public void initVoronoi()
{
  ArrayList<float[]> validPoints = new ArrayList<float[]>();
  fillArrayWithValidImagePoints(validPoints,200);
  
  
  points = new float[1200][2];
  println("creating " + points.length + " vonShapes...");
  for(int i =0; i < points.length; i++)
  {
    if(validPoints.size() > 0)
    {
      int ptIndex = (int)random(validPoints.size());
      points[i] = validPoints.get(ptIndex);
      validPoints.remove(ptIndex);
    }  
  }
  println("...done\ncreating Voronoi regions...");

  validPoints.clear();
  fillArrayWithValidImagePoints(validPoints,200);
  Voronoi myVoronoi = new Voronoi( points );
  MPolygon[] myRegions= myVoronoi.getRegions();
  println("...done\ncropping regions...");
  
  shapes = new ArrayList<VonShape>();
  for(int i = 0; i < myRegions.length; i++)
  {
    if(isRegionWithinBounds(myRegions[i], validPoints))
      shapes.add(new VonShape(myRegions[i],points[i]));
  }
  println("...done");
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

float levelDiff = 0;
void draw()
{
  background(0);
  float tm = millis()/1000.f;
  float lightpos[]= new float[]{width/2*(1+cos(tm/1.3)/2),
                                height/2*(1+sin(tm/3.1)/2),
                                -.01-1000*(1+sin(tm/6))/2};
  pointLight(255, 255, 255, 
             lightpos[0],lightpos[1],lightpos[2]);
  ambientLight(150,150,150);
  pushMatrix();
  translate(lightpos[0],lightpos[1],lightpos[2]);
  fill(0,255,0);
//  ellipse(0,0,50,50);
  popMatrix();
  
  fill(255);
  levelDiff = max(0,in.mix.level()-levelDiff);
  if(levelDiff > .1)
  {
    float thtD = .2;
    for(VonShape shape : shapes)
    {
      shape.applyForce(new float[]{0,0,0}, 
                               new float[]{random(thtD)-thtD/2,
                                           random(thtD)-thtD/2,
                                           random(thtD)-thtD/2});
    }
  }
  
  println("levelDiff: " + levelDiff);
  float shaftLen = levelDiff;//200*curMax;//(cos(tm/20)+1)/2;
  for(VonShape shape : shapes)//for(int i = 0; i < shapes.size(); i++)
  {
    shape.update(lightpos,shaftLen,tm);
    shape.draw(anti);
  }
  hint(DISABLE_DEPTH_TEST);
  noLights();
  for(VonShape shape : shapes)//  int i = 0; i < shapes.length; i++)
  {
    shape.drawHalo();
  }   
  String hashtag = "#Amaker50";
//  text(hashtag , width/2-textWidth(hashtag)/2,height-50);
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
    saveFrame("/captures/###.png");
  }
//  if (key == 'q') 
//  {
//    initVoronoi();
//  }
}

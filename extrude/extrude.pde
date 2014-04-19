float[][] points;
float lightpos[];

void setup()
{
  size(500,500,OPENGL);
  points = new float[][]{{-50,50,0},{50,50,0},{50,-50,0},{-50,-50,0}};
  lightpos = new float[]{0,0,1};
}

void draw()
{
  float tm = millis()/1000.f;
  background(0);
  lightpos[0] = mouseX;
  lightpos[1] = mouseY;
  lightpos[2] = sin(tm)*200;
 
  //draw light
  pushMatrix();
  translate(lightpos[0],lightpos[1],lightpos[2]);
  ellipse(0,0,50,50);
  popMatrix();
  
  pushMatrix();
  translate(width/2,height/2);
//translate(mouseX,mouseY);
  rotateX(tm/2);
  rotateZ(tm/3.5);
  pushMatrix();
  PMatrix3D pMat = new PMatrix3D();
  pMat.translate(width/2,height/2);
  pMat.rotateX(tm/2);
  pMat.rotateZ(tm/3.5);
//  getMatrix(pMat);
  popMatrix();
  //get 'shadow' points
  float[][] spoints = new float[points.length][3];
  for(int i = 0; i < points.length;i++)
  {
    pMat.mult(points[i],spoints[i]);
    float[] lightDir = new float[]{spoints[i][0]-lightpos[0],
                                   spoints[i][1]-lightpos[1],
                                   spoints[i][2]-lightpos[2]};
    float dirLen = dist(0,0,0, lightDir[0],lightDir[1],lightDir[2]);
    lightDir[0] /=dirLen; 
    lightDir[1] /=dirLen;
    lightDir[2] /=dirLen;
    
    lightDir[0] *= 150;
    lightDir[1] *= 150;
    lightDir[2] *= 150;
    spoints[i][0]+= lightDir[0];
    spoints[i][1]+= lightDir[1];
    spoints[i][2]+= lightDir[2];
//    points[i][0],points[i][1],points[i][2]
  }  
  
  //draw shape
  fill(0,255,255);
  beginShape();
  for(int i = 0; i < points.length;i++)
  {
    vertex(points[i][0],points[i][1],points[i][2]);
  }
  endShape();
  popMatrix();
  
  fill(0,0,255,90);
  noStroke();
  beginShape(TRIANGLE_STRIP);
  float newPont[] =new float[3];
  for(int i = 0; i < points.length;i++)
  {
    pMat.mult(points[i],newPont);
    fill(0,0,255);
    vertex(newPont[0],newPont[1],newPont[2]);
    fill(255,10);
    vertex(spoints[i][0],spoints[i][1],spoints[i][2]);
  }
  pMat.mult(points[0],newPont);
  fill(0,0,255);
  vertex(newPont[0],newPont[1],newPont[2]);
  fill(255,10);
  vertex(spoints[0][0],spoints[0][1],spoints[0][2]);
  endShape();
}

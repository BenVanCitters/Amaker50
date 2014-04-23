class VonShape
{
  private PMatrix3D mat; 
  private float[] pos;
  private float[] vel;
  
  private float[] rotPos;
  private float[] rotVel;
  
  private float[][] pts;
  private float[][] spts;
  private float[][] texCoords;	
  private boolean offScr;
  
  public VonShape(MPolygon region, float[] pt)
  {
    mat = new PMatrix3D();
    offScr = false;
    rotPos = new float[]{0.0f,0.0f,0.0f};
    rotVel = new float[]{0.0f,0.0f,0.0f};//{random(.05),random(.05),random(.05)};
    vel    = new float[]{0.0f,0.0f,0.0f};
    
    pos = new float[]{pt[0],pt[1],0.0f};
    
    // the mesh lib doesn't copy the array for us so we 
    // must be careful not to write over the org. data
    float tmp[][] = region.getCoords();
    pts = new float[tmp.length][3];
    spts = new float[tmp.length][3];

    texCoords = new float[pts.length][2];
    for(int i = 0; i < pts.length; i++)
    {
      pts[i][0] = max(min(tmp[i][0],width),0);
      pts[i][0] -= pos[0];
      pts[i][1] = max(min(tmp[i][1],height),0);
      pts[i][1] -= pos[1];
      pts[i][2] = 0.0f;
      texCoords[i][0] = tmp[i][0] * 1366.0/width;// max(min(tmp[i][0],640),0);
      texCoords[i][1] = tmp[i][1] * 768.0/height;//max(min(tmp[i][1],480),0);
    }
  } 
  
  public void applyForce(float[] acc, float[] rtv)
  {
    vel[0] += acc[0];
    vel[1] += acc[1];
    vel[2] += acc[2];
        
    rotVel[0] += rtv[0];
    rotVel[1] += rtv[1];
    rotVel[2] += rtv[2];
  }
  
  public void update(float[] lightpos, float trailLen,float tm)
  {
//    rotPos[0] = 2*(cos(tm + pos[0]/400)+1)/2;  
//    rotPos[1] += 0;
//    rotPos[2] = 2*(cos(tm + pos[1]/300)+1)/2;
    float rotIncrement = .5*trailLen;
    float rotFade = .95; 
    
//    rotVel[0] += rotIncrement*.2;
//    rotVel[1] += rotIncrement*.1;
//    rotVel[2] += rotIncrement * .1;
    
    rotVel[0] *= rotFade;//= min(rotFade*rotVel[0],.1);
    rotVel[1] *= rotFade;
    rotVel[2] *= rotFade;
    
    rotPos[0] += rotVel[0];
    rotPos[1] += rotVel[1];
    rotPos[2] += rotVel[2];
    
//    pos[0] += vel[0];
//    pos[2] += vel[1];
//    pos[1] += vel[2];

    mat.reset();
    mat.translate(pos[0],pos[1],pos[2]);
    mat.rotateX(rotPos[0]);
    mat.rotateY(rotPos[1]);
    mat.rotateZ(rotPos[2]);
    
    float tmp = trailLen*1150*(sin(pos[0]/12 +tm)+1)*(sin(pos[1]/22 +tm)+1)/2;
    for(int i = 0; i < pts.length;i++)
    {
      mat.mult(pts[i],spts[i]);
      float[] lightDir = new float[]{spts[i][0]-lightpos[0],
                                     spts[i][1]-lightpos[1],
                                     spts[i][2]-lightpos[2]};
      float dirLen = dist(0,0,0, lightDir[0],lightDir[1],lightDir[2]);
      lightDir[0] /=dirLen; 
      lightDir[1] /=dirLen;
      lightDir[2] /=dirLen;
      
      lightDir[0] *= tmp;
      lightDir[1] *= tmp;
      lightDir[2] *= tmp;
      spts[i][0]+= lightDir[0];
      spts[i][1]+= lightDir[1];
      spts[i][2]+= lightDir[2];
    }
  }
  
  public void drawHalo()
  {
    pushMatrix();
    noStroke();
    beginShape(TRIANGLE_STRIP);
    float newPont[] =new float[3];
    for(int i = 0; i < pts.length;i++)
    {
      mat.mult(pts[i],newPont);
      fill(shaftStartColor);
      vertex(newPont[0],newPont[1],newPont[2]);
      fill(shaftEndColor);
      vertex(spts[i][0],spts[i][1],spts[i][2]);
    }
    mat.mult(pts[0],newPont);
    fill(shaftStartColor);
    vertex(newPont[0],newPont[1],newPont[2]);
    fill(shaftEndColor);
    vertex(spts[0][0],spts[0][1],spts[0][2]);
    endShape();
    popMatrix();
    pushMatrix();
    translate(pos[0],pos[1],pos[2]);
    fill(255);
    stroke(255);
    float rotSpd = dist(0,0,0,rotVel[0],rotVel[1],rotVel[2]);
//    text("rotSpd:" + rotSpd , 0,0); 
//    text("rotVel:{" + rotVel[0] + "," + rotVel[1] + "," + rotVel[2] + "}", 0,0); 
    popMatrix();
  }
  
  public void draw(PImage tex)
  {
    //textureMode(IMAGE);
    pushMatrix();
    applyMatrix(mat);
    
    noStroke();
    beginShape();
//    texture(tex);
    for(int i = 0; i < pts.length; i++)
    {
      vertex(pts[i][0],pts[i][1],pts[i][2]
//             ,texCoords[i][0],texCoords[i][1]
             );
    }
    endShape();
    popMatrix();
  }
  
  float[] getPos()
  {
    return new float[]{pos[0],pos[1],pos[2]};
  }

  boolean isOnScreen()
  {
    return !offScr;
  }
}


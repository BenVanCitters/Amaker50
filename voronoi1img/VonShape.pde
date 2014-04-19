class VonShape
{
  private float[] pos;
  private float[] vel;
  
  private float[] rotPos;
  private float[] rotVel;
  
  private float[][] pts;
  private float[][] texCoords;	
  private boolean offScr;
  
  public VonShape(MPolygon region, float[] pt)
  {
    offScr = false;
    rotPos = new float[]{0.0f,0.0f,0.0f};
    rotVel = new float[]{0.0f,0.0f,0.0f};//{random(.05),random(.05),random(.05)};
    vel    = new float[]{0.0f,0.0f,0.0f};
    
    pos = new float[]{pt[0],pt[1],0.0f};
    
    // the mesh lib doesn't copy the array for us so we 
    // must be careful not to write over the org. data
    float tmp[][] = region.getCoords();
    pts = new float[tmp.length][3];

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
  
  public void update()
  {
    rotPos[0] += rotVel[0];
    rotPos[1] += rotVel[1];
    rotPos[2] += rotVel[2];
   
    pos[0] += vel[0];
    pos[2] += vel[1];
    pos[1] += vel[2];
    float sx = screenX(pos[0],pos[1],pos[2]);
    float sy = screenY(pos[0],pos[1],pos[2]);
    if(sx < 0 || sx > width)
      offScr = true;
    if(sy < 0 || sy > height)
      offScr = true;
  }
  
  public void draw(PImage tex)
  {
    //textureMode(IMAGE);
    pushMatrix();
    translate(pos[0],pos[1],pos[2]);
    rotateX(rotPos[0]);
    rotateY(rotPos[1]);
    rotateZ(rotPos[2]);
//    rotateX(mouseX*TWO_PI/width);
//    rotateY(random(1));
//    rotateZ(random(1));
    noStroke();
    beginShape();
    texture(tex);
    for(int i = 0; i < pts.length; i++)
    {
      vertex(pts[i][0],pts[i][1],pts[i][2],
             texCoords[i][0],texCoords[i][1]);
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

